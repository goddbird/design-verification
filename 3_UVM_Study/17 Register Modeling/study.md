# 目標

1. 介紹register modeling的目的
2. 建立一個register的reference model
3. 如何把model加入環境中
4. 在simulation中打出自定義的stimulus

---
# 介紹
UVM register model是一種high level的abstract class，用來對DUT中有地址映射的register跟memory進行建模，`可以反映DUT中register的各種特性`，讓工程師可以不用手動紀錄每個register的位置與值，也可以產生Stimulus對DUT的register進行檢查，透過UVM register model可以進行front door / back door的操作。
![image](https://github.com/user-attachments/assets/1c66938f-8323-4197-a267-7628514cce0e)

以之前要驗的router為例，可以把檔案歸納成下列這幾個:
router_reg.sv：包含所有寄存器  
router_reg_block.sv：建構 reg block 與 memory  
router_reg_sequence.sv：示範如何用 sequence 測試 register  

註: Shadow copy
後面會介紹.write()的使用方式，當你用 .write() 去寫一個 DUT 裡的 register 時，RAL 除了透過 bus 把資料送進 DUT，自己也會記住你剛剛寫的是什麼值，這就是 shadow copy。
同樣的，當你從 DUT 用 .read() 讀一個 register 時，RAL 可以拿這個值與 shadow copy 比對，看是不是你預期的結果（例如用 .mirror() 自動比較）。

---
# UVM對驗證register給出一些方法
1. 會針對register，define出uvm_reg_block
uvm_reg/uvm_mem，最小單位是uvm_field
2. 並抓取register對應的屬性。e.g. RW / RO etc
3. 可以使用reg名稱來代替address e.g. 使用en_reg來代替0x1001
4. 可以支援位置mapping
5. 可以包含coverage
![image](https://github.com/user-attachments/assets/0161159c-06aa-45e1-9b85-e967af7b7dcc)

結論: UVM的register API可以讓你省去為每種bus寫專屬sequence的麻煩，直接用統一的方法存取register。
---


# UVM register model怎麼和DUT配合?
1. 使用register API存取register
```systemverilog
model.ctrl_reg.write(..., 8'h00);
model.ctrl_reg.read(..., rdata, UVM_BACKDOOR);
```
這段程式碼不是直接對 bus 下指令，而是：  
透過 register model 存取 DUT 的 register  
可以選擇使用 frontdoor（經由 bus） 或 backdoor（直接存取 RTL） 方法  
2. Frontdoor: 透過bus存取
- ctrl_reg.write()被翻譯成UVC的transaction(由adapter轉換)
- 經由seqr -> driver -> bus傳到DUT
- 需要一個UVM

🔁 優點：

模擬真實 bus 行為

可檢查握手/時序錯誤

✅ 3. Backdoor：直接寫入 RTL 層
ctrl_reg.read(..., UVM_BACKDOOR) 表示不走 bus

直接從 RTL 層的 hierarchical path 取值

📍 需要：

DUT 要有 hierarchical path（e.g. top.dut.ctrl_reg）

⚠️ 注意：

模擬速度快但不代表實際硬體運作

通常用在 initialization 或 reset check

✅ 4. Register Model（右側 YAPP Register Model）
是 UVM 自動生成的 class 結構

把 DUT 裡每個 register/memory 的資訊（名稱、地址、存取模式）建成 model

每個 register 都會有 shadow copy 可驗證

---
# 建立register model流程
## 1. 建立一個 Register class
這是你定義一個單獨 Register 的地方，使用 uvm_reg 來繼承。
```systemverilog
class en_reg extends uvm_reg;
    rand uvm_reg_field router_en;

    function new(string name = "en_reg");
        super.new(name, 8, UVM_NO_COVERAGE); // 這個 register 是 8-bit
    endfunction

    virtual function void build();
        router_en = uvm_reg_field::type_id::create("router_en");
        router_en.configure(this, 1, 0, "RW", 0, 1, 1, 0); 
    endfunction
endclass
```
📌 重點說明：  
router_en 是這個 register 裡的一個 field。  
.configure() 裡面定義的是 field 的 bit 寬度、位置、讀寫權限、reset 值等。  
這一步就是在告訴 RAL：「我這個 register 有什麼結構」。  


## 2. 建立register block
這是 將多個 Register 組合起來 的地方，也就是 RAL 架構的「管理層」。
```systemverilog
class router_reg_block extends uvm_reg_block;
    rand en_reg en_reg_h;

    function new(string name = "router_reg_block");
        super.new(name, build_coverage(UVM_NO_COVERAGE));
    endfunction

    virtual function void build();
        default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);

        en_reg_h = en_reg::type_id::create("en_reg_h");
        en_reg_h.build();
        en_reg_h.configure(this);
        default_map.add_reg(en_reg_h, 'h1001, "RW");
    endfunction
endclass
```
📌 重點說明：  
create_map() 創建了 register map，告訴 UVM 你從什麼起始位址開始，位元組間距等。  
add_reg() 把之前定義好的 register 放到 map 中並指定 address。  
這是讓你可以用 .ctrl_reg.write(...) 而不是 write_to_addr(0x1001) 的關鍵步驟。  


## 3. 建立adapter (FRONT DOOR才需要)
Adapter 的角色是：把 RAL 的讀寫請求，轉成 bus protocol 的 transaction，傳給seqr(後續透過seqr -> driver -> bus)，也就是連結 RAL 與 Bus UVC 的橋樑。
```systemverilog
class router_reg_adapter extends uvm_reg_adapter;

    function new(string name = "router_reg_adapter");
        super.new(name);
        supports_byte_enable = 0;
        provides_responses = 1;
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        hbus_transaction tx = hbus_transaction::type_id::create("tx");
        tx.addr = rw.addr;
        tx.data = rw.data;
        tx.kind = (rw.kind == UVM_READ) ? READ : WRITE;
        return tx;
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        hbus_transaction tx;
        $cast(tx, bus_item);
        rw.addr = tx.addr;
        rw.data = tx.data;
        rw.kind = (tx.kind == READ) ? UVM_READ : UVM_WRITE;
        rw.status = UVM_IS_OK;
    endfunction
endclass
```
📌 重點說明：  
reg2bus() 是 write/read 前會被呼叫，把 register 的操作轉換成 bus 傳輸。  
bus2reg() 則是從 bus 收到回應時用來轉回 RAL 格式。  

## 4. 在 test 中用 .write() 與 .mirror() 來驗證
*注意: write也可以直接以backdoor型式寫入DUT，如此就不用經過BUS。
```systemverilog
initial begin
    router_reg_block reg_blk;
    router_reg_adapter reg_adapt;

    // 建立 reg block & adapter
    reg_blk = router_reg_block::type_id::create("reg_blk");
    reg_adapt = router_reg_adapter::type_id::create("reg_adapt");

    reg_blk.build();
    reg_blk.lock_model(); // 鎖住 reg 架構
    reg_blk.default_map.set_sequencer(p_sequencer, reg_adapt);

    // 寫入 register
    reg_blk.en_reg_h.router_en.write(status, 1'b0);

    // 讀回來 check
    uvm_reg_data_t read_val;
    reg_blk.en_reg_h.router_en.read(status, read_val);
    `uvm_info("REG_CHECK", $sformatf("Read back = %0h", read_val), UVM_LOW)

    // mirror() 自動比對 DUT 值與 shadow copy
    reg_blk.en_reg_h.mirror(status, UVM_CHECK);
end
```

📌 重點說明：
.write()：會透過 adapter 呼叫 bus 去寫入 register。  
.read()：同樣透過 adapter 讀出值。  
.mirror()：自動比對 shadow copy 和真實 DUT 的 register 值是否一致，不用你自己寫 if/else 判斷式去比！  

---

# UVM register model架構
🔍 功能總結：
| 功能                       | 說明                                           |
| ------------------------ | -------------------------------------------- |
| **階層式建模**                | `uvm_reg_block` → 包含多個 `uvm_reg` 和 `uvm_mem` |
| **註冊 register 屬性**       | 包含 address、大小、reset 值、讀寫權限（RW/RO）等           |
| **名稱與位址綁定**              | 可用 `.write("en_reg", value)` 來操作，不需用地址       |
| **保留 shadow copy**       | 每個 reg 實例會保有預期值，可做比對                         |
| **支援多 address map**      | 適用於 multi-interface case，例如 AXI vs. APB      |
| **支援 register coverage** | 可整合 covergroup 追蹤 register 的使用情況             |
| **模組化/可重複使用**            | reg block 可直接帶入到不同專案中                        |

🧠 你可以這樣想：
UVM register model 讓你不用自己去記每個 register 在哪裡、初始值是什麼，也不用自己寫 checker 去比對結果。你只要：
- 在 uvm_reg_block 寫好 reg 架構
- 在 uvm_reg_adapter 連結 reg model 與 bus UVC
- 用 .read() / .write() 和 .mirror() 自動做驗證
---

# Address Map
## 💡 什麼是 Address Map？
![image](https://github.com/user-attachments/assets/5b18ed9c-b186-4427-95f3-039469266adb)
是一個用來表示 某個介面 (interface) 如何看到 register address 的映射結構。
一個 register 可以被 不同的介面（UVC）以不同位址存取。

## 🔁 為什麼要有多個 Address Map？
當 DUT 有多個 bus 介面（如 UVC1 與 UVC2）都能控制 registers。
每個介面可能有自己的 base address 和地址編排。
同一個 register（如 reg1）可能在 map1 是 0x040，在 map2 是 0x050。

## 🧩 重點整理：
✅ 每個介面都有`對應的 address map`。  
✅ reg1 可以同時存在於多個 map 中（不同地址）。
e.g.   
```systemverilog
reg1.write(status, data, UVM_FRONTDOOR, map1); // 指定使用 map1
```  
✅ 如果只有一個 map，預設名稱叫 default_map。  
✅ 如果 register 存在於多個 map，執行 .write() 或 .read() 時就要明確指定 map 名稱。  

---
# Register Model自動產生
1. 手動建立 register model 很麻煩  
Register 可能有數千個。
每個 register 的設定錯誤容易出錯，還會有很多程式碼依賴（dependencies）。  
2. 可以從 register 規格自動產生 register model  
根據規格輸入（如 XML、Excel、IP-XACT 等）自動生成。
這樣一來，如果規格變動，model 也能快速更新，不用重新手刻。  
3. 支援多種格式  
標準格式：IEEE 1685 IP-XACT（基於 XML）。
也支援一些非標準或客製格式（例如 Excel-based 的 spec）。  
4. 使用工具自動產生 Model  
利用 “Model Generator” 工具，輸入 spec，自動輸出 uvm_reg_block、uvm_reg、uvm_reg_field 等類別。

註: ✅ IP-XACT 是什麼？
IP-XACT 是由 IEEE 定義的標準（IEEE 1685），用來描述 IP（Intellectual Property）元件的資料，特別是：
- 寄存器（registers）
- 記憶體（memory maps）
- 位元欄位（fields）
- 模組介面等

主要用途是：
自動產生 RTL、驗證用的 Register Model（如 UVM RAL）
支援工具間的 IP reuse 與整合，格式為 XML，可供第三方工具讀寫與轉換

---
# Cadence - Register Model Generator - reg_verifier
🔧 功能說明：reg_verifier
✅ 輸入（Input）
IP-XACT XML 檔案
遵循 IEEE 1685 標準
可包含 Cadence 專屬的 extension（例如 backdoor path）

🔍 驗證（Validation）
自動檢查 XML 結構是否符合 IP-XACT 規範
有錯誤會提醒，防止你用錯格式或漏欄位

🧾 輸出（Output）
產生一套 UVM Register Model
如：class addr0_cnt_reg_c extends cdns_uvm_reg 等 code
可以馬上拿去跑簡單的測試（快速驗證）

## 如何使用reg_verifier?
```bash
reg_verifier -domain uvmreg -top <IP-XACT file> -dut_name <model name> [options]
```

🔑 常用選項 (Options)
| 選項                   | 功能說明                                                                   |
| -------------------- | ---------------------------------------------------------------------- |
| `-target_dir <name>` | 指定產生的檔案要放到哪個資料夾中                                                       |
| `-out_file <name>`   | 指定產出的 SystemVerilog 檔名                                                 |
| `-pkg <name>`        | 指定產生的 SV package 名稱                                                    |
| `-quicktest`         | 自動建立一個簡易的 testbench 來驗證 register model                                 |
| `-cov`               | 在產生的 register model 中啟用 coverage 功能（需配合 IP-XACT 有寫 coverage extension） |

---

# 理解Register Model & Address Map Prints
![image](https://github.com/user-attachments/assets/ef907296-6216-42ed-adfc-6e73db2a3ee8)

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


# 驗證register的流程如下
![image](https://github.com/user-attachments/assets/088a009b-e0d4-4f29-9032-37828ec39055)

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


## 3. 建立adapter
Adapter 的角色是：把 RAL 的讀寫請求，轉成 bus protocol 的 transaction，也就是連結 RAL 與 Bus UVC 的橋樑。
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

# Register API Access Methods
![image](https://github.com/user-attachments/assets/2671798e-d67b-422d-908e-b4503e6be9a8)  
![image](https://github.com/user-attachments/assets/a909abe3-8ce9-4dc4-9106-8beedad39ae5)


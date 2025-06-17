# 目標
使用virtual interface，把driver, monitor連接上dut ports



---

# 1. Interface的compile
- 一個interface，在uvm架構裡面做compile時，必須加入pkg中
- ![image](https://github.com/user-attachments/assets/7ede8f8d-f06a-4502-bc2e-299b8764171a)

# 2. Interface連接UVM driver/monitor
- uvm component不可直接連接實例的interface => 會破壞reusability / interface實例是靜態的
- 所以必須使用virtual interface做連接
```systemverilog
virtual interface <if_name> <local_name>
```

# 3. 使用transaction recording
這是一個非常實用的 debug 工具，讓你可以在波形圖中看到高階資料物件（例如封包 packet），而不只是底層的訊號波形。
## 範例
![image](https://github.com/user-attachments/assets/0714aa5a-781d-4308-a1a6-0fc3e2e7a6a9)
## 解釋
![image](https://github.com/user-attachments/assets/4915e339-665c-4091-ac33-3ea9ae4c7773)  
📷 模擬結果
在 waveform 中會看到：
一個時間軸上的方塊，代表該 transaction 的存在時間。
點開可以看到封包的 payload、地址、delay、parity 等欄位資訊。

# 4. 介紹各檔案的top modules
## tb_top
✅ import uvm_pkg::*：匯入 UVM 所需的所有 class。  
✅ import yapp_pkg::*：自訂封裝的驗證 component。  
✅ run_test()：啟動整個 UVM 測試流程。  
✅ connect interfaces：會在 initial block 中用 uvm_config_db::set() 把實體 interface 傳給 driver 等 UVM 元件。  
![image](https://github.com/user-attachments/assets/4d70b120-9f00-410a-8471-2a21ee340805)

### 如何在tb_top做設定
```systemverilog
//輸入要帶virtual interface
uvm_config_db#(virtual interface yapp_if)::set(
    null,                                // context（模組層一定要是 null），因為不是一個物件
    "uvm_test_top.tb.yapp.*",           // instance name（可以使用萬用字元 *）
    "vif",                               // 欄位名稱（field name）
    hw_top.in0                           // 要傳遞的 interface 實體
);
```
![image](https://github.com/user-attachments/assets/3ecfe269-25ab-401e-a12e-169c073bc094)  
註1: 這個測試環境的階層長這樣，路徑才會是uvm_test_top.tb.yapp.*  
✅ 為什麼不用設到 driver/monitor？  
因為：driver 和 monitor 都有一個成員變數叫 vif  
如果你用 "uvm_test_top.tb.yapp.*" 搭配萬用字元 *，UVM config DB 會自動找出所有符合路徑的子 component 中有vif的並設定，所以這個用法是"對agent底下元件設值"  


註2: 做了set之後還得在driver/monitor中的connect phase做get
![image](https://github.com/user-attachments/assets/f6f5c3f5-37d9-4dd6-a8bc-6f6d0cf302fb)  
問: 為什麼是在connect phase做  
![image](https://github.com/user-attachments/assets/1c1e531b-7658-41c7-8b31-1c1de771cdd4)  


註3: 建議使用typedef包住uvm_config_db#(...)
uvm_config_db 是一個 template（泛型）class，對 type 非常敏感。  
如果 set() 和 get() 的 type 不一致（例如少了 virtual 關鍵字或用了不同的 interface 名），就會導致配置失敗。所以建議將 uvm_config_db#(virtual yapp_if) 透過 typedef 命名為一個通用的型別名稱。  
![image](https://github.com/user-attachments/assets/73c4d8d4-b5a6-452c-9032-13f6affe0244)


## hw_top
✅ 宣告並實體化 interface，如 yapp_if in0(clock, reset);  
✅ 將 interface 的訊號接到 DUT（例如 router）的 port 上  
✅ 也會宣告其他硬體模組（如 clock generator）  
❌ 不包含 run_test()（這部分是在軟體端執行）  
![image](https://github.com/user-attachments/assets/d1dc415e-c0b9-446f-9010-5d056494c535)

## 統整
![image](https://github.com/user-attachments/assets/59413ab3-ca34-4ae6-a14c-40ab793b7aa3)

# 5. Vif的限制與解法
1. Vif不能寫資料到wire
2. 但是DUT的inout都要接wire

## 解決方案
✅ 解決方法：用兩個訊號代表同一條線
以範例中的 hdata 為例：
在 interface 中：
```systemverilog
interface hbus_if (...);
    logic        hen, hwr_rd;
    logic  [7:0] haddr;

    wire   [7:0] hdata_w;  // 給 DUT 用，接 inout port
    logic  [7:0] hdata;    // 給 UVM driver 用，可以用在程序中
    ...
    assign hdata_w = hdata;  // 用 assign 將 hdata 值推到 hdata_w 上
endinterface
```
✅ 實務建議
所有 bidirectional 或 tri-state port，interface 中都應該拆成一組 logic + wire 配 assign  
驅動端（driver）用 logic；讀取端（monitor）可從 wire 讀  
在 interface 裡面橋接：assign w = l 或更進階用 tri-state control  


# 6. 用法步驟總結
1. 在if.sv中宣告好interface該有的訊號
2. 在file list要加入寫好的if.sv來compile
3. 在hw_top中宣告interface的instance  
4. 在test level使用config_db做set動作，路徑設定是test.env.agent.`*`，如果有多個agent要設定vif，可以改成test.env.`*`    
5. 路徑設定好後，名稱給"vif"，值要給instance的路徑，e.g. hw_top.if1  


assign_vi好像只有宣告並沒有呼叫

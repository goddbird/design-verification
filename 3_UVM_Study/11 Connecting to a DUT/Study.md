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
uvm_config_db#(virtual yapp_if)::set(
    null,                                // context（模組層一定要是 null）
    "uvm_test_top.tb.yapp.*",           // instance name（可以使用萬用字元 *）
    "vif",                               // 欄位名稱（field name）
    hw_top.in0                           // 要傳遞的 interface 實體
);
```
註: 這個測試環境的階層長這樣，路徑才會是uvm_test_top.tb.yapp.*
![image](https://github.com/user-attachments/assets/3ecfe269-25ab-401e-a12e-169c073bc094)



## hw_top
✅ 宣告並實體化 interface，如 yapp_if in0(clock, reset);  
✅ 將 interface 的訊號接到 DUT（例如 router）的 port 上  
✅ 也會宣告其他硬體模組（如 clock generator）  
❌ 不包含 run_test()（這部分是在軟體端執行）  
![image](https://github.com/user-attachments/assets/d1dc415e-c0b9-446f-9010-5d056494c535)

## 統整
![image](https://github.com/user-attachments/assets/59413ab3-ca34-4ae6-a14c-40ab793b7aa3)

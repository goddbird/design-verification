# 創建簡單的UVC
![image](https://github.com/user-attachments/assets/be085cae-9a75-452c-b212-6543d2b38084)  

1. 創建一個driver / sequencer / monitor
2. 創建一個agent去build出driver / sequencer / monitor
3. 封裝所有的component進UVC top level
4. 使用build, connect方法，創建&連接hierarchy
5. 在tb實例化UVC
6. 產生出一個packet & 檢查log file

## 摘要(初版)😒
|top|sequence|agent|
|---|---|---|
|![image](https://github.com/user-attachments/assets/af022400-be8a-41f8-b2e0-07746cbdcc62)|![image](https://github.com/user-attachments/assets/e2070ac3-d0c1-4a3c-b928-649bfe898c57)|![image](https://github.com/user-attachments/assets/aeef0ea6-78ab-4d65-b8fc-28de7a94ff3d)|![image](https://github.com/user-attachments/assets/122d9022-687b-44ef-b411-40089f5fd163)|
|1. 宣告agent<br>2. build_phase(set default seq)<br>3. topology|1. 定義body來傳送transaction|1. 宣告seqr/driver<br>2. build_phase<br>3. connect_phase|


|seqr|driver|monitor|
|---|---|---|
|![image](https://github.com/user-attachments/assets/122d9022-687b-44ef-b411-40089f5fd163)|![image](https://github.com/user-attachments/assets/8133991b-1a39-45a0-b91b-a89c72745ccb)|![image](https://github.com/user-attachments/assets/da7763c0-525d-41a9-a566-3db0166cf7c3)|
|x|1. task run_phase<br>2. send_to_dut||

## 修正版❤️
`很重要的` uvm_config_wrapper在指定sequencer路徑的時候，其實很容易寫錯，要確認的話就是在sequencer的build_phase裡面加入`uvm_info(get_type_name(), $sformatf("My path is %s", get_full_name()), UVM_NONE)
![image](https://github.com/user-attachments/assets/2ffd5864-8894-4ad2-862a-813b9df8b911)



|top|sequence|agent|
|---|---|---|
|![image](https://github.com/user-attachments/assets/af022400-be8a-41f8-b2e0-07746cbdcc62)|![image](https://github.com/user-attachments/assets/e2070ac3-d0c1-4a3c-b928-649bfe898c57)|![image](https://github.com/user-attachments/assets/aeef0ea6-78ab-4d65-b8fc-28de7a94ff3d)|![image](https://github.com/user-attachments/assets/122d9022-687b-44ef-b411-40089f5fd163)|
|1. 宣告agent<br>2. build_phase(set default seq)<br>3. topology|1. 定義body來傳送transaction|1. 宣告seqr/driver<br>2. build_phase<br>3. connect_phase|


|seqr|driver|monitor|
|---|---|---|
|![image](https://github.com/user-attachments/assets/122d9022-687b-44ef-b411-40089f5fd163)|![image](https://github.com/user-attachments/assets/8133991b-1a39-45a0-b91b-a89c72745ccb)|![image](https://github.com/user-attachments/assets/da7763c0-525d-41a9-a566-3db0166cf7c3)|
|x|1. task run_phase<br>2. send_to_dut||


## 錯誤狀況

1.
因為不知道加入的driver有沒有build過<br>想要使用topology確認  
|錯誤訊息|Code|改善方式|
|---|---|---|
|![image](https://github.com/user-attachments/assets/8628f955-4b7d-4256-86c0-1c47a181e659)|![image](https://github.com/user-attachments/assets/6b5bc390-3081-4fee-950a-85089822e601)|把原本的module改成class，然後在module裡面run_test，會尋找名為my_test的class![image](https://github.com/user-attachments/assets/eafd88d5-976d-4aad-b10e-a82e216d4454)
|

![image](https://github.com/user-attachments/assets/ee1b849e-198f-4b7b-9ed0-1c908bcefa94)
![image](https://github.com/user-attachments/assets/7421dabe-775a-49a4-bd27-3e83e3c2a75d)  
這樣看起來就有driver了。
但是有個error message: *E, TRNULID: NULL pointer dereference  
Scope: worklib.uvm_pkg::uvm_seq_item_pull_port#(yapp_packet)::get_next_item
看起來是想拿item，但沒辦法拿，問了gpt是要先寫sequencer


|錯誤訊息|Code|改善方式|
|---|---|---|
|![image](https://github.com/user-attachments/assets/ffc4b22d-e203-4d40-bd4f-9896aed150f6)|看起來有成功印出topology!且seqr & driver都有顯示[image](https://github.com/user-attachments/assets/fe83079a-5485-40ea-811e-0f9f1cd935da)||




## 問題集
1. 為什麼agent裡 build_phase 要先呼叫 super.build_phase(phase);？
因為這是 UVM 架構規定：
在 component 的 build_phase() 中，你要在建立子 component 前先呼叫父類別的 build_phase()，目的是：

✅ 目的 1：讓 UVM 的內部機制先初始化完成
super.build_phase() 會建立很多必要的 UVM 元件內部機制（像是 config、resource、factory）
如果你沒先呼叫它，有些 UVM 的功能像 uvm_config_db 或 factory override 可能無法正確運作
✅ 目的 2：遵循正確的 UVM phase 呼叫順序
UVM framework 會自動依照 hierarchy 呼叫每個 component 的 build_phase()
→ super.build_phase() 保證你是 延續上層的 phase 行為，不中斷整個架構
✅ 目的 3：避免錯誤或難 trace 的行為
如果你先 create 物件，再呼叫 super.build_phase()
父類別有可能會 override 或干擾你剛剛 new 出來的東西
導致 debug 非常困難（特別是在大型 testbench）

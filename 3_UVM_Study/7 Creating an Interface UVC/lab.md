# 創建簡單的UVC
![image](https://github.com/user-attachments/assets/be085cae-9a75-452c-b212-6543d2b38084)  

1. 創建一個driver / sequencer / monitor
2. 創建一個agent去build出driver / sequencer / monitor
3. 封裝所有的component進UVC top level
4. 使用build, connect方法，創建&連接hierarchy
5. 在tb實例化UVC
6. 產生出一個packet & 檢查log file

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
|![image](https://github.com/user-attachments/assets/ffc4b22d-e203-4d40-bd4f-9896aed150f6)|看起來有成功印出topology![image](https://github.com/user-attachments/assets/fe83079a-5485-40ea-811e-0f9f1cd935da)||

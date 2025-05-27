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

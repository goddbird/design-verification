![image](https://github.com/user-attachments/assets/be085cae-9a75-452c-b212-6543d2b38084)  
創建簡單的UVC
1. 創建一個driver / sequencer / monitor
2. 創建一個agent去build出driver / sequencer / monitor
3. 封裝所有的component進UVC top level
4. 使用build, connect方法，創建&連接hierarchy
5. 在tb實例化UVC
6. 產生出一個packet & 檢查log file

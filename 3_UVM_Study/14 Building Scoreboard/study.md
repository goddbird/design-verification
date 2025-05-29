# 介紹
 
1. 創建一個scoreboard
2. 實例 & 連接一個TLM的interface，用來從UVC傳送packet資訊到scoreboard
3. 宣告scoreboard的clone/compare操作

---
 
## 📌 內容重點
1. 為什麼需要ScoreBoard?  
A: 用來驗證 DUT 是否正確處理封包的核心元件，它從 YAPP 和 Channel 的 monitor 收集封包，進行輸入/輸出比對，必要時也可以分析 HBUS 資料，並考慮異常狀況。  

2. ScoreBoard組成的要素  
A: Ref model (Golden Model) / storage (暫存預測資料) /  Checking logic (比對)  

3. ScoreBoard如何收資料  
![image](https://github.com/user-attachments/assets/83e7b292-f443-4986-a2e8-5f8a661bbab7)  
A: YAPP UVC的agent裡面會有monitor，他會收到來自DUT的封包，再把封包傳給scoreboard
會透過TLM機制傳遞analysis port(Monitor發) / analysis port imp(ScoreBoard收)。  
connect phase會在env/test中完成
一個ap可以接多個imp，但一個imp只能接一個ap  
![image](https://github.com/user-attachments/assets/7ca3d099-060c-4ee9-aca2-fede89299ec9)  


5. Write function機制
A: Scoreboard會定義write function，而monitor會call write function並帶入transaction做輸入，來表示傳送transaction

|monitor|scoreboard|
|---|---|
|![image](https://github.com/user-attachments/assets/ad8eb952-a4b4-45d0-a8ea-5ec7da1983ac)|![image](https://github.com/user-attachments/assets/931e47d9-5bcb-4d3d-84f0-b115d3ba0261)|

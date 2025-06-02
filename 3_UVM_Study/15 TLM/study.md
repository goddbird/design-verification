# 目標
 
1. 使用Transaction Level Modeling
2. 選擇TLM連接的種類
3. 實例化 & 連接TLM interface
4. 使用TLM FIFO創建scoreboard

---
 
## Data & Control Flow
1. 為什麼需要ScoreBoard?  
A: 用來驗證 DUT 是否正確處理封包的核心元件，它從 YAPP 和 Channel 的 monitor 收集封包，進行輸入/輸出比對，必要時也可以分析 HBUS 資料，並考慮異常狀況。  

2. ScoreBoard組成的要素  
A: Ref model (Golden Model) / storage (暫存預測資料) /  Checking logic (比對)  

# 介紹
 
1. 創建一個scoreboard
2. 實例 & 連接一個TLM的interface，用來從UVC傳送packet資訊到scoreboard
3. 宣告scoreboard的clone/compare操作

---
 
## 📌 內容重點
為什麼需要ScoreBoard?
A: 用來驗證 DUT 是否正確處理封包的核心元件，它從 YAPP 和 Channel 的 monitor 收集封包，進行輸入/輸出比對，必要時也可以分析 HBUS 資料，並考慮異常狀況。

🎯 實務上的重要結論
虛擬 sequence 的必要性，來自「要跨多個 UVC 同步控制」的需求
不是所有 UVC 都要掛進虛擬 sequencer！
如果某個 UVC 只跑一條固定 sequence 或只負責 response，就不需要特別控制


### 一、如何建立Multichannel Sequencer/Sequence

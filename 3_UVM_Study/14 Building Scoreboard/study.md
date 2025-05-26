# 介紹
 
1. 創建一個scoreboard
2. 實例 & 連接一個TLM的interface，用來從UVC傳送packet資訊到scoreboard
3. 宣告scoreboard的clone/compare操作


一開始業界習慣把控制多個UVC的sequencer/sequence叫做virtual sequencer, virtual sequence，但因為virtual早有定義，所以這個名字會很混淆
現在IEEE 1800.2改術語叫做multichannel sequencer

---
 
## 📌 內容重點
為什麼需要UVC multichannel sequence?  
A: 讓一個上層sequence，能啟動多個sequence，讓不同個sequencer使用
1. 需要跨多個UVC同步行為 e.g. 一邊送AXI、一邊觀察APB
2. 將資料分配到多個input port

🎯 實務上的重要結論
虛擬 sequence 的必要性，來自「要跨多個 UVC 同步控制」的需求
不是所有 UVC 都要掛進虛擬 sequencer！
如果某個 UVC 只跑一條固定 sequence 或只負責 response，就不需要特別控制


### 一、如何建立Multichannel Sequencer/Sequence

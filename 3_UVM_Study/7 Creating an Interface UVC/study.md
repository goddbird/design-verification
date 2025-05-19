# 介紹
 
1. 介紹 UVC 的架構  
2. 介紹 Sequencer 和 Driver 如何透過 TLM interface 進行資料傳遞  
3. 定義 UVC 的資料欄位 Layout  
 
---
 
## 📌 內容重點
 
### 一、介紹 UVC 的架構
 
#### 1. UVC 架構說明
 
- **UVC** (*Universal Verification Component*)：  
  整體的驗證元件，可以包含一個或多個 `agent`
 
- **Agent**：  
  UVC 的子單位，包含：
  - `sequencer`
  - `driver`
  - `monitor`
 
  類型區分為：
  - **active agent**：會主動送 stimulus  
  - **passive agent**：只監控訊號，不送 stimulus（例如 sniffer）
 
---
 
#### 2. 各子元件說明
 
- **Sequencer**：
  - 負責產生 `sequence`
  - 管理 arbitration
  - 經由 `TLM interface` 把下一筆 `transaction` 傳給 `driver`
 
- **Driver**：
  - 根據 `sequencer` 給的資料
  - 用正確的時序 drive 到 DUT
  - 接上 `virtual interface`  
  - 資料驅動完成後，會回報 `sequencer`，讓它送下一筆資料
 
- **Monitor**：
  - 從 DUT 的 `virtual interface` 擷取訊號
  - 屬於**被動監控**，不影響 DUT 行為
  - 觀察 transaction 並轉換成 `object`，再送給：
    - `scoreboard`
    - `coverage`
    - `reference model`
 
- **TLM Port/Export**：
  - 提供一組方法，如：
    - `get_next_item()`
    - `item_done()`
  - 來實作元件間的連線與溝通
 
---
#### 2. 介紹sequencer和driver如何透過TLM介面進行資料傳遞
- **sequencer**
  - **get_next_item()**
    - driver使用這個函式從sequencer抓下一筆資料

# 目標
1. 建立uvm sequence，使用UVM macros & methods建立stimulus
2. 定義sequencer該執行哪些sequence
3. 使用UVM objection mechanism控制simulation結尾


---

## 1. 介紹Sequence

### 一、什麼是Sequence?
- 是Transaction的集合，並會傳送給DUT
- 為什麼需要sequence? 通常test會在transaction level進行，但僅憑單一transaction無法應用high level測試，需要一連串有順序的transaction才能達成
- Sequence應該被設計成reusable，方便其他驗證者延伸 or reuse

### 二、Sequence架構
![image](https://github.com/user-attachments/assets/d2ebc401-d307-4c12-9dc0-ec75b51d8c37)
1. 宣告 : 從uvm_sequence extends來的，transaction type必須指定為yapp_packet
2. 註冊 : 使用`uvm_object_utils(<class name>)
3. constructor : 使用new，但只有指定name
4. body : 在圖中的uvm_info是用來print message用的，這是sequence的主要流程，uvm_do是常用的UVM巨集，`用來產生&送出transaction`，第一筆是隨機packet : uvm_do(req)，第二筆是強制addr == 0
![image](https://github.com/user-attachments/assets/e80c6ee9-108b-406a-8eec-67a5787454f8)

### 三、uvm_do
摘要，實際運作了哪些流程 :
1. create : 用factory自動分配建立req，也就是transaction item
2. Wait : sequencer等driver說需要資料了才送
3. Randomize : 會與class內的constraint結合
4. Transfer : sequencer把item傳給driver的seq_item_port
5. Wait done : sequencer會等driver呼叫`item_done()`才繼續往下執行

實際運行流程 : 
![image](https://github.com/user-attachments/assets/21217e0a-f122-4772-aa88-9d165d398e18)
|步驟|名稱|說明|對應方法|
|---|---|---|---|
|1️⃣|	creation|	使用 factory 建立 transaction 實例，設定 parent 與 sequencer|	create()
|2️⃣|	synchronize|	等待 sequencer 發出 get_next_item() 請求（表示 driver 需要 item）|	start_item()
|3️⃣|pre_do hook|	呼叫 pre_do() 方法（可以客製化行為）|	—
|4️⃣|	randomization|	對 item 做隨機化，若失敗會發出警告	|randomize()
|5️⃣|	mid_do hook|	隨機化後，送出前可在此進一步修改 item|	—
|6️⃣|	send & wait|	將 item 傳給 driver，並等待執行結束|	finish_item()
|7️⃣|	post_do hook|	driver 執行結束後呼叫，可作為後處理|	—

🔹 pre_do(bit is_item)
在 隨機化之前執行

通常用於：初始化欄位、清除前一筆資料等

⚠ 注意：這是 task，若執行時間過久會影響 TLM 時序

🔹 mid_do(uvm_sequence_item this_item)
在 randomize 之後、送出之前 執行

可用來：檢查隨機結果、加註時間戳、改變某些欄位內容

🔹 post_do(uvm_sequence_item this_item)
在 item_done() 被 driver 呼叫之後 執行

可用來：記錄 log、統計 coverage、清除 temporary data

### 三、explicit flow (取代uvm_do)
使用 uvm_do 巨集雖然簡潔，但有時候你可能會希望在每個步驟中插入客製邏輯，這時就可以用「顯式寫法」來達成同樣的功能，而且控制力更高。
uvm_do優點是一行搞定，但難以客製化流程。但explicit flow可以自己控制。
```systemverilog
virtual task body();
  req = yapp_packet::type_id::create("req");   // 等同於 uvm_do 的 step 1。這邊要注意object不需要傳入this，只有component才要
  start_item(req);                             // 等同於 uvm_do 的 step 2~3
  ok = req.randomize() with {addr == 0;};      // 等同於 uvm_do 的 step 4
  finish_item(req);                            // 等同於 uvm_do 的 step 5~7
endtask
```
![image](https://github.com/user-attachments/assets/23e96801-7101-433c-849d-ad713b7d8b1a)

### 四、Additional `uvm_do Macros
|巨集名稱|執行步驟|特性說明|使用時機|
|---|---|---|---|
|`uvm_do(req)|步驟 1 ~ 7（全部）|最完整，一鍵完成建立、隨機化、傳送與完成等待|要求快速完成transaction流程|
|`uvm_do_with(req, {...})|	步驟 1 ~ 7（全部），但加上 inline 條件|加入額外條件限制的版本（randomize with {}）|要求快速完成交易流程|
|`uvm_create(req)|只做步驟 1（建立）|可以之後手動控制送出或隨機化|想手動插入前處理邏輯、或避免隨機化|
|`uvm_send(req)|步驟 2 ~ 3, 5 ~ 7（不做 randomize）|已手動完成 randomize 或資料固定時使用|想手動插入前處理邏輯、或避免隨機化|
|`uvm_rand_send(req)|步驟 2 ~ 7（含 randomize）|若你已手動建立 req，可以用這個送出|自己處理 randomize，但仍需 sequencer 管理送出與等待|
|`uvm_rand_send_with(req, {...})|步驟 2 ~ 7，且帶限制條件|手動建立 + 附加隨機條件送出|想結合手動建立 + 隨機限制|

實際語法使用:
範例1.
```systemverilog
`uvm_do(req)
`uvm_do_with(req, {addr == 0;})

`uvm_create(req)
`uvm_send(req)

`uvm_rand_send(req)
`uvm_rand_send_with(req, {addr inside {[0:15]};})
```

範例2.
![image](https://github.com/user-attachments/assets/2d50c2d1-09b2-4eb5-8947-d1b97fbbfccb)

---
## 2. 定義Sequencer中的sequence執行
要如何決定run哪些Sequence / 什麼時候跑sequence?
1. run phase有default_sequence
2. 使用test class來執行
3. 使用Sequence library

### 1. Run Phase Default Sequence
使用uvm_config_wrapper (這在ch7有介紹過，設定sequence到某個sequencer的phase)
1. default_sequence是讓sequence自動在某個phase被執行的設定方法
2. 透過uvm_config_db或uvm_config_wrapper設定
3. 可以指定phase : main_phase、run_phase、reset_phase
4. 通常在test level (上層level)設定於build phase
![image](https://github.com/user-attachments/assets/72275dbf-d487-4409-beb7-ca01bd5343ab)




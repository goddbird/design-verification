# 目標
1. 建立uvm sequence，使用UVM macros & methods建立stimulus
2. 定義sequencer該執行哪些sequence
3. 說明 UVM 模擬結束的機制：Objection（異議）機制


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
3. constructor : 使用new，`但只有指定name`
4. body : 在圖中的uvm_info是用來print message用的，這是sequence的主要流程，uvm_do是常用的UVM巨集，`用來產生&送出transaction`，第一筆是隨機packet : uvm_do(req)，第二筆是強制addr == 0
![image](https://github.com/user-attachments/assets/e80c6ee9-108b-406a-8eec-67a5787454f8)

### 三、uvm_do
摘要，實際運作了哪些流程 :
1. create : 用factory自動分配建立req，也就是transaction item。
2. Wait : sequencer等driver說需要資料了才送
3. Randomize : 會與class內的constraint結合
4. Transfer : sequencer把item傳給driver的seq_item_port
5. Wait done : sequencer會等driver呼叫`item_done()`才繼續往下執行

*如何檢查sequence打出去的內容 req.sprint()
![image](https://github.com/user-attachments/assets/04de385f-745d-4553-a055-c886bcd7ac7a)


實際運行流程 : 
![image](https://github.com/user-attachments/assets/21217e0a-f122-4772-aa88-9d165d398e18)
|步驟|名稱|說明|對應方法|
|---|---|---|---|
|1️⃣|	creation|	使用 factory 建立 transaction 實例，設定 parent 與 sequencer|	`create()`
|2️⃣|	synchronize|	等待 sequencer 發出 get_next_item() 請求（表示 driver 需要 item）|	`start_item()`
|3️⃣|pre_do hook|	呼叫 pre_do() 方法（可以客製化行為）|	通常會raise objection
|4️⃣|	randomization|	對 item 做隨機化`是針對transaction裏面的變數做rand，不會針對sequence內的變數做rand`，若失敗會發出警告	|`randomize()`
|5️⃣|	mid_do hook|	隨機化後，送出前可在此進一步修改 item|	—
|6️⃣|	send & wait|	將 item 傳給 driver，並等待執行結束|	`finish_item()`
|7️⃣|	post_do hook|	driver 執行結束後呼叫，可作為後處理|	通常會drop objection

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
|`uvm_do_with(req, {...})|	步驟 1 ~ 7（全部），但加上 `constraint 條件`|加入額外條件限制的版本（randomize with {}）|要求快速完成交易流程|
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
使用uvm_config_wrapper (這在ch7有介紹過，設定sequence到某個sequencer的phase)，會讓一個特定sequence自動在某個phase啟動，如此一來不用手動呼叫start() / start_item()
1. default_sequence是讓sequence自動在某個phase被執行的設定方法
2. 透過uvm_config_db或uvm_config_wrapper設定
3. 可以指定phase : main_phase、run_phase、reset_phase
4. 通常在test level (上層level)設定於build phase
![image](https://github.com/user-attachments/assets/72275dbf-d487-4409-beb7-ca01bd5343ab)

註: 
1. uvm_config_wrapper是透過`typedef uvm_config_db#(uvm_object_wrapper) uvm_config_wrapper;` 來的
2. 若有使用uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)，就會在super.build_phase後自動更新is_active變數，不需要get


### 2. 使用test class來執行Sequence
1. 需要test class裡面create，會在build phase階段生成sequence，`需傳入Parent讓config_db可以作用，儘管是object`
2. connect phase必須連接sequencer的handle
3. run phase必須讓指定的sequence start起來，seq.start(seqr)
![image](https://github.com/user-attachments/assets/7bc0b42b-7884-4665-9bfc-6a576d1a8136)

## 補充
小馬說 : 此種test class手動啟動sequence的方法，可以指定在某一phase(比如main phase)，然後再打sequence，會比default sequence更有彈性

|default sequence| test class|
|---|---|
|![image](https://github.com/user-attachments/assets/dd867f9d-f2ca-4191-9659-b2d458eec40d)|![image](https://github.com/user-attachments/assets/7dfb8619-79e9-4d54-943a-99a2450378f2)|

//以下可刪
1. 一定要在test level才能宣告seqr, seq? 不能在env先宣告?
A: Sequencer會放agent/env中，作為component結構的一部分。sequence會放在test或virtual sequence中  
2. create sequence一定得在super.build_phase前嗎? 為什麼?
A: super.build_phase() 可能會做 config_db::set()
UVM 的建構順序是 由上而下、由 test 去建 env，再建 agent，再建 sequencer...
在某些層級的 component（如 base_test 或 env）裡，可能會使用 uvm_config_db::set() 去傳遞設定給 sequence。
若你在 super.build_phase() 之後才 create() 你的 sequence，那麼那些 config 設定早就已經完成，但你的 sequence 還沒建立，自然也無法接收到這些設定。
3. 為什麼直到connect_phase在要把sequencer的handle指定好，而不是在build_phase就指定好?
A: UVM 架構設計上就是希望「所有 handle 指定與連接動作」放在 connect_phase 處理。
4. 所以在run_phase還得指定sequence做randomize，可以不做randomize然後讓sequence裡面自己跑body，讓他randomize就好?
A: 是的，你可以不在 run_phase 手動 randomize()，讓 sequence 裡的 body() 自己跑 randomize() 是可行的，前提是你在 body() 中真的有寫 randomize() 的邏輯。
5. 請問一個seqr，可以同時設定default sequence & 用sequence.start來跑嗎?  
A: 
![image](https://github.com/user-attachments/assets/aa779af5-45e7-48ec-a835-0c718ae07b85)



## 3. 說明 UVM 模擬結束的機制：Objection（異議）機制
Objecttion是一個UVM的同步控制機制，用來決定該不該結束一個Run Phase

下圖說明
raise：sequence 開始，阻止 run_phase 結束
drop：sequence 執行完，放手讓 run phase 可以結束
drain time：最後一個 drop 後會等一小段時間（可設）再結束
stop called：UVM 開始準備結束
stop executed：真的關閉模擬

示意圖
![image](https://github.com/user-attachments/assets/85390075-4be2-42a7-813a-e4422468a1e7)

## 3.1 Objection語法 (objection method)
```systemverilog
raise_objection(<object>, <description>, <count>);
drop_objection(<object>, <description>, <count>);
```
*description是一種string，用來trace & debug

### 1. Objection handling
目前有三種方式執行objection handling
1. test class handle `(讓run phase來raise/drop)`
2. default sequence `(讓sequence的body來raise/drop)`
3. another sequence

#### 1. test class objection
test objection，會在`run phase`裡面使用objection method
![image](https://github.com/user-attachments/assets/e7b92e5d-0a8c-42dd-bc44-40bfc39abc07)

#### 2. Sequence objection
sequence objection，會在body()裡面使用，會搭配starting_phase來使用
會確認starting_phase是否為null? 如果sequence是由test執行的(seq.start())，starting_phase就會為null，就無法在sequence內使用objection。
如果是用uvm_config_db::set，這種就是default sequence，就不會是null。  
![image](https://github.com/user-attachments/assets/0c65c752-e298-43f3-9cf7-6ca7c122741d)



使用範例: 注意不是所有Sequence都要raise objection
```systemverilog
task body();
  `uvm_info("SEQ", "Start", UVM_LOW);
  starting_phase.raise_objection(this);

  repeat (10) `uvm_do(req);

  starting_phase.drop_objection(this);
  `uvm_info("SEQ", "Finished", UVM_LOW);
endtask
```

#### 3. Efficient Sequence Objections
在Pre/Post body使用Objection，統一處理objection

#### 4. 注意
raise objection不能加入消耗模擬時間的敘述，否則有可能無法起作用
![image](https://github.com/user-attachments/assets/d8e62ca0-be0b-43e5-839c-f3b9927db001)


## m_sequencer / p_sequencer
### m_sequencer (my sequencer)
- 可以理解為local sequencer
- 類型為uvm_sequencer_base，定義在uvm_sequence_item中
- 每個sequence中都有一個default變數叫做m_sequence，是一個指向當前sequence的`sequencer`

### p_sequencer (parent sequencer)
- 需要使用uvm_declare_p_sequencer(my_sequencer)，宣告p_sequencer
- 會在sequence裡面指定sequencer的Handle，可以透過那個handle提取sequencer裡的變數

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
### 二、介紹sequencer和driver如何透過TLM介面進行資料傳遞
- a. seqencer (包含TLM export : seq_item_export):
  - i. get_next_item() : driver使用這個函式從sequencer抓下一筆資料。
  - ii. item_done() : driver執行完後告訴sequencer
- b. driver (包含TLM port : seq_item_port) :
  - i. 與seq_item_export連接
  - 呼叫像seq_item_port.get_next_item(), seq_item_port.item_done()這些方法來完成資料流程
![image](https://github.com/user-attachments/assets/d2bdbb03-e2ba-4746-8bcb-a2302af3738e)
---
### 三、介紹Component架構
## Driver

![image](https://github.com/user-attachments/assets/f0c55d58-ace5-406a-8bdc-9f8008bb9942)
yapp_driver從 uvm_driver extends而來，#後面代表要帶的transaction是yapp_packet type。
此driver的component要註冊進factory就要寫`uvm_component_utils(yapp_driver)
new要給名字 & parent class是誰來註冊factory

註 : seq_item_port連接到sequencer，在connect phase做連接。run_phase中，此driver會透過seq_item_port物件中的get_next_item函式來拿到transaction。
後續透過自己在這個class寫的函式send_to_dut來送transaction到DUT，再透過seq_item_port.item_done()，告訴sequencer說driver已經傳完了  
![image](https://github.com/user-attachments/assets/cd2dd08e-8373-4930-9de4-f9ca63c8cf23)

## 整理 Driver 應注意事項：
1. 從 `uvm_driver` extend，`transaction` 要指定好 `req` 的 type（也可以指定 `rsp` type）。
2. 把 driver class 註冊進 factory。
3. `new` 需要符合 component 的輸入（給 `name` 與 `parent`）。
4. 定義好 `run_phase` 該做的事情：
   - 使用 TLM port 的 `get_next_item`、`item_done`
   - 還有自己要送到 DUT 的函式

---
## Sequencer
![image](https://github.com/user-attachments/assets/d49a90a2-f5eb-4e47-b001-50957ea527b5)
在 sequence 與 driver 之間傳遞 transaction。
Stimulus透過sequence產生，透過start(), start_item()傳送transaction到sequencer
上圖的#(yapp_packet)是為了讓sequencer知道transaction是哪一個型別的。

## 整理 Sequencer 應注意事項：
1. 從 `uvm_sequencer` extend，transaction 要指定好 `req` 的 type（sequencer 不需要指定 `rsp` type）。
2. 把 sequencer class 註冊進 factory。
3. `new` 需要符合 component 的輸入（給 `name` 與 `parent`）。
4. Sequencer 本身不用 override `run_phase`。
---	
## Agent
![image](https://github.com/user-attachments/assets/c999974e-5cf3-4358-a21c-a52438ab7a43)
如上圖，這是一個uvm agent，會包含driver, monitor, sequencer
*須注意uvm_agent本身沒有參數化。
有三個子元件，會在build_phase()裡建立，使用create建立，如果is_active是UVM_PASSIVE，就只會建立monitor
*agent的factory註冊還需要end (uvm_component_utils_end)，這個用法類似C的{}
`uvm_component_utils_begin(yapp_agent) 是用來註冊這個class到factory
中間的enum那行代表要把is_active這個欄位加入倒uvm field automation中 *注意is_active在上方註解就已經是列舉型別 (uvm_active_passive_enum) 了，且default value是UVM_ACTIVE
uvm_field算是一種library，裡面擁有很多功能

## 整理 Agent 應注意事項：
1. 從uvm_agent extend，Agent不需要處理transaction的type  
2. 宣告drive, sequencer, monitor handle
3. 把agent class註冊進factory，要注意agent也會處理"is_active"的註冊。
4. new也跟driver, sequencer一樣
5. 要增加build phase : 呼叫super.build_phase，把一開始宣告的handle new一下 : monitor, sequencer, driver (後面這兩個要看is_active的變數值，來決定要不要build)
6. connect phase : 做driver / sequencer的連接
---

## Env
![image](https://github.com/user-attachments/assets/ee1c1df4-e126-4c7c-9482-af696686e195)
env通常會在build_phase()中 : 使用factory建立agent, scoreboard，就跟FIFO的架構一樣。
最後是有個router_tb (top-level testbench)
router_tb是整個測試環境的最上層元件，會在build_phase中實例化yapp_env。

## 整理 Env 應注意事項：
1. 從uvm_env extend
2. 宣告agent handle
3. 把env註冊進factory
4. new自己
5. 要增加build phase : 呼叫super.build_phase，還要create agent

## 整理 Env 應注意事項：
1. 從uvm_env extend (跟env一模一樣)
2. 宣告env handle
3. 要增加build phase : 呼叫super.build_phase

## Sequence
![image](https://github.com/user-attachments/assets/d396bb42-d749-4f21-98ac-0dc4c003fb49)
上圖中的yapp_5_packet，代表這個sequence會產生yapp_packet的transaction，body會使用uvm_do來發送5筆transaction
*必須要確實在test level指定set裡面的path為run_phase，不然無法正確讓sequence動起來

## 統整sequence該定義哪些事情 : 
1. 從uvm_sequence extend，並且需要指定transaction type。
2. uvm_object_utils 註冊此class進factory
3. 需要做new的動作，但只要加入name就好了，不需要parent，因為是object，不是component
4. 要特別加入body function，這是用作產生或傳送transaction內容。
5. 在test的build phase要特別設定default sequence


*會有疑問，一定要寫body嗎?
A : 不一定，但幾乎必要，不需要寫body的情況
宣告一個abstract sequence, base sequence，就不需要寫body

## test
![image](https://github.com/user-attachments/assets/9c59b0e1-e928-4801-81e5-d4131ad90a97)  
uvm_config_wrapper::set的功能，這邊的例子是用來設定uvm default sequence in sequencer  
這個 function 是 UVM 的設定機制的一部分，用來動態設定組件之間的參數。它的用途是：  
📌 功能：
	在特定的 component 上設定一個 key-value 配對，在 simulation 中的某個階段可被讀取使用。
📘 語法說明：

```systemverilog
uvm_config_wrapper::set(
  context,     // 目前在哪個 component 設定，通常設定this
  inst_name,   // 指定的 component path
  field_name,  // 要設定的變數名稱
  value        // 設定的值（可為 object, int, string...）
);
```

---
### 四、其他要注意的事情

1. 什麼是uvm_do?
是一個啟動sequence的語法，包含start_item, randomize, finish_item等步驟。

2. 下圖介紹哪些component需要型別參數化。  
![image](https://github.com/user-attachments/assets/256c8ff6-01b2-4a3b-bbd4-e2056126e3d0)
active元件 (driver / sequence / sequencer) 需要處理transaction，需要知道transaction的型別 : yapp_packet
passive元件不需要知道型別，只要負責控制、建構、連接即可。

3. UVC的目錄應該要包含 : 可重用程式碼 & 不可重用程式碼。架構圖應該要像下圖
![image](https://github.com/user-attachments/assets/2ea19865-6355-4031-a136-fcad0bd0030e)
![image](https://github.com/user-attachments/assets/ad43e900-09f6-479a-8955-2090c7d68898)
![image](https://github.com/user-attachments/assets/2ac9dc0d-954b-4311-bf40-d03ed703d5c5)

4. 介紹實際的sv檔例子 : include的file必須要遵守bottom-up的順序 (從小的build到大的)
![image](https://github.com/user-attachments/assets/f2c41310-988c-47b5-af17-c23825b5e3d5)


# 目標
 
1. 使用Transaction Level Modeling
2. 選擇TLM連接的種類
3. 實例化 & 連接TLM interface
4. 使用TLM FIFO創建scoreboard

--- 
## 介紹
🔷 什麼是 TLM API？
是一種 class 之間通訊的標準機制
由 Open SystemC Initiative (OSCI) 所開發
允許 UVM component 之間 plug-and-play 式的溝通

🔷 UVM 中 TLM 的用途：
UVM 框架內建了 TLM 的實作，可用來在不同元件（例如 driver、monitor、sequencer、scoreboard）之間傳遞資料。

🔎 補充（UVM 常用 TLM 實作）：
uvm_blocking_put_port / uvm_blocking_put_imp → 有阻塞性單向傳輸  
uvm_nonblocking_put_port / uvm_nonblocking_put_imp → 非阻塞單向  
uvm_analysis_port / uvm_analysis_export → 廣播型態，不阻塞  
uvm_tlm_fifo → 內建 FIFO buffer，雙向傳輸  

### Data & Control Flow
Data流向: Producer -> Consumer  
Control流向: Initiator -> Target (看是pull/push mode，get/put)

### Blocking & Nonblocking
傳送transaction可分為這兩種
Blocking: 會消耗時間，使用get/put task
Nonblocking: 不會消耗時間，使用try_get/try_put兩種

### TLM Methods Reference
下表中的種類，都是可以拿來宣告port是哪一種類型的。
|情境|建議方法|
|---|---|
|保證資料傳輸且可以等待|put/get/peek|
|不想被block，須及時處理|try_put/try_get/try_peek|
|只想測試狀態，並不傳送txn|can_put/can_get/can_peek|

`註1: peek是會從fifo或channel中讀出一筆資料，但不會把他移除，後續還是可以用get取出這筆資料`
`註2: 如果你定義的是 uvm_put_imp，你就必須提供 put(), try_put(), 和 can_put() 三個方法的實作，即使實際測試中只用到 put()。
這是 UVM 的接口完整性要求：定義一個接口類型，就要把它的所有方法實作，否則會編譯錯誤或模擬期出錯。`

---
#### 範例
![image](https://github.com/user-attachments/assets/785a2fd7-2a6f-488b-993b-5d7b516b5bdd)  
1. 在initiator裡呼叫port.put(packet);
2. 此put()會透過port->imp的連接傳遞到target
3. target的imp實際會呼叫put function(這個會實作在target裡面)。
4. 如何連接起來的? 在top level or env用producer.port.connect(consumer.imp)

#### 實際的Put例子
|Producer|Consumer|
|---|---|
|![image](https://github.com/user-attachments/assets/819b84f0-6c7c-41ce-8013-c0ad1800e923)|在imp端定義好put的task![image](https://github.com/user-attachments/assets/e0797e85-ae9f-4c14-8144-8c4d88483961)|

#### ENV上的build/connect
上述已經有producer/consumer的class，在env這層做build & connect，都是從port端呼叫connect函式做連接，且imp端當作輸入使用。
![image](https://github.com/user-attachments/assets/73bc7cbc-f8a3-465b-b4f2-cbe070eaef29)

### 用法統整
![image](https://github.com/user-attachments/assets/79d8e892-5fc1-4c03-9cc7-72ab2b6dd07b)  

## TLM 連接的三個重要規則
1. 連接方向
TLM 的連接遵循「資料流的方向」。
所以要從 port 呼叫 .connect()，並傳入 imp 作為參數。
2. 不能有未連接的 port（除了 analysis）
如果有任何 TLM port 沒有被連接，會被視為錯誤（例外是 uvm_analysis）。
3. 一對多 vs 多對一
一個 port 只能連接到一個 imp（一對一）。
但一個 imp 可以接收多個 port 的連接（多對一）。
不允許一個 port 連接多個 imp（一對多），除了 uvm_analysis 的情況可以。
![image](https://github.com/user-attachments/assets/bdfe1a66-46f9-4e6f-8fdb-1338211bde3d)



---
### 單向TLM的Data flow種類
#### A. 一般put/get單向模型
1. consumer主動拉資料 (get model)  producer主動推資料 (put model)

#### B. Analysis Broadcast模型(廣播式)
使用單一uvm_analysis_port + 多個uvm_analysis_imp
資料從port同時傳給多個imp

#### C. 使用TLM FIFO
使用uvm_put_port & uvm_get_port，來提供先進先出的資料流控制

# uvm_tlm_fifo的架構與應用
UVM提供內建的FIFO類別，用來緩衝producer & consumer的transaction資料

## 架構
![image](https://github.com/user-attachments/assets/d7537fc5-b298-41e8-8abf-ac8e982f9573)  
![image](https://github.com/user-attachments/assets/d895b9b7-b06a-44ac-99aa-59a3b22b2b2d)

## TLM FIFO的優缺點
✅ 優點：
不需要自己定義 imp 方法或通訊邏輯。
提供資料緩衝功能（寫入 put → 暫存在 FIFO → 被 get/peek 取出）。
提供許多內建方法來檢查 FIFO 狀態（例如 FIFO 是否為空、是否滿等）。

❌ 缺點：
必須雙向都要接好連接（put 和 get/peek 都要連上），資料傳輸才完整。
相較於普通 port/imp 只要連一次，FIFO 要進行 兩個連接（輸入、輸出）。

#### TLM FIFO的運作機制
|Producer|Consumer|
|---|---|
|宣告uvm_put_port，後續使用put方法![image](https://github.com/user-attachments/assets/1ef6f1e4-ecc0-43bd-94c0-cbb55b275a30)|宣告uvm_get_port，後續使用get方法![image](https://github.com/user-attachments/assets/2b285319-ed9e-479e-863b-dff61a52dc0d)|

## TLM FIFO的配置
🔷 架構圖說明（上方圖）  
Producer（生產者）：
有 send_txn（put_port），發送資料。  

FIFO（資料緩衝區）：  
接收端是 put_export，提供 put 方法給 producer。  
傳送端是 get_peek_export，提供 get / peek 給 consumer。  

Consumer（接收者）：  
有 get_txn（get_port），從 FIFO 取資料。  

## 解讀
類別宣告
```systemverilog
uvm_tlm_fifo #(yapp_packet) fifo;
```
- 使用 uvm_tlm_fifo，資料型態是 yapp_packet（你自己定義的 transaction 類型）。
- FIFO 是 template 型別的，所以你可以傳入任何 transaction 類型。
  
建構元初始化
```systemverilog
fifo = new("fifo", this, 5);
```
- 名稱 "fifo"，父物件是 this。
- 第三個參數是 FIFO 的深度（容量為 5 筆），預設是 1，如果沒給會用 1。

建立 producer / consumer 實例
```systemverilog
producer = yapp_prod::type_id::create("producer", this);
consumer = yapp_con::type_id::create("consumer", this);
```

在 connect_phase 中建立 TLM 連接
```systemverilog
producer.send_txn.connect(fifo.put_export);
consumer.get_txn.connect(fifo.get_peek_export);
```
![image](https://github.com/user-attachments/assets/88aa4c43-40bf-4d5e-8607-25cfc17690fe)

#### TLM FIFO Methods
![image](https://github.com/user-attachments/assets/0255bbc0-112e-446a-b7f8-402395ec2e2f)

# TLM FIFO - Analysis FIFO
✅ 什麼是 uvm_tlm_analysis_fifo？  
uvm_tlm_analysis_fifo 是 uvm_tlm_fifo 的一個專門子類，用來與 uvm_analysis_port 搭配使用。
它是一個 無界（unbounded）FIFO（也就是 size = 0 表示不設大小限制），可以接收 write() 資料。  

A. 架構  
analysis_export 是用來接收 write() 呼叫的，它實際上是包裝了 put_export。  
get_peek_export 提供 get() 與 peek() 方法讓 Scoreboard 讀取資料。  
可以當作分析資料的 緩衝區（buffer） 使用，避免資料遺失。  

![image](https://github.com/user-attachments/assets/216f0b6b-bb31-4b51-92cd-6b7082a53247)
![image](https://github.com/user-attachments/assets/8b7f0805-a61c-4a1b-9038-189428fbb084)

B. 實際配置
如何在 Scoreboard 中使用 uvm_tlm_analysis_fifo (un-bounded) 作為分析資料的接收與緩衝。  
✅ 架構與好處
- Scoreboard可以直接用get()對FIFO存取
- 可使用不同的export方法: get_export / blocking_get_export / nonblocking_get_export
- Monitor不需要變動，只需要改scoreboard就能加上緩衝機制
- unbounded，可安心緩衝高頻資料

![image](https://github.com/user-attachments/assets/ca6c0627-cddd-40e0-bc84-1ef65edcb476)

C. Connect
在大一階的router_tb.sv做連接，一樣也是在connect_phase做連接，使用monitor的connect function  
![image](https://github.com/user-attachments/assets/22897f8d-7613-4ec3-9cf8-9a13ce7f12a0)


# 使用analysis FIFO的架構
![image](https://github.com/user-attachments/assets/ac54d136-092c-400d-b3d6-974e229e2368)
來源資料（YAPP UVC、HBUS UVC、Channel UVCs）透過 uvm_analysis_port 傳送封包。
Scoreboard 內含多個 uvm_tlm_analysis_fifo：
- yapp_fifo：接收來自 YAPP UVC 的封包。
- hbus_fifo：接收 HBUS 控制封包（含設定指令）。
- ch0_fifo, ch1_fifo, ch2_fifo：接收每個 Channel 輸出的封包。
- Scoreboard 在 run_phase() 主動從 FIFO 取資料做比較。
---

# Analysis port的廣播範例
使用一種write可以連結到"多個"monitor  
  
✅ Analysis Broadcast 架構  
Producer/Initiator：一個 uvm_analysis_port
Consumer/Target(s)：多個 uvm_analysis_imp
當 producer 執行 write(packet)，同一筆資料會廣播到所有已連接的 target
![image](https://github.com/user-attachments/assets/b219e714-ae66-4143-88ea-1f9f5f46d03d)
![image](https://github.com/user-attachments/assets/91dcedd9-156c-455e-962a-1e73deb19963)

## 連接實例
analysis port 的一對多（one-to-many）broadcast 連線 的技術細節與使用規則。
- send_yapp 是 uvm_analysis_port
- mone_in、mtwo_in 是 uvm_analysis_imp
- 在 connect_phase() 中將 一個 port 連接到多個 imp，形成 broadcast 機制
  
![image](https://github.com/user-attachments/assets/d7163fa8-36b1-4c76-8233-615443c26077)


## 解析analysis_imp vs TLM FIFO
| 分類         | `uvm_analysis_imp` 直連（Broadcast） | `uvm_tlm_analysis_fifo`（緩衝）        |
| ---------- | -------------------------------- | ---------------------------------- |
| 傳送模式       | Push                             | Pull                               |
| 接收端是否主動讀取？ | 否（write() 主動送入）                  | 是（需呼叫 get()）                       |
| 是否可支援一對多？  | ✅ 可多個 imp                        | FIFO 自身只支援一個輸出，但 port 可再 broadcast |
| 是否有資料緩衝？   | ❌ 無                              | ✅ 有 FIFO 暫存                        |


---

# 雙向的TLM傳輸
這張圖與說明介紹了 UVM 中的 雙向 TLM 傳輸通道（Bi-Directional TLM Transport Connection），是用來在模組之間傳遞請求 (REQ) 和獲取回應 (RSP) 的機制。這是另外一種port，叫做uvm_transport_port  
✅ 雙向 TLM Transport 架構  
Initiator：uvm_transport_port（主動端）  
Target：uvm_transport_imp（被動端） 
雙向傳輸：傳送 REQ、接收 RSP，全部封裝在一個方法呼叫中。  
![image](https://github.com/user-attachments/assets/10941595-f1fd-4554-be88-e8c76c372934)
可以有兩種方法  
![image](https://github.com/user-attachments/assets/41227956-61ba-44e2-8175-3e218eba83c4)



---

# 總結TLM
![image](https://github.com/user-attachments/assets/b0a7193d-99b8-4948-a5e2-3b19b472702a)
| 類型                        | TLM 元件名稱                                   | 使用情境 / 範例                                      | 備註                            |
| ------------------------- | ------------------------------------------ | ---------------------------------------------- | ----------------------------- |
| **Sequencer 與 Driver 之間** | `seq_item_port` / `seq_item_export`        | 驅動 Transaction，執行 transaction-based 模擬         | ✅ UVM 預設內建                    |
| **資料廣播（push）**            | `uvm_analysis_port` / `uvm_analysis_imp`   | Monitor 廣播封包給 Scoreboard、Coverage 模組等          | ✅ 支援一對多 broadcast             |
| **資料緩衝接收（pull）**          | `uvm_tlm_analysis_fifo`                    | Scoreboard 主動讀取封包（使用 `get()`）                  | ✅ 支援非同步處理                     |
| **單向資料傳送**                | `uvm_put_port` / `uvm_put_imp`             | Transaction 傳遞，但無需回傳（ex: monitor 傳送樣本）         | ✅ 有 blocking / nonblocking 版本 |
| **單向資料讀取**                | `uvm_get_port` / `uvm_get_imp`             | Target 主動從 source 拉資料（如 scoreboard pull data）  | ✅ 有 blocking / nonblocking 版本 |
| **雙向命令/回應傳輸**             | `uvm_transport_port` / `uvm_transport_imp` | Master 發送 REQ，Slave 回應 RSP（如 memory 模型）        | ✅ 同步或非同步皆可                    |
| **SystemC TLM2 整合**       | `tlm_initiator_socket`, `b_transport()`    | 與 SystemC 模型連接（如 SystemVerilog + SystemC 混合驗證） | ⚠️ 需 simulator 支援             |
| **多語言環境橋接**               | `uvm_tlm_ml`, `multi-language sockets`     | 異語言整合（UVM + C/SystemC）                         | ⚠️ Vendor-specific 解決方案       |




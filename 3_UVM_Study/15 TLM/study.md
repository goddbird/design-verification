# 目標
 
1. 使用Transaction Level Modeling
2. 選擇TLM連接的種類
3. 實例化 & 連接TLM interface
4. 使用TLM FIFO創建scoreboard

---
 
## 介紹
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
|只想測試狀態|can_put/can_get/can_peek|

#### 範例
![image](https://github.com/user-attachments/assets/785a2fd7-2a6f-488b-993b-5d7b516b5bdd)  
1. 在initiator裡呼叫port.put(packet);
2. 此put()會透過port->imp的連接傳遞到target
3. target的imp實際會呼叫put function(這個會實作在target裡面)。
4. 如何連接起來的? 在top level or env用producer.port.connect(consumer.imp)

#### 實際的Put例子
|Producer|Consumer|
|---|---|
|![image](https://github.com/user-attachments/assets/819b84f0-6c7c-41ce-8013-c0ad1800e923)|![image](https://github.com/user-attachments/assets/e0797e85-ae9f-4c14-8144-8c4d88483961)|

#### ENV上的build/connect
上述已經有producer/consumer的class，在env這層做build & connect
![image](https://github.com/user-attachments/assets/73bc7cbc-f8a3-465b-b4f2-cbe070eaef29)

---
### 單向TLM的Data flow種類
#### A. 一般put/get單向模型
1. consumer主動拉資料 (get model)  producer主動推資料 (put model)

#### B. Analysis Broadcast模型(廣播式)
使用單一uvm_analysis_port + 多個uvm_analysis_imp
資料從port同時傳給多個imp

#### C. 使用TLM FIFO
使用uvm_put_port & uvm_get_port，來提供先進先出的資料流控制
---
### uvm_tlm_fifo的架構與應用
UVM提供內建的FIFO類別，用來緩衝producer & consumer的transaction資料

#### 架構
![image](https://github.com/user-attachments/assets/d7537fc5-b298-41e8-8abf-ac8e982f9573)
- Producer
使用 uvm_put_port
呼叫 put() 把資料送進 FIFO

- FIFO
使用 put_export 暴露 put 功能（內部實作是 uvm_put_imp）
使用 get_peek_export 暴露 get/peek 功能（內部實作是 uvm_get_peek_imp）

- Consumer  
使用 uvm_get_port 來 get() 或 peek() 取資料

#### TLM FIFO的運作機制
|Producer|Consumer|
|---|---|
|宣告uvm_put_port，後續使用put方法![image](https://github.com/user-attachments/assets/1ef6f1e4-ecc0-43bd-94c0-cbb55b275a30)|宣告uvm_get_port，後續使用get方法![image](https://github.com/user-attachments/assets/2b285319-ed9e-479e-863b-dff61a52dc0d)|

#### TLM FIFO的配置
![image](https://github.com/user-attachments/assets/88aa4c43-40bf-4d5e-8607-25cfc17690fe)

#### TLM FIFO Methods
![image](https://github.com/user-attachments/assets/0255bbc0-112e-446a-b7f8-402395ec2e2f)

### TLM FIFO - Analysis FIFO
uvm_tlm_analysis是一種uvm_tlm_fifo的特殊化版本
A. 架構
![image](https://github.com/user-attachments/assets/216f0b6b-bb31-4b51-92cd-6b7082a53247)
![image](https://github.com/user-attachments/assets/8b7f0805-a61c-4a1b-9038-189428fbb084)

B. 實際配置
![image](https://github.com/user-attachments/assets/ca6c0627-cddd-40e0-bc84-1ef65edcb476)

C. Connect
![image](https://github.com/user-attachments/assets/22897f8d-7613-4ec3-9cf8-9a13ce7f12a0)

D-1. 與原本uvm_analysis_imp差別
![image](https://github.com/user-attachments/assets/74b3c35b-9a86-4969-aa78-b0e4d836c68f)
使用uvm_tlm_analysis_fifo的好處:
1. 不需實作write()
2. Scoreboard主動get()
3. 可同時get多個FIFO做比對

D-2. Analysis port的廣播範例
使用一種write可以連結到"多個"monitor
![image](https://github.com/user-attachments/assets/b219e714-ae66-4143-88ea-1f9f5f46d03d)

若使用的是FIFO，就沒辦法使用broadcast了

### 雙向的TLM傳輸
這是另外一種port，叫做uvm_transport_port
![image](https://github.com/user-attachments/assets/10941595-f1fd-4554-be88-e8c76c372934)
可以有兩種方法
![image](https://github.com/user-attachments/assets/37d53de8-59e9-444a-aae4-b818fee2f099)



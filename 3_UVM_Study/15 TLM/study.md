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


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

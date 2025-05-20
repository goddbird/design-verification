# 目標
學會使用UVM factory機制 : 改變default behavior & override method


---

## 內容重點

### 一、UVM Factory
Factory是一種物件產生機制，在"不改變"原程式碼的情況，建立不同類型的物件，適合以下 : 
- 可覆蓋的元件架構 (e.g. UVM env/agent/sequence item)
- 重複使用驗證IP
- 動態取代某些class行為

|優點|說明|
|----|----|
|🛠 取代建構子 new|更換 instance 的實際類型|
|🔁 支援 override|動態替換元件，支援重用與客製|
|🔍 類型註冊與比對|所有 type 經過註冊與工廠管理|
---

### 二、Factory使用步驟
1. 註冊 : 把 class 加入 factory `uvm_object_utils(class name) /  uvm_component_utils(class name)`  
2. create : 取代new，保持一致性，自動註冊與建構管理
3. type override : 允許覆蓋class，不用改程式碼
---
#### A. Create
語法 : `<handle>` = <class name>::type_id::create("packet", this);
this的意思是，告訴factory這個物件是在哪個元件下創造的
![image](https://github.com/user-attachments/assets/21c5943e-dbe4-41d3-bdeb-d16fc9927d1d)  
<br>
<br>
<br>
#### B. Override with Factory
*type override  
語法 : set_type_override_by_type(src_class::get_type(), des_class::get_type());  
覆蓋的流程如以下順序 :   
1. 宣告 : 需宣告src_class
2. 註冊 : `uvm_object_utils(src_class)
3. 覆蓋 : 在`test level`使用set_type_override_by_type()來覆蓋
4. 創建 : 這邊原本的src_class::type_id::create(..)會自動取代掉
![image](https://github.com/user-attachments/assets/bda370c8-b688-47e9-b488-17c40936da6d)

*instance override
語法 : set_inst_override_by_type(src_class::get_type(), des_class::get_type());
![image](https://github.com/user-attachments/assets/80bc37cd-6e66-4f0f-b02a-56f3ddc48f92)

||全域型別替換 (Type Override) | 實例指定型別（Instance Override）|
|----|----|----|
|語法|sub_class::type_id::set_type_override(base_class::get_type());|sub_class::type_id::set_inst_override("my_instance", base_class::get_type());|
|使用時機||例如你有一個 yapp_packet 的子類別 short_packet，但你只想讓 env.agent[0] 用 short_packet，其餘 agent 用原本的 yapp_packet|
|||![image](https://github.com/user-attachments/assets/9471601c-75d3-4586-8f4e-6c94dfbe5842)
|

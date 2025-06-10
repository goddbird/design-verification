# 目標
1. 學會使用UVM configuration機制，在build phase控制topology，比如控制UVC agent是active/passive，或者設定有幾個master/slave
2. 為特定實例設定屬性 : 使用uvm_config_db可以讓agent / sequence / monitor指定獨有行為，e.g. 使用不合法的設定來測試error case

---

## 內容重點

### 一、uvm中的 `is_active`
| 問題                                       | 解釋 |
|--------------------------------------------|------|
| 這是什麼？                                      | 這是一個 Config Property，可以改變整個 UVM 的架構是 active / passive |
| 如何決定 build phase 的架構？                   | topology 可由 `config property` 決定，例如 `is_active = UVM_ACTIVE` 或 `UVM_PASSIVE` |
| 由誰來主導？                                    | 通常在上層級就決定了，會由 `test` 級別 來決定是 active / passive |
| 改值前需要前置作業？                            | 是，需在 component 建立前就設定，要先在agent裡面先註冊 (`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON))，如此一來is_active就可以被管理 |
| 如何改變此值？                                  | 透過 test 的 build phase 設定：<br>`uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_PASSIVE)` |
| 會在哪個階段生效？                              | 必須在 `super.build_phase`「之前」就設定好 config，要怎麼吃到這個設定?  super.build_phase()就會呼叫到test level的build phase (做set) |
| 延伸學習：為什麼不用 new/build phase 傳變數？ e.g. `my_agent_h = new("agent_h", this, is_active);`  | 因為這樣會破壞封裝性與可重用性。用 config 設定可讓元件更泛用，不綁定上下文 |

*最後延伸學習的原因如下  
![image](https://github.com/user-attachments/assets/2296d9d1-6055-40ba-bb0a-820be9a26403)

*補充UVM的特性  
![image](https://github.com/user-attachments/assets/2d0e2cfe-7962-4604-96cd-bae29b7b1940)

---
### 二、uvm_config_db

| 問題                                       | 解釋 |
|--------------------------------------------|------|
|這是什麼?|設定屬性的語法，這會在test中的build phase執行，上述的is_active就可以用這個語法設定 |
|這個語法的架構是什麼?| uvm_config_db#(型別)::set( 誰下指令, 給誰, 設什麼欄位, 設成什麼值 );<br>![image](https://github.com/user-attachments/assets/8341ba63-2afe-4643-b430-380b40be30c8)|
---
| test                                       | agent |
|--------------------------------------------|------|
|![image](https://github.com/user-attachments/assets/9cbff238-e721-45e4-b8c2-b5cfbdfa6226)|![image](https://github.com/user-attachments/assets/2268f5f0-f597-4834-b643-80741084dbd3)|

![image](https://github.com/user-attachments/assets/3d6045d5-0284-48bd-a45f-e15aeb81bf9e)

---
#### 補充
- uvm_bitstream_t 是什麼? UVM提供一種通用的整數型別，可以用來容納大多數整數類型，int, bit, byte, logic等，例如 : uvm_config_db#(uvm_bitstream_t)::set(this, "env.agent", "burst_length", 32);
- uvm_config_db的set方法，wildcard版本 (使用* ?這兩種符號)
  - uvm_config_int::set(this, "tb.env.agent?", "is_active", UVM_PASSIVE);  //這是可以把agent1, agent2….agent9裡面的is_active都改成passive
  - uvm_config_int::set(this, "`*agent*`", "is_active", UVM_ACTIVE); //這是路徑中有包含agent的元件，都設定成active
  - uvm_config_int::set(this, "*", "recording_detail", 1); //為所有元件中的recording_detail改成1
- config設定失敗時，要如何debug?
  - 可以在test加入check phase做檢查 (check_config_usage) ，會在simulation最後階段印出所有set過但沒有被get到的設定。
  - ![image](https://github.com/user-attachments/assets/3ce82217-c9cc-4f34-a26c-9b42983244cc)

## 問題討論
發現uvm_field_xxx會有自動get & 透過super.build_phase自動更新  
但是uvm 1.1d對於uvm_active_passive_enum這個type有bug

結論1 : 根據測試，換了版本 1.1d -> 1.2
結論是uvm_field_enum在1.1d看起來有問題，會沒有super.build_phase自動更新的效果 => `假如不寫get，是不會更新test level更新is_active的效果`    
![image](https://github.com/user-attachments/assets/8718f71a-cd6a-4bdd-8c58-cb97fb17ad6b)



結論2 : 假如有`uvm_field_xxx註冊某變數or object，在經過了build phase中的super.build_phase後，會自動"更新註冊過的變數"
![image](https://github.com/user-attachments/assets/f2c1ab4c-876c-45a2-9526-890c438bc8b6)
![image](https://github.com/user-attachments/assets/78b86eb0-daf3-4796-a1c0-9b444dc5d4a8)




---
#### UVM Configure Method
|方法  | 功能說明 | 語法範例 |
|---------|------|-----|
|set|寫入設定：將 <field_name> 和 <value> 寫入 config DB（指定路徑）|set(uvm_component ctx, string inst_name, string field, T value)|
|get|讀取設定：取得先前設定的值，成功傳回 1，失敗傳回 0|get(uvm_component ctx, string inst_name, string field, inout T value)|
|exists|檢查是否存在：檢查指定的 field 在指定路徑下是否有被 set|exists(ctx, inst, field, bit spell_chk)|
|wait_modified|等待某個設定值被改變才繼續執行，可用於同步或等待 config 設定完成|wait_modified(ctx, inst, field)|



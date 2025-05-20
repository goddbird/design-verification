# 目標
1. 學會使用UVM configuration機制，在build phase控制topology，比如控制UVC agent是active/passive，或者設定有幾個master/slave
2. 為特定實例設定屬性 : 可以讓agent / sequence / monitor指定獨有行為，使用uvm_config_db，使用不合法的設定來測試error case

---

## 內容重點

### uvm中的 `is_active`
| 問題                                       | 解釋 |
|--------------------------------------------|------|
| 這是什麼？                                      | 這是一個 Config Property，可以改變整個 UVM 的架構是 active / passive |
| 如何決定 build phase 的架構？                   | topology 可由 `config property` 決定，例如 `is_active = UVM_ACTIVE` 或 `UVM_PASSIVE` |
| 由誰來主導？                                    | 通常在上層級就決定了，會由 `test` 級別 來決定是 active / passive |
| 改值前需要前置作業？                            | 是，需在 component 建立前就設定，要先在agent裡面先註冊 (`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON))，如此一來is_active就可以被管理 |
| 如何改變此值？                                  | 透過 test 的 build phase 設定：<br>`uvm_config_db#(uvm_active_passive_enum)::set(this, "env.agent", "is_active", UVM_PASSIVE)` |
| 會在哪個階段生效？                              | 必須在 `build phase`「之前」就設定好 config，要怎麼吃到這個設定?  super.build_phase()就會呼叫到test level的build phase (做set) |
| 延伸學習：為什麼不用 new/build phase 傳變數？ e.g. `my_agent_h = new("agent_h", this, is_active);`  | 因為這樣會破壞封裝性與可重用性。用 config 設定可讓元件更泛用，不綁定上下文 |

*最後延伸學習的原因如下  
![image](https://github.com/user-attachments/assets/2296d9d1-6055-40ba-bb0a-820be9a26403)

*補充UVM的特性  
![image](https://github.com/user-attachments/assets/2d0e2cfe-7962-4604-96cd-bae29b7b1940)

---
### uvm_config_db

| 問題                                       | 解釋 |
|--------------------------------------------|------|
|這是什麼?|設定屬性的語法，這會在test中的build phase執行，上述的is_active就可以用這個語法設定 |
|這個語法的架構是什麼?| uvm_config_db#(型別)::set( 誰下指令, 給誰, 設什麼欄位, 設成什麼值 );<br>![image](https://github.com/user-attachments/assets/8341ba63-2afe-4643-b430-380b40be30c8)|
---
| test                                       | agent |
|--------------------------------------------|------|
|![image](https://github.com/user-attachments/assets/9cbff238-e721-45e4-b8c2-b5cfbdfa6226)|![image](https://github.com/user-attachments/assets/2268f5f0-f597-4834-b643-80741084dbd3)|
---
#### 補充
- uvm_bitstream_t 是什麼? UVM提供一種通用的整數型別，可以用來容納大多數整數類型，int, bit, byte, logic等，例如 : uvm_config_db#(uvm_bitstream_t)::set(this, "env.agent", "burst_length", 32);
- uvm_config_db的set方法，wildcard版本 (使用* ?這兩種符號)
  - uvm_config_int::set(this, "tb.env.agent?", "is_active", UVM_PASSIVE);  //這是可以把agent1, agent2….agent9裡面的is_active都改成passive
  - uvm_config_int::set(this, "`*agent*`", "is_active", UVM_ACTIVE); //這是路徑中有包含agent的元件，都設定成active
  - uvm_config_int::set(this, "*", "recording_detail", 1); //為所有元件中的recording_detail改成1


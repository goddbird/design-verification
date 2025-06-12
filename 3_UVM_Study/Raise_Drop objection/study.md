# 目標
 
1. 為何要使用Phase
2. Phase的特性
3. 各Phase介紹
4. Phase的跳轉機制
5. Phase的debug方式
6. Objection機制


---
 
## 為何要使用Phase?
UVM採用phase機制來運行各個phase，運行的時候需要`thread控制` & `跳轉之前or之後 (使用callback)`
phase的使用很大程度上可以解決code紊亂所引發的問題，根本上是使用code順序固定來實現這個目的，例如build phase一定是在connect phase之前執行，而connect phase一定在end_of_elaboration_phase之前執行
![image](https://github.com/user-attachments/assets/966fb9ac-b943-4a1c-8c03-8f262c16dcb8)


## Phase的特性
所有的phase都是定義在uvm_component的base class，所有的phase都是function除了run_phase，因為run_phase會消耗時間，而其他不會。
![image](https://github.com/user-attachments/assets/0e3871e4-4d5c-4e2d-9850-9400149e4484)

## 各Phase介紹

### build_phase
利用factory機制，建立所有的component，所有的override方法會在這層作用，順序是top-down (從top往最下層)

### connect_phase
等到所有的component建立後，會需要連接，所有的component使用TLM方式做連接，順序是bottom-up

### end_of_elaboration_phase
等到上述的元件build & connect後，有可能有些元件漏build/connect，或者override機制沒有成功。
所以需要有個phase確保以上功能能正常運行，這會印出topology，這個phase的執行順序是bottom-up。

### run_phase
唯一的task函式，simulation都從此phase開始消耗時間，此phase含有12個sub-phase，大致可以分為reset / configure / main / shutdown這幾個phase，這層的順序也是botton-up
- reset_phase => to reset dut and initialize dut
- configure_phase => the configuration and setting of dut
- main_phase => the main operation of dut is in this phase
- shutdown_phase => to power off dut

Run phase裡的執行順序下圖舉例，是要每個phase一起結束才進入到下個Phase
![image](https://github.com/user-attachments/assets/eabddf5a-6561-4c19-814d-ae5eb7b34f43)
![image](https://github.com/user-attachments/assets/138fda01-212b-4508-9a51-e329589b102e)

## Phase的跳轉機制
預設各phase是按時間順序執行，但可以自訂做必要的跳轉，如在main_phase執行過程中，突然遇到reset訊號被置起，可以用jump()實作從mian_phase到reset_phase的跳轉：
phase.jump(uvm_reset_phase::get())  e.g. phase.jump(uvm_reset_phase::get());

### 跳轉的限制
1. 不能跳到build -> start_of_function之間的phase
2. 不能直接跳到run_phase
3. `從run_phase後就可以向前/向後跳轉了`
![image](https://github.com/user-attachments/assets/0d39b0fa-7c66-49f4-b590-edafac14960b)


## Phase的Debug方式
1. 在compile加入+UVM_PHASE_TRACE : 這會印出很多phase的資訊
![image](https://github.com/user-attachments/assets/b1911192-f1d9-4730-9854-cd599f0ba018)

2. 可以加入Timeout條件
+UVM_TIMEOUT=“300ns, YES”

3. 或者在每個phase中加入uvm_info來確認log


## Objection機制
component中，task phase是會消耗simulation時間的，可以使用objection機制來控制phase執行。  
![image](https://github.com/user-attachments/assets/0b00aeb4-2576-49af-afea-8d67172341cc)  
分為raise/drop objection兩種，raise objection可以讓phase不要結束，而drop objection可以讓phase在執行完後，進入下一個phase。

## 重要觀念
run_phase & 其他run-time phase是平行執行  
Case 1  
如果其他的run-time phase有raise objection，run phase就能維持住不結束。  
Case 2   
如果run phase有raise objection，其他的run-time phase可能會結束。  
|Run time phase - Objection|Run phase - Objection|
|-|-|
|這可以維持!![image](https://github.com/user-attachments/assets/327d34be-d2d3-45b7-9ebf-d4ff5fece8be)|這不能維持!![image](https://github.com/user-attachments/assets/9457fab4-6241-4590-95ea-bba4e2e47f7c)
|
![image](https://github.com/user-attachments/assets/cf1552aa-31ee-4967-b4fb-6ff08de661b9)


推薦的objection使用位置  
1. Scoreboard  
 ![image](https://github.com/user-attachments/assets/baf4cf8a-003d-4d0e-9b00-b958cd32c0c6)  

2. Sequence (最常使用)  
![image](https://github.com/user-attachments/assets/9c0028f0-402f-4685-aaee-88994f27418f)  

![image](https://github.com/user-attachments/assets/d2754cae-311f-413c-b2d1-c70c0d30b2a9)

## Debug專用
要如何知道程式裡有沒drop的objection?
A: 可以在compile option裡面加入+UVM_PHASE_TRACE來確認PHASE的狀態
|有drop|沒drop|
|-|-|
|最後會看到final phase之類的![image](https://github.com/user-attachments/assets/4301ee43-337c-4e85-ae1a-4e85f66a3b4f)|如果有沒drop的objection，則會卡在shutdown phase![image](https://github.com/user-attachments/assets/9138d439-4ce6-4bc9-9af4-e5b143500df0)|

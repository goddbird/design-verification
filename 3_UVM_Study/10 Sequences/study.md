# 目標
1. 建立uvm sequence，使用UVM macros & methods建立stimulus
2. 定義sequencer該執行哪些sequence
3. 使用UVM objection mechanism控制simulation結尾


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
3. constructor : 使用new，但只有指定name
4. body : 在圖中的uvm_info是用來print message用的，這是sequence的主要流程，uvm_do是常用的UVM巨集，`用來產生&送出transaction`，第一筆是隨機packet : uvm_do(req)，第二筆是強制addr == 0
![image](https://github.com/user-attachments/assets/e80c6ee9-108b-406a-8eec-67a5787454f8)

### 三、uvm_do
實際運作了哪些流程 :
1. create : 用factory自動分配建立req，也就是transaction item
2. Wait : sequencer等driver說需要資料了才送
3. Randomize : 會與class內的constraint結合
4. Transfer : sequencer把item傳給driver的seq_item_port
5. Wait done : sequencer會等driver呼叫`item_done()`才繼續往下執行

![image](https://github.com/user-attachments/assets/21217e0a-f122-4772-aa88-9d165d398e18)

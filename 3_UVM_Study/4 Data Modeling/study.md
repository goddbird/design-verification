# 介紹
 
1. 建模DUT
2. 實例 & 連接一個TLM的interface，用來從UVC傳送packet資訊到scoreboard
3. 宣告scoreboard的clone/compare操作


一開始業界習慣把控制多個UVC的sequencer/sequence叫做virtual sequencer, virtual sequence，但因為virtual早有定義，所以這個名字會很混淆
現在IEEE 1800.2改術語叫做multichannel sequencer

---
 
## 📌 內容重點
### 一、建立yapp_packet的sequence物件
1. 下圖是一個packet的實際例子
![image](https://github.com/user-attachments/assets/7818168d-c915-4a05-ac56-f45a98029f7b)  
a. extends uvm_sequence_item: 讓yapp_packet擁有如print(), copy(), compare()等uvm操作。uvm_sequence_item是uvm_object的子類  
b. constructor: 建構子必須有一個string name(當作物件名稱)，必須要呼叫super.new(name)才能傳到uvm系統內部  
c. 註冊factory : 內部變數length也要向factory註冊，讓uvm的函式可以使用此一變數。

2. 

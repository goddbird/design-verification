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

2. 介紹一些UVM field macro
   
   <img width="732" height="412" alt="image" src="https://github.com/user-attachments/assets/3a3b6740-e885-4691-b567-b7dff5b7687e" />
   
   像第一點的uvm_field_int就是要註冊length這個變數，後續使用uvm的方法時可以參考
   讓一些像是p1.length = 20這種操作改變值，或者像是p1.print()印出14 (default 是hex) => 確定是Hex。
   *要注意的是，只有`uvm_field_enum，要特別加入參數的type。

4. array type的macro註冊
   <img width="836" height="478" alt="image" src="https://github.com/user-attachments/assets/ba59424c-362d-4dde-a4ea-63c0daa4db0a" />
   
   記住就只有中間的關鍵字替換為 : array / sarray / queue / aa，其中要注意aa後面還要加int or string

5. Macro flag的用途，上述使用uvm_field_int(<field_name>, 還要加flags)

   <img width="890" height="480" alt="image" src="https://github.com/user-attachments/assets/86068ef1-2e60-4d9f-86ed-fbec46224187" />
   
   這會決定某些欄位會不會被print, copy, compare, pack等動作影響，進階一點還可以指定印binary or decimal，詳見圖片下方。
   假設在flag欄位給定UVM_NOPRINT，這樣後續對這個註冊的變數使用print()，就不會印出這個變數相關的屬性。
   *若是沒在factory註冊的變數，在print也印不出來
   e.g.
   
   <img width="508" height="607" alt="image" src="https://github.com/user-attachments/assets/9b52a3ca-3b77-4414-b204-9143def07583" />

7. 使用Field Macro Example

   <img width="659" height="389" alt="image" src="https://github.com/user-attachments/assets/9a1803d6-376c-4586-ae5f-c633be835019" />
   
   上圖註冊了yapp_packet內的所有變數。

8. 解釋copy, clone的差別與舉例。

   <img width="940" height="519" alt="image" src="https://github.com/user-attachments/assets/ffbe8cc8-7d6d-4407-8c61-427fcede7e34" />
   <img width="900" height="329" alt="image" src="https://github.com/user-attachments/assets/fecd549c-1ac2-483c-865a-7b7651be8245" />
   
   copy : 是兩個已new過的物件，做內容複製的動作。
   clone : 一個沒new過的空物件 / 把一個已存在的物件，把內容複製過來。由於回傳的是uvm_object，要用$cast轉成正確的型別。

9. uvm inheritance

   <img width="665" height="593" alt="image" src="https://github.com/user-attachments/assets/b7b9ba1e-3d46-468f-ab8c-5e3150cc1233" />







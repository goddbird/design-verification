# 介紹
 
1. 使用multichannel sequencer控制多個UVC  
2. 創建 & 連接multichannel sequencer
3. 定義multichannel sequencer


一開始業界習慣把控制多個UVC的sequencer/sequence叫做virtual sequencer, virtual sequence，但因為virtual早有定義，所以這個名字會很混淆
現在IEEE 1800.2改術語叫做multichannel sequencer

---
 
## 📌 內容重點
為什麼需要UVC multichannel sequence?  
A: 讓一個上層sequence，能啟動多個sequence，讓不同個sequencer使用
1. 需要跨多個UVC同步行為 e.g. 一邊送AXI、一邊觀察APB
2. 將資料分配到多個input port

🎯 實務上的重要結論
虛擬 sequence 的必要性，來自「要跨多個 UVC 同步控制」的需求
不是所有 UVC 都要掛進虛擬 sequencer！
如果某個 UVC 只跑一條固定 sequence 或只負責 response，就不需要特別控制


### 一、如何建立Multichannel Sequencer/Sequence
步驟摘要
1. 宣告multichannel seqr
2. 宣告multichannel seq
3. 在env把mc seqr跟實體seqr連接
4. 在test level設定default sequence

#### 1. 步驟說明
1. 建一個 multichannel sequencer class，只宣告seqr handle  
![image](https://github.com/user-attachments/assets/a15cedf0-270f-41f0-a3a4-67aa08431629)  
這個是virtual sequencer，不處理item，所以不用參數。
  
2. 建 multichannel sequence，要先把前面宣告的virtual seqr註冊p_sequencer
![image](https://github.com/user-attachments/assets/01b6a46b-91a1-470f-9c31-ff6694624e9c)
- `uvm_declare_p_sequencer(router_mcsequencer) : 需要把multichannel seqr的class註冊進p_sequencer
- 宣告sequence的handle
- body使用uvm_do_on來連接p_sequencer & sequence: uvm_do需輸入要執行哪一種sequence，且是p_sequencer中的哪一個seqr實體。

3. 在env中建好mc sequencer的handle，在build_phase中create各個handle，並在connect_phase連接各 UVC 的 sequencer，把multichannel seqr連線上實體的agent裡面的seqr  
註: 為什麼是在env裡做連接而不是在agent裡面做，是因為mc sequencer是一個跨agent的元件，他需要從多個agent中取得sequencer的handle  
![image](https://github.com/user-attachments/assets/8666487e-f7f1-4f1b-ac05-2ee28f53f1f9)

4. 在 test 中設定 default sequence，並取消原本有的default sequence  
![image](https://github.com/user-attachments/assets/5c07f63c-cf13-4551-b11a-5ed65dc1f71a)


#### 2. Multichannel Sequence Objections
在 UVM 中，run_phase 等 phase 是 "objection-based" 的：
phase 只會在 沒人再 raise objection 時結束。
如果你在 virtual sequence 裡沒有 raise objection，那整個測試可能會過早結束，造成：
子 sequence 還沒跑完就 simulation 停止，看起來像是 DUT 沒反應，實際是 test 沒撐住

建議作法:
如此一來不用每一個sequence都要寫raise/drop objection
1. 宣告base class
```systemverilog
class base_mcseq extends uvm_sequence;

  virtual task pre_body();
    if (starting_phase != null)
      starting_phase.raise_objection(this, get_type_name());
  endtask

  virtual task post_body();
    if (starting_phase != null)
      starting_phase.drop_objection(this, get_type_name());
  endtask

endclass
```

2. Multichannel Sequence繼承此class  
class router_mcseq extends base_mcseq; 


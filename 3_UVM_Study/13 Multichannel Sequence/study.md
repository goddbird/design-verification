# 介紹
 
1. 使用multichannel sequencer控制多個UVC  
2. 創建 & 連接multichannel sequencer
3. 定義multichannel sequencer


一開始業界習慣把控制多個UVC的sequencer/sequence叫做virtual sequencer, virtual sequence，但因為virtual早有定義，所以這個名字會很混淆
現在IEEE 1800.2改術語叫做multichannel sequencer

---
 
## 📌 內容重點
為什麼需要UVC multichannel sequence?
A: 讓一個sequence能指揮多個sequencer
1. 需要跨多個UVC同步行為 e.g. 一邊送AXI、一邊觀察APB
2. 將資料分配到多個input port

🎯 實務上的重要結論
虛擬 sequence 的必要性，來自「要跨多個 UVC 同步控制」的需求
不是所有 UVC 都要掛進虛擬 sequencer！
如果某個 UVC 只跑一條固定 sequence 或只負責 response，就不需要特別控制


### 一、如何建立Multichannel Sequencer/Sequence
 
#### 1. 步驟說明
1. 建一個 multichannel sequencer class，加入 handle  
![image](https://github.com/user-attachments/assets/a15cedf0-270f-41f0-a3a4-67aa08431629)  
這個是virtual sequencer，不處理item，所以不用參數。
  
2. 建 multichannel sequence，呼叫各個子 sequence  
![image](https://github.com/user-attachments/assets/d11c939f-a75f-4c59-9dca-56508d5a79b3)  
這步使用p_sequencer連接時，記得要先宣告p_sequencer

3. 在環境中建好 sequencer，並連接各 UVC 的 sequencer  
![image](https://github.com/user-attachments/assets/8666487e-f7f1-4f1b-ac05-2ee28f53f1f9)

4. 在 test 中設定 default sequence，並取消 UVC 的 local control  
![image](https://github.com/user-attachments/assets/5c07f63c-cf13-4551-b11a-5ed65dc1f71a)

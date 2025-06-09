![image](https://github.com/user-attachments/assets/9fec714e-2ffa-4213-a2df-23f886bd9e12)  
建立一個UVM sequence
1. 宣告yapp sequence達到多種stimulus: a. simple, b. nested, c. property-controlled, d. directed
2. 在sequencer上執行選定的sequence
3. TBD
4. Debug & fix rand fail


# 實作
## 1/2, 宣告yapp sequence的多種stimulus
|種類|Simple Stimulus|Nest Stimulus|
|-|-|-|
|實作|![image](https://github.com/user-attachments/assets/20c08d76-670f-4c29-a487-5c1aca3a1dcf)|使用Line 45的Base class，然後宣告另一個nest_packet來呼叫base class，就是所謂的nest stimulus![image](https://github.com/user-attachments/assets/531b4de7-5997-4cbe-92e6-6d23375de807)<br>在tb這層要設定default sequence![image](https://github.com/user-attachments/assets/7691e9fb-b1d8-4d3a-956a-3823c70e72a7)|

|種類|Property-controlled|directed Stimulus|
|-|-|-|
|實作|property是說使用with來限制randomize給的值![image](https://github.com/user-attachments/assets/dd8c578d-f851-437a-991c-bf0bf5a6758f)|direct是指不需要randomize，直接指定值![image](https://github.com/user-attachments/assets/f1eaf9ee-60f8-450f-8f71-3fa841bd1833)|

---
## 3. 建立一個「完整執行所有子 sequence」的總集合 sequence
目前的做法，可能會先宣告好複數個以上的sequence，然後在我自己定義的Seq_pack中，create & 用start呼叫，就會運行了。
![image](https://github.com/user-attachments/assets/86a9223c-aeff-43b8-9051-76bb37e52365)

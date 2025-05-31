# 介紹
 
1. 創建一個scoreboard
2. 實例 & 連接一個TLM的interface，用來從UVC傳送packet資訊到scoreboard
3. 宣告scoreboard的clone/compare操作

---
 
## 📌 內容重點
1. 為什麼需要ScoreBoard?  
A: 用來驗證 DUT 是否正確處理封包的核心元件，它從 YAPP 和 Channel 的 monitor 收集封包，進行輸入/輸出比對，必要時也可以分析 HBUS 資料，並考慮異常狀況。  

2. ScoreBoard組成的要素  
A: Ref model (Golden Model) / storage (暫存預測資料) /  Checking logic (比對)  

3. ScoreBoard如何收資料  
![image](https://github.com/user-attachments/assets/83e7b292-f443-4986-a2e8-5f8a661bbab7)  
A: YAPP UVC的agent裡面會有monitor，他會收到來自DUT的封包，再把封包傳給scoreboard
會透過TLM機制傳遞analysis port(Monitor發) / analysis port imp(ScoreBoard收)。  
connect phase會在env/test中完成
一個ap可以接多個imp，但一個imp只能接一個ap  
![image](https://github.com/user-attachments/assets/7ca3d099-060c-4ee9-aca2-fede89299ec9)  


4. Write function機制  
A: Scoreboard會定義write function，而monitor會call write function並帶入transaction做輸入，來表示傳送transaction

|monitor|scoreboard|testbench|
|---|---|---|
|先宣告analysis port & 實例化`在TLM溝通中，會避免使用type override的功能，所以只能用new`，後續把packet當作輸入丟進write![image](https://github.com/user-attachments/assets/ad8eb952-a4b4-45d0-a8ea-5ec7da1983ac)|宣告analysis imp port(會在env/test做連接，並要帶入transaction的class & 實作write的class)，還需要定義好write function內容![image](https://github.com/user-attachments/assets/931e47d9-5bcb-4d3d-84f0-b115d3ba0261)|在tb裡面宣告env & sb，build_phase把sb create出來，最後在env的connect_phase連接![image](https://github.com/user-attachments/assets/d8653864-723c-49f1-a27f-33fcc9412cac)|


5. 多個imp機制

  
🔧 問題背景
UVM 中的設計限制是：
一個 component 只能宣告一個 uvm_analysis_imp 物件。
👉 但在實務中，你的 scoreboard 可能要從多個 monitor 收資料（例如 yapp、chan0、chan1、hb等）→ 就需要多個 imp！
 
✅ 解決方式：使用 uvm_analysis_imp_decl(<suffix>) 巨集
這個巨集的用途是：
🔁 產生多個不同的 imp 類別，每個 imp 都有自己的 write_<suffix>() 方法可以實作

語法: `新增註冊的宣告式`，再用剛宣告的註冊式來註冊，write function也要使用新的名字來定義
```systemverilog
`umv_analysis_imp_decl(_yapp)
uvm_analysis_imp_yapp#(yapp_packet, router_tb)
```
例子如下  
![image](https://github.com/user-attachments/assets/73ca2378-6fed-4707-b7d4-afa1bbb0fa08)

最終的應用如下圖
建立一個sb後，在tb的connect_phase把多個monitor連接到同一sb上，sb內部用imp處理多個port(yapp_in, hbus_in)  
要注意是monitor的connect函式，然後把scoreboard當成輸入丟進去。 (monitor.connect(scoreboard) )
![image](https://github.com/user-attachments/assets/9b8b4dab-0a3c-4e31-8bdb-30e136a973f8)


6. Clone的機制  
因為monitor傳給scoreboard的方式，是用write(pkt)來傳指標，不是透過copy，所以每次都重複使用pkt這物件時，可能變成以下狀況:
`queue = {pkt, pkt, pkt}`，這樣就等於封包內容傳了後，又會一直被更改，傳了就沒有意義。

### 正確做法
🔧 正確做法：在 write() 中用 clone() 複製封包！
```systemverilog
function void write_yapp(yapp_packet packet);
  yapp_packet vpkt;
  $cast(vpkt, packet.clone()); // 複製出一份新封包（不同記憶體位置）
  case (vpkt.addr)
    2'b00: q0.push_back(vpkt);
    ...
endfunction
```

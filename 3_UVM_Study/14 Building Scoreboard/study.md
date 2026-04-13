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

## 步驟摘要
### Monitor
1. ap port的宣告，要輸入transaction
2. constructor要帶new ap port
3. 呼叫write function

### Scoreboard   
1. ap imp的宣告，帶入transaction & sb的class
2. constructor要帶new ap imp port
3. 定義write function

### tb
1. 宣告sb handle
2. build_phase要create sb
3. connect_phase要把ap & imp連起來，使用ap的connect函式來做連接

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
function void write_yapp(input yapp_packet packet);
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

7. Compare的機制
Scoreboard在碰到封包類型不同的時候，無法直接透過==比較。這個compare method要寫在scoreboard裡面
#### 語法
e.g. function bit pkt_compare(yapp_packet yp, channel_packet cp);
function bit <name> (預期封包, 實際封包, 比較器=null)
1. 判斷是否傳入comparer  
如果沒傳入comparer，就自己創建一個新的

2. 使用comparer比較欄位  
語法 name = comparer.compare_field("欄位名稱", 預期欄位, 實際欄位, 欄位寬度);
#### 範例
![image](https://github.com/user-attachments/assets/ab4a8761-3c66-45c2-8be3-b46eb2977800)


### 總結
會自動報告差異 / 比較多欄位

### 比較後錯誤
![image](https://github.com/user-attachments/assets/79995735-e6c8-4523-8c18-3203e279cd96)


### 正確做法
![image](https://github.com/user-attachments/assets/f12c9747-1f6f-488d-9a97-7fe1bd76e791)


---
8. 階層式連線的方法  
- 在 UVM 的階層架構下，你的 component（例如 testbench, env, agent）通常是分層的
- 低層會產生資料（monitor），最終要送到 scoreboard 的 imp
- 中間的層級無法實作 write()，但可以轉交 → 所以要用 export


### 每層TLM介面怎麼用?
![image](https://github.com/user-attachments/assets/367fe93e-fd7f-4619-89b0-89580f4af00a)


### Scoreboard機制 & Driver機制的差別
port是發送請求者，Scoreboard機制的請求者是monitor
![image](https://github.com/user-attachments/assets/114672b6-0cc9-42e4-9bdb-55b310fbc47c)

![image](https://github.com/user-attachments/assets/83fbaecd-330d-4aa5-ab51-389111c1a2ac)

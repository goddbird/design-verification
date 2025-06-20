# 目標

將functional coverage整合到  
🧩 interface-level UVC（從 monitor 提取資訊）  
🧠 module-level scoreboard（確認行為 + 分析 coverage）  

---
 
# 介紹
分為explicit/implicit coverage (人為/程式計算的coverage)
## Explicit Coverage
### Assertions
1. 用來檢查訊號的時序關係、事件順序
2. 使用程序區塊
3. `無法在class裡面被定義`
#### 範例說明
```systemverilog
property req_gnt (cyc);
 @(posedge clk)
  $rose(req) ##0 (req && !gnt)[cyc] ##1 gnt;
endproperty
cover property (req_gnt(3)); // 檢查3個cycle內是否有grant
cover property (req_gnt(4)); // 檢查4個cycle內是否有grant
cover property (req_gnt(5)); // 檢查5個cycle內是否有grant
```

### Covergroup
1. 用來收集資料組合、交叉值、特定輸入範圍的出現次數
2. 可以被宣告為class，通常會用new建立
3. 在interface or module裡面使用
#### 範例說明
```systemverilog
covergroup cg @(posedge clk);
 len : coverpoint pkt.length {
  illegal_bins zero = {0}; // 長度為0視為非法
  bins sml = {[1:10]};     // 合法長度1~10
...
}

 addrxlen : cross pkt.addr, len;
endgroup
cg cg1 = new(); //建立covergroup測項
```

---
# Coverage要放在哪裡?
## 通常放在哪裡?
會放在monitor中，即使 agent 是 passive（不主動產生 stimulus），monitor 還是能被動收集 coverage

## 放在別的UVC例子
1. interface monitor
用來覆蓋 資料排列組合（data permutations）
比如：各種合法的 data pattern / 交錯方式
2. Module monitor
用來覆蓋 模組內部的行為
如：路由選擇、延遲 latency

## 放在整個UVC內
▸ 例如：追蹤架構性統計資訊（跨多次模擬）
如：總共看到了幾個不同的 slave device
這種 coverage 通常與系統架構有關
📌 例子 1：Bus 系統中 slave 設備的觸達
「模擬期間是否所有 slave 都有被 access 到？」
系統架構：你有一個 master 發 request 給多個 slave（像 AXI、AHB、Wishbone 等 bus）
Coverage 寫法：紀錄有哪些 slave ID 被 access 過
使用時機：確認測試是否涵蓋所有 slave
✅ 跨模擬累積統計：某些 seed 可能只 hit 到部分 slave，需要多次模擬收集完整資料。

## 放在Transaction class中
🔧 需要配合控制開關（policy / knob）
否則容易產生太多或無意義的 coverage
⚠️ 缺點：
若 coverage 目標不一致，會很難針對每個目標客製化

# Coverage範例
## Monitor內
1. 使用enable_cover來控制要不要new covergroup
2. 宣告好covergroup
3. 這範例中沒有clock event，需再寫sample的code
![image](https://github.com/user-attachments/assets/d01682f8-31d8-43b1-9048-41e3a77e4c77)

## UVC內
這是放在其他UVC的monitor中
💡 這個範例說明什麼？
這個 router_monitor 用 chan0_rec 計數器來追蹤從 channel0 收到幾筆資料，每當有資料到來，就：
加總 chan0_rec
呼叫 chan_cov.sample() 來記錄目前計數情況是否已命中某個 bin
範例 bin：
```systemverilog
bins ch0_cov = {[1:$]}; // 表示 1 以上的值都會被統計
```
![image](https://github.com/user-attachments/assets/dbc41d08-a1eb-4c5a-b86a-5861fd8c60c2)

# Sample的時機點?
![image](https://github.com/user-attachments/assets/3722d51d-bded-49af-ab46-15fbd67685f1)

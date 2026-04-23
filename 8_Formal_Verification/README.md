# Formal Verification Introduce
/*** 參考文獻 ***/ <br>
https://www.eettaiwan.com/20190715ta31-introduction-to-formal-verification/  <br>
https://www.wenhui.space/docs/07-ic-verify/formal/formal/ <br>
https://www.systemverilog.io/verification/gentle-introduction-to-formal-verification/ <br>


形式驗證(formal verification)是使用數學方法驗證設計正確性的過程，其工具使用各種演算法來驗證設計，但不執行任何時序檢查。這些工具不需要激勵(stimulus)或測試平台，在IC設計週期初期即可執行，也就是說，只要有RTL碼即可執行形式驗證。問題發現越早，修復就越容易。
形式驗證的普及得益於在英特爾(Intel) Pentium處理器發現漏洞的業界知名事件；該事件導致故障處理器召回，英特爾也不得不承擔近5億美元的損失。還有其他各種事故，例如Ariane 5號運載火箭爆炸，以及巴拿馬癌症研究所(Panama Cancer Institute)輻射量超標事故等；這些事故實際上都可以利用形式驗證以避免。
測試是指在軟硬體產品生產後，將選定的輸入訊號送入待測物 (device under testing；DUT)，從而檢驗產品設計的正確與否。模擬則不需要用到實際的待測物件，而用一個數學模型代替，觀察此數學模型的行為，以推斷產品設計的正確與否。而形式化驗證則完全在數學模型的抽象層次，企圖證明系統設計架構的正確性。


# JasperGold implementation
常用的使用方法有兩種類型,一個是SEC,對模組功能做對等性檢查,另一個是FPV,基於規則特性的功能驗證。這裡只對FPV進行介紹,也就是 Formal Property Verifycation

# Formal Verification in FIFO RTL
## Step 1. Generate FIFO
## Step 2. Generate System Verilog Assertion (SVA)
需要把SVA跟DUT寫在同一個module裡面，不能分開成兩個module
## Step 3. Create formal filelist (formal.f)  /  Create tcl file
           ```
           ../rtl/fifo.sv
           ./checker/assertion.sv
           ./interface/interface.sv
           ```
---
           
           ```
           clear -all
           analyze -sv ../rtl/fifo.sv
           elaborate -top fifo
           clock CLK
           reset -expression {RESETn == 0}
           prove -all
           ```


# Side Project Agenda
## 特色
- 形式驗證方法：專案採用 formal verification（形式驗證），利用數學方法驗證設計正確性，不需激勵或傳統 testbench，能在 RTL 階段早期發現問題，修復成本低。
- 自動化流程：有明確的流程與腳本（如 run_formal.tcl），自動化分析、elaborate、clock/reset 設定與 prove-all，方便快速驗證。
- SVA 整合：強調 SystemVerilog Assertion（SVA）必須與 DUT 寫在同一 module，確保 assertion 能正確作用於設計。
- 文件結構清楚：RTL、assertion、interface、formal filelist、tcl 腳本分明，易於維護與擴充。
- 參考文獻豐富：README 提供多個 formal verification 相關資源，便於學習與查證。
---

## Future Work
- Assertion 覆蓋率：可加入 assertion coverage 報告，檢查哪些設計行為未被 assertion 覆蓋，提升驗證完整性。
- 模組化與重用性：將 assertion、interface、checker 進一步模組化，方便日後複用於其他專案。
- 自動化報告產生：增設自動產生驗證報告（如通過/失敗、counterexample trace），方便追蹤與審查。
- 多工具支援：目前流程偏向 JasperGold，可考慮支援其他 formal 工具（如 Synopsys VC Formal、OneSpin），提升移植性。
- 參數化設計：讓 FIFO 或 assertion 支援參數化（如深度、資料寬度），提升驗證彈性。
- 結合仿真驗證：可考慮 hybrid flow，將 formal assertion 與傳統仿真 testbench 結合，提升驗證信心。
- 更細緻的 reset/clock 控制：根據設計需求，提供更彈性的 clock/reset 設定與多時脈支援。

# TBD
針對 FIFO (First-In-First-Out) 的驗證，編寫 Assertion (通常使用 SystemVerilog Assertions, SVA) 的核心在於確保**資料完整性**、**邊界條件**以及**時序協議**。

以下我將 FIFO 的行為拆解為幾個維度，你可以根據這些行為來編寫 Assertion，以提升 Coverage：

---

### 1. 基礎指針與狀態行為 (Pointer & Status Flags)
這部分確保 FIFO 的「滿」與「空」旗標邏輯正確。

* **Reset 狀態檢查：** 當 `reset` 觸發時，`full` 必須為 0，`empty` 必須為 1，指針必須歸零。
* **Full 狀態阻擋：** 當 `full` 為高電位時，若 `push` 動作仍然發生，必須觸發錯誤（除非設計允許自動忽略，否則通常視為 Overflow）。
* **Empty 狀態阻擋：** 當 `empty` 為高電位時，若 `pop` 動作仍然發生，必須觸發錯誤（Underflow）。
* **滿/空互斥：** 除非深度為 0（不合理），否則 `full` 和 `empty` 不應同時為 1。
* **臨界旗標 (Thresholds)：** 若有 `almost_full` 或 `almost_empty`，檢查其觸發時的計數值是否符合設定。

### 2. 資料完整性 (Data Integrity)
這是 FIFO 最關鍵的部分，確保進去的資料跟出來的一模一樣。

* **資料穩定性：** 當 `push` 有效但 `pop` 未發生時，`data_out` (或內部存儲) 在下一個時鐘週期不應改變。
* **FIFO 順序檢查 (Ordered Pass-through)：** > **建議寫法：** 利用一個輔助的 Queue 或偵測特定 Data Tag。進入 FIFO 的第一個資料 `D1`，必須是第一個被輸出的資料。
* **無中生有 (No Spurious Data)：** 當 `pop` 發生時，輸出的資料必須是之前曾經 `push` 進去的。

### 3. 計數器與深度 (Counter & Depth)
* **計數器遞增/遞減：** * 若只有 `push`，計數器必加 1。
    * 若只有 `pop`，計數器必減 1。
    * 若同時 `push` 和 `pop`，計數器應保持不變。
* **最大深度：** 計數器的值永遠不可超過 FIFO 的 `DEPTH`。

### 4. 握手協議與時序 (Interface Handshaking)
如果你的 FIFO 介面是 AXI-Stream 或類似的 Ready/Valid 協議：

* **Valid 穩定性：** 當 `valid` 拉高但 `ready` 為低時，`valid` 必須保持為高，且 `data` 內容不可變動，直到 `ready` 變高完成握手。
* **連續讀寫：** 測試在連續 `push` 到滿、連續 `pop` 到空的極端切換。

---

### 5. 建議增加的 Assertion 行為列表 (可直接轉化為程式碼)

| 行為分類 | 描述 (Assertion Logic) |
| :--- | :--- |
| **Overflow** | `assert property (@(posedge clk) full && push |-> ##1 (error_flag));` |
| **Underflow** | `assert property (@(posedge clk) empty && pop |-> ##1 (error_flag));` |
| **Full Delay** | 當 counter 達到 `DEPTH` 時，下一個週期 `full` 必須為 1。 |
| **Empty Recovery** | 當最後一筆資料被 `pop` 後，下一個週期 `empty` 必須變為 1。 |
| **Toggle Coverage** | 確保 `full` 和 `empty` 都至少被觸發過高與低狀態。 |
| **Read-While-Write** | 在 `full` 的狀態下同時進行 `push` 與 `pop` (如果支援)，檢查 `full` 是否正確維持。 |

---

### 💡 提升 Coverage 的小技巧

為了確保你的 Assertion 真的覆蓋了所有行為，你可以檢查以下 **Corner Cases**：
1.  **Wrap-around:** 當寫入指針或讀取指針到達地址頂端並回到 0 時。
2.  **Back-to-back:** 連續的單週期切換 `push` 與 `pop`。
3.  **One-entry:** 只有一筆資料在 FIFO 裡面的行為。
4.  **Simultaneous:** 同時發生 `push` 和 `pop` 且 FIFO 正好處於 `empty` 或 `full` 的邊界。

針對你之前的問題，如果你寫了 `(icpen == 0 && wrtrmp == 0)` 的 Assertion 卻一直跑不到 (No hit)，你可以試著寫一個 **Cover Property** 來確認這兩個變數在模擬過程中是否真的有「同時為 0」的機會：
`cover property (@(posedge clk) icpen == 0 && wrtrmp == 0);`

如果 Cover report 顯示這條沒被滿足，那就說明你的 Testbench (Stimulus) 根本沒有產生這種情境，或是硬體邏輯上鎖死了這個組合。

在你的設計中，`icpen` 和 `wrtrmp` 是否有特定的優先順序（例如其中一個為 1 時，另一個必然不為 0）？


---

# Formal Goal
### 1. 關鍵協議與微架構的「Bug Hunting」經驗
公司最想看的是你如何處理那些「模擬驗證難以觸發」的深層邏輯錯誤。
* **重點經驗：** 針對 **AXI / ACE / PCIe** 等複雜匯流排協議，或 **Arbiter (仲裁器)**、**Credit-based flow control** 的驗證。
* **面試考點：** 你如何定義 Assertions (SVA) 來捕捉 Corner Case？當 Formal 跑不完 (Complexity issue) 時，你用了什麼 **Abstraction (抽象化)** 技巧？（例如：Data Invariant、Black-boxing、減少 Counter 位元數等）。

### 2. 形式驗證的「Sign-off」流程經驗
單純找到 Bug 只是第一步，公司更看重你是否知道何時可以說「這個模組驗證完了」。
* **重點經驗：** 如何處理 **Full Proof (完整證明)**。如果你在 JasperGold 裡只跑出一個 Bounded Proof (深度有限的證明)，你該如何向主管證明這已經足夠？
* **面試考點：** 你是否熟悉 **Formal Coverage (如 JasperGold 的 Unreachability / Observeability coverage)**？如何判斷哪些過不去的 Proof 是真正的設計缺陷，還是因為 Constraints (Assume) 寫得太緊？

### 3. 特殊應用場景 (Special Apps) 的工具運用
現在公司非常強調用「專門的 App」解決特定痛點，這比自己寫 SVA 更有商業價值：
* **CDC (Clock Domain Crossing) Formal：** 證明非同步時鐘域轉換時不會產生亞穩態或數據丟失。這是目前業界 FV 最普遍的用途。
* **SEC (Sequential Equivalence Checking)：** 當設計為了省電做了 Clock Gating 或改了 Pipeline，你如何用 SEC 證明改版前後的功能完全一致？這對產品迭代非常重要。
* **Connectivity Checking：** 對於數百萬門電路的 SoC，證明 Pin 對 Pin 的連線正確。

---

### 如何包裝你的 AXI-to-APB Bridge 練習經驗？
既然你正在做這個 7 天的 side project，建議在履歷或面試中強調以下細節：

* **不要只說：** 「我用 JasperGold 驗證了 AXI-to-APB Bridge。」
* **要這樣說：** > 「我針對 AXI-to-APB Bridge 建立了 Formal 驗證環境，重點在於證明 **Outstanding Transaction** 在極端壓力下的資料完整性。我透過撰寫 **Liveness Assertions** 成功找出了在特定 Back-pressure 情況下可能導致的 **Deadlock** 問題，並利用 **Symbolic Variables** 減少了 40% 的證明收斂時間。」

### 實戰建議
既然你有 3 年 DV 經驗且熟悉 UVM，面試官常會問：**「這部分為什麼不跑 Simulation 而要用 Formal？」**
你必須能回答出：
1.  **效率對比：** Simulation 需建構完整 Testbench 才能動，Formal 只要 RTL 完成就能提早介入 (Shift-left)。
2.  **信心維度：** Simulation 是機率性的，Formal 是數學證明的 100% 覆蓋。

你目前在 AXI-to-APB 的練習中，有試著寫出一些能觸發 Counter-example (反例) 的錯誤邏輯嗎？這通常是理解「收斂」最快的方式。

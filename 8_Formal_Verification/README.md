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

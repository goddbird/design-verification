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

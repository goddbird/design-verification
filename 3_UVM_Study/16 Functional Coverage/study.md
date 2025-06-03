# 目標

將functional coverage整合到
🧩 interface-level UVC（從 monitor 提取資訊）
🧠 module-level scoreboard（確認行為 + 分析 coverage）

---
 
## 介紹
### Explicit Coverage
#### Assertions
1. 用來檢查訊號的時序關係、事件順序
2. 使用程序區塊
3. 無法在class裡面被定義  

##### Covergroup
1. 用來收集資料組合、交叉值、特定輸入範圍的出現次數
2. 可以被宣告為class
3. 在interface or module裡面使用

# 目標

1. 介紹register modeling的目的
2. 建立一個register的reference model
3. 如何把model加入環境中
4. 在simulation中打出自定義的stimulus

---
# 介紹
UVM register model是一種high level的abstract class，用來對DUT中有地址映射的register跟memory進行建模，可以反映DUT中register的各種特性，也可以產生Stimulus對DUT的register進行檢查，透過UVM register model可以進行front door / back door的操作。
![image](https://github.com/user-attachments/assets/1c66938f-8323-4197-a267-7628514cce0e)


# 驗證register的流程如下
![image](https://github.com/user-attachments/assets/088a009b-e0d4-4f29-9032-37828ec39055)

1. 建立一個 Register Reference Model
包含每個 register 的：
位址、寬度、reset 值
權限（RW / RO）
這些資訊由 uvm_reg, uvm_reg_field, uvm_reg_block 等類別描述
是 RTL register 的「影子版本」，用來做比對

2. 使用 sequence 去存取 DUT register
透過 HBUS UVC 傳送 read/write 訊號
ex: reg_model.ctrl_reg.write(status);

3. 更新 register model
如果成功寫入 DUT，register model 就也更新對應值
讀的時候則比對實際讀值與 model 預期值是否一致

4. 比對 DUT register vs. model
會呼叫 UVM 內建的 mirror / predict 機制
若發現 mismatch，會報 error：表示 RTL register 行為有問題

# UVM register model架構
🔍 功能總結：
| 功能                       | 說明                                           |
| ------------------------ | -------------------------------------------- |
| **階層式建模**                | `uvm_reg_block` → 包含多個 `uvm_reg` 和 `uvm_mem` |
| **註冊 register 屬性**       | 包含 address、大小、reset 值、讀寫權限（RW/RO）等           |
| **名稱與位址綁定**              | 可用 `.write("en_reg", value)` 來操作，不需用地址       |
| **保留 shadow copy**       | 每個 reg 實例會保有預期值，可做比對                         |
| **支援多 address map**      | 適用於 multi-interface case，例如 AXI vs. APB      |
| **支援 register coverage** | 可整合 covergroup 追蹤 register 的使用情況             |
| **模組化/可重複使用**            | reg block 可直接帶入到不同專案中                        |

🧠 你可以這樣想：
UVM register model 讓你不用自己去記每個 register 在哪裡、初始值是什麼，也不用自己寫 checker 去比對結果。你只要：
- 在 uvm_reg_block 寫好 reg 架構
- 在 uvm_reg_adapter 連結 reg model 與 bus UVC
- 用 .read() / .write() 和 .mirror() 自動做驗證
---

# Register API Access Methods
![image](https://github.com/user-attachments/assets/2671798e-d67b-422d-908e-b4503e6be9a8)  
![image](https://github.com/user-attachments/assets/a909abe3-8ce9-4dc4-9106-8beedad39ae5)


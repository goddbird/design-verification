# UART spec
1. parity / data length
2. CTS/RTS testcases

## Quick Guide
### Data length / Parity
✅ 1. Parity / Data Length  
  🔸  Data Length（資料長度） 
UART 傳輸資料時，一個 frame 通常包含：   
Start bit + Data bits + Optional parity bit + Stop bit(s)   
Data bits 可設定為 5, 6, 7, 8 或有些支持到 9 bits。    
測試重點：  
不同 data length 的傳送與接收正確性  
長度設定不一致時的 error handling  

  🔸  Parity（同位檢查）  
一種簡單錯誤偵測機制   
常見選項：   
None（無同位）
Even parity（偶同位）：若資料位中 1 的個數為奇數，則 parity bit 為 1，使總數為偶數   
Odd parity（奇同位）：相反，使總數為奇數    
測試重點：  
parity enable/disable 是否生效  
傳送錯誤 parity 時接收端是否能偵測  

### CTS/RTS
CTS (Clear To Send)   : 
- Transmitter 發送資料前會檢查 CTS 訊號。
- 如果 CTS 為 High，表示 “不要發送”
- 是由接收端控制（Mode: in 表示對 transmitter 而言這是輸入）
  
RTS (Request To Send) :
- Receiver 根據其 FIFO 狀態來決定是否可以接受更多資料
- 當 FIFO 滿到超過某個門檻時，RTS 拉高，表示「不要送了」
- 由接收端主動控制 RTS（Mode 是 out 相對於接收器）

## 舉例
AP與MODEM的流控這樣通訊的：
AP串口可用時，將AP-RTS拉低，MODEM-CTS檢測到AP-RTS為低，知道AP串口已準備好，可以發送資料；
AP串口不可用時，將AP-RTS拉高，MODEM-CTS檢測到AP-RTS為高，知道AP串口還未準備好，就不會放資料。


好像需要去安裝VIP?
![image](https://github.com/user-attachments/assets/47f31472-3f4c-4c92-94e7-58324a994532)

---

✅ 2. Terminology 重點對照表
| 術語                                             | 定義                                   | 用途 / 備註                     |
| ---------------------------------------------- | ------------------------------------ | --------------------------- |
| **\$CDN\_VIP\_ROOT**                           | 環境變數，指定 VIPCAT 安裝目錄的 root 路徑         | 用於設置 VIP 模型執行環境             |
| **\$DENALI**                                   | 環境變數，指向 `$CDN_VIP_ROOT/tools/denali` | 與 Denali VIP 工具路徑有關         |
| **BFM (Bus Functional Model)**                 | 驗證軟體模擬的某個 protocol 或 device 行為       | 例如 UART BFM 就是模擬 UART 傳輸    |
| **DDVAPI (Data-Driven Verification API)**      | 擴充 VIP 的應用層 API，允許模擬中整合外部應用程式        | 進階用法，例如 script 控制模擬         |
| **DUT (Design Under Test)** / **DUV**          | 被驗證的實際設計電路                           | 例如你的 UART RTL               |
| **PureView**                                   | Cadence 提供的 GUI，用來設定 VIP 產品          | 可產生 SOMA 與 HDL interface    |
| **HDL Instantiation Interface**                | HDL 設計單元，用於在設計中實例化 VIP 模型並連接訊號       | 例：`uart_model u_uart(...);` |
| **SOMA (Specification of Model Architecture)** | Cadence 自定的格式，用來配置模型參數化資訊            | 像 JSON 或 XML 檔，告訴 VIP 怎麼工作  |



這是個很好的問題！這份 **Cadence UART VIP 文件** 的確資訊很多，如果你希望快速理解並能實際動手驗證、寫 test case，建議採取 **「搭配文件 + 動手實驗 + 模組拆解學習」的策略**，以下是具體建議：

---

# 要怎麼跑起來
![image](https://github.com/user-attachments/assets/5eb5c3c6-d704-464b-a238-04686059993d)


# 先研究那個log
Script中可以指定要跑哪個test (+UVM_TESTNAME)
![image](https://github.com/user-attachments/assets/17f9fc54-1aaf-40b4-bdf8-7f5a40f2e839)


# Topology
![image](https://github.com/user-attachments/assets/eb811a9c-1bf0-4dfe-a7dc-5827fe1478a5)


# Virtual Sequence
## cdnUartUvmVirSeqModeSwitchConfigTx

A. 內部有兩種seq
cdnUartUvmModeSwitchConfigSeq
cdnUartUvmSeqTx

B. virtual seqr: cdnUartUvmUserSequencer

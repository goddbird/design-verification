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

## 使用Macro  CDN_UART_UVM_TEST
0. 透過上方的script知道test name為cdnUartUvmTestModeSwitchExample
1. 指定cdnUartUvmTestModeSwitchExample這個class要打特定virtual seq: cdnUartUvmVirSeqModeSwitchConfigTx
要打uartModeSwitchExample這個test
![image](https://github.com/user-attachments/assets/59ba7e9b-dc1b-46ce-aff6-e6e497d10a12)  
2. 這個virtual seq內部會執行cdnUartUvmModeSwitchConfigSeq / cdnUartUvmSeqTx
![image](https://github.com/user-attachments/assets/5efea5bd-8dde-43a4-96e5-d181fda3f949)



# Topology
![image](https://github.com/user-attachments/assets/eb811a9c-1bf0-4dfe-a7dc-5827fe1478a5)


# Virtual Sequence
## cdnUartUvmVirSeqModeSwitchConfigTx

A. 內部有兩種seq
cdnUartUvmUserSequenceLib.sv / cdnUartUvmModeSwitchConfigSeq : 送這個的目的是什麼，研究一下register
Flow整理
cdnUartUvmModeSwitchConfigSeq:
1. config tx，送txn到sourceSeqr
2. 先確認架構:
有哪些agent跟seqr?
如下圖，找到架構的檔案在cdnUartUvmAgent.sv，裡面有真的monitor/drive/sequnecer
再上層就被cadence加密包起來了。
![image](https://github.com/user-attachments/assets/43a2007e-fc6a-4428-9abe-cc3439d8ff9e)
3. Env裡有3個Agent: tx, rx, dut
![image](https://github.com/user-attachments/assets/93e6fdd5-2c5f-4f8c-a59e-7d348a5be2bd)





|步驟|Line|Register|用處|
|-|-|-|-|
|1|201|DENALI_UART_REG_CTRL_CONFIG_BEGIN|對vip初始化，設定後就可以開始配置UART|
|2|202|DENALI_UART_REG_CTRL_INTERRUPT_ENABLE|讓Interrupt enable|
|3|209|DENALI_UART_REG_CTRL_UART_CONTROL|設定可傳可收，並設定取樣精度(速度越快精度越低)![image](https://github.com/user-attachments/assets/f62d45d5-6e6d-4a9d-a79e-985d31eacc69)|
|4|215|DENALI_UART_REG_CTRL_LINE_CONTROL|可指定資料位數，不包含parity bit, stop bit，可包含5-8bitsEnable parity![image](https://github.com/user-attachments/assets/6e0c04fe-abb6-4a0a-b71b-031215f042b6)|
|*5|228|DENALI_UART_REG_CTRL_MODEM_CONTROL|控制RTS / 控制loop back![image](https://github.com/user-attachments/assets/ae1457d3-b108-46ad-b23a-37d167879f2e)|
|*6|234|DENALI_UART_REG_CTRL_FIFO_CONTROL|清空FIFO，RXTRIG確認多少資料量(1B, 4B, 8B, 14B)觸發中斷。提問，感覺VIP設定的BIT345欄位跟code的1'b0有出入![image](https://github.com/user-attachments/assets/dd51042a-37be-4d7d-bb56-dfc40e5ba87f)|
|7|241|DENALI_UART_REG_CTRL_CONFIG_DONE|把CONFIG推進config queue|
|8|244|uvm_do_with|把CONFIG透過WRITE_REG推進config queue，藉此送txn可以讓VIP/monitor知道有這樣的設定行為|

||||
|-|-|-|
|![image](https://github.com/user-attachments/assets/c7cc0b6a-4522-417c-9101-4573b9ca93af)|![image](https://github.com/user-attachments/assets/730634d3-3943-4c77-ac5e-1146c9d3c465)|![image](https://github.com/user-attachments/assets/a7aa6848-f759-4fb5-aedc-b8ec439318ef)|

![image](https://github.com/user-attachments/assets/c9bb0421-2587-44c9-a71a-68e4d50d36ac)


cdnUartUvmSeqTx

B. virtual seqr: cdnUartUvmUserSequencer


# Total Flow
cdnUartUvmVirSeqModeSwitchConfigTx
1. 有兩個handle : config / Txn，分別的作用為 (把TX agent的UART control register寫好 / 實際發封包用的Sequence Handle)
2. config seq會打transaction，且body內部會有對RAL的設定
![image](https://github.com/user-attachments/assets/fb3ae5eb-0bb4-49ab-9a3d-f24e4dbc72ee)
3. config sequence打出去後，會打正常的tx/rx封包，再monitor裡面若觀察到一個tx/rx行為完成，就會trigger_data()通知外界
外面就會wait_trigger_data等他完成了。
而註冊的callback，這點寫在VIP裡面，所以Packet完成後呼叫哪個callback我們不會知道。
小馬說，其實每傳一個bit，現在的資料處理到哪裡，比如data or parity，這都會呼叫不同callback。
![image](https://github.com/user-attachments/assets/adb94888-c605-4250-b19f-4164da6d21d7)
4. 818行開始要切換成Sync, Full Duplex mode  (RX )，後面會有half duplex mode


實體sequence:
cdnUartUvmModeSwitchConfigSeq
cdnUartUvmSeqTx
CDN_UART_UVM_TEST(className, sequenceName, testName, trCount)
下圖有很多test
![image](https://github.com/user-attachments/assets/f7972e6f-9924-46e6-883c-f96f632d7227)

# 現階段要做的事情
![image](https://github.com/user-attachments/assets/9f2f1655-0e11-4a91-bbbd-6dfa9c3c02fb)

# 了解cdnUartUvmTestEvenParity128000
CDN_UART_UVM_TEST
![image](https://github.com/user-attachments/assets/58c8f478-f8d6-4263-8058-2d8c79bda4ad)
解釋 :  
![image](https://github.com/user-attachments/assets/9fa18c7b-507c-4b01-8ea3-d781cfeb8907)

## Sequence
![image](https://github.com/user-attachments/assets/46068ff9-2d83-4141-a786-b2c8e25869d7)

## Transaction
下圖先用constraint把各個參數鎖死
div_latch = 0x49 (這個跟Baudrate有關係)
baudrate = clk_freq / (16 * 0x49)
=> 128000 = clk_freq / (16 * 0x49) => clk得到6.7ns
![image](https://github.com/user-attachments/assets/6f07e3db-b4dd-4ca5-a9db-26c463aa30bc)


|Reg|意義|
|-|-|
|ier_modem_status||
|ier_rx_line_status||
|ier_tx_holding_reg_empty||
|||
|||


![image](https://github.com/user-attachments/assets/30c9e69c-05d7-4e44-94c5-2edd68d69d9d)


想要改跑EvenParity128000
卻失敗了
![image](https://github.com/user-attachments/assets/404251c7-8cf9-4ce2-91e5-341d2e56b491)
![image](https://github.com/user-attachments/assets/1068ae57-74ce-4dc2-b669-d7e840be621c)


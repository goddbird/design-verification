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


好像需要去安裝VIP?
![image](https://github.com/user-attachments/assets/47f31472-3f4c-4c92-94e7-58324a994532)

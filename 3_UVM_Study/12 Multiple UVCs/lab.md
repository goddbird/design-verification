![image](https://github.com/user-attachments/assets/25faa009-d98c-4604-b9f6-460bcc474d64)
建立一個multiple UVC，並且連接&配置HBUS, channel, clock/reset UVC
# 介紹
YAPP 傳資料，HBUS 控制哪裡能收、何時送等，看 Router 是否能正確分配到 CH0~CH2。  


# Summary
driver: 

# 問題
1. 為什麼hbus master/slave不需要monitor?
📌 為什麼不用 monitor？
在 UVM 裡，monitor 主要是用來觀察 DUT 傳出來的資料、做 scoreboard、coverage、protocol check 等
而 master/slave 都是主動參與傳輸的 agent，傳什麼、收什麼都在 driver 中明確定義了，不需要 monitor 來額外觀察，除非你有要做 bus snooping（像 AXI monitor），才需要加 monitor 來做 cross-check
2. 

# 進度
1. 先讓run能動
2. 確認uvm topology : 沒辦法，因為沒設定對應的channel vif
![image](https://github.com/user-attachments/assets/321ec0d2-1dad-440b-988a-f51fa37c20f2)
3. 在tb level控制channel_env: uvm_config_int::set(this, "chan0", "channel_id", 0);
並把對應channel設定值
4. 發現hbus沒有設定好對應的vif，hbus還有分master/slave
可以透過以下設定，在tb_top一口氣把hbus裡有使用到interface get的全部set好
![image](https://github.com/user-attachments/assets/0189c6e1-7e22-48de-bb2a-078eb17d82d2)
5. 發現假如要讓原本是hw_top控制的reset訊號，交由clock_and_reset_if來控制時，需要把原本在initial begin控制的reset訊號那段code註解掉，然後把reset的操作寫在if裡面。
6. 做Router & 其他component連線
發現會在hbus碰到問題，hb.hdata是logic，但是內部因為assign inout = logic，造成下面的錯誤
![image](https://github.com/user-attachments/assets/f2be6d25-b203-4f39-b8a7-dee9e020c197)
解法是  
![image](https://github.com/user-attachments/assets/a4dae6e9-6ba0-43fe-ae70-9694a30d6055)  
![image](https://github.com/user-attachments/assets/ee246c8c-32d3-4a9a-b215-17b110e76e9b)


|router|channel_if|hbus_if|  
|-|-|-|  
|![image](https://github.com/user-attachments/assets/9551a378-e3e0-4df1-a353-7eccc4325576)|![image](https://github.com/user-attachments/assets/25adb8d4-f14e-46cd-b54b-43e0e52147bc)|![image](https://github.com/user-attachments/assets/d0d6eddd-7421-4f72-a90d-a7687411f487)|

# 做到第10個步驟
做waveform的確認，加入一些cmd到run裡面 :
![image](https://github.com/user-attachments/assets/f02569ab-cede-4571-a50f-c196106b46e0)  
發現sequence卡住了，gpt說是先確認driver/seqr有沒有接好
但現在看起來有接好TLM，比較像是reset訊號沒振，造成卡住，但是現在simvision看不到波型
![image](https://github.com/user-attachments/assets/ba41dd5d-e291-405f-83fb-96ed77d26d22)  
找到問題了，確實是打seq時，那範例code需要reset訊號
但reset訊號放進一個UVC (clock_and_reset)裡面做控管
然後沒讓clock開始跑，就不會讓reset訊號做改變這樣 => 導致沒打sequence

現在是運行好像有點問題，打中了這個assert
先看lab6為什麼要加，並且了解assert
![image](https://github.com/user-attachments/assets/ecd83cc0-1941-4b58-ab64-04bb682499f5)  

---
解讀
![image](https://github.com/user-attachments/assets/c990b655-84bd-4a6e-952c-4e5e992b9145)
結論 : 觀察的 in_suspend 沒有在期望的 20 個 clock 後變為 0，是因為下面兩個條件之一可能沒有被滿足：
in_suspend = !fifo_empty && in_data_vld組成，fifo_empty=0   in_data_vld=1 才會一直讓in_suspend為1
抓以下這些訊號出來看，先確認是否沒send_to_dut()
![image](https://github.com/user-attachments/assets/72416c41-6847-4e06-a558-e6fb84b6b7c2)
clk = 10 ns

|1st|2nd|3rd|
|-|-|-|
|![image](https://github.com/user-attachments/assets/4ecd654e-3042-41bd-a608-b3dc3fac211e)|![image](https://github.com/user-attachments/assets/032abd40-8f6e-4e59-9bd1-290cc520b88c)|![image](https://github.com/user-attachments/assets/3c8a89ee-b20f-4859-b81d-6b3a17b5ad5f)
|
看起來比較像state沒有如預期切換，in_data_vld舉high後，應該要切state至1
![image](https://github.com/user-attachments/assets/8286a04f-cfd4-414f-898d-8003f09c15f4)

後續發現state沒有切換到DATA_LOAD是因為fifo_empty2一直都為0，沒有變成1，就被assert卡住了，確認一下
![image](https://github.com/user-attachments/assets/ffd9a8b3-427f-4e1d-ae22-45de665674b8)
Log


連寫了兩次ch2，確認一下ch2:
1. 是不是滿了?  為何full沒舉?
2. wptr有對?  是對的! 
但為什麼長度寫13，卻有15筆
看起來是資料的payload有13 Byte，但卻送了15筆出來的概念
3. 為何沒有read enable?
4. 為什麼fifo_empty0, `145ns可以從0->1，明明沒有read` => 因為fifo_empty = empty0 | addr[0]| addr[1]|
=> 意思是，我想寫ch2的時候，我想看總fifo_empty是否可以push，所以想寫ch2就跟ch0沒關係，ch0的empty就會變1

而fifo_empty, 155ns卻從1->0然後起不來


現在看起來比較像是channel_rx_resp_seq沒辦法正常seq/driver之間溝通
下面這個適合印log
![image](https://github.com/user-attachments/assets/937e6e80-b9d9-4f06-895c-de03b2b555b7)


有透過下方的log發現channel if會一直卡在send_response這隻函式裡面，因為resp_delay太大
透過下圖把constraint改小後，就會pass了
![image](https://github.com/user-attachments/assets/e7ef903e-ee3e-46c4-a567-6295b31ec0a9)

![image](https://github.com/user-attachments/assets/875b0835-e4c2-4a44-aabe-96a9d0abab80)

使用wildcard對UVC的ch0, ch1, ch2作全部的default sequence設定
![image](https://github.com/user-attachments/assets/b2159aa6-4a8b-44cc-9c2e-55c24d0c3b87)


問題集錦: 
1. YAPP router 透過 tx 發出 transaction（txn）後，UVC channel 的 rx 是怎麼知道要收數據的？
yapp裡面有fifo，driver收到txn後，丟給DUT的input，會丟進DUT裡面的FIFO進行儲存，之後read_enb後會從FIFO拿出來。
拿出來後，會當作DUT的output。
DUT output會跟UVC ch0, ch1, ch2做連接 (用if去接)，變成它們的input，收到這些input後，monitor會宣告一個packet實例，並使用vif的collect_pkt去接這些input，最後顯示出來。



✅ 精簡版流程總結（優化版）
1. YAPP router 的 TX agent driver  
透過 seq_item_port.get_next_item() 取得 sequence 送來的 transaction (txn)，並把資料送到 DUT 的輸入介面（通常是 FIFO 的 write port）。

2. DUT 接收 TX 傳來的資料  
TX driver 寫入資料到 DUT 的 input FIFO。等到 DUT 的讀取條件成立（例如 read enable asserted），DUT 就會把資料從 FIFO 讀出，並將其送到對應的 output port。

3. DUT output port 對應到各個 channel interface  
這些 output 資料會經由 channel_if interface 分別傳送給 channel_0, channel_1, channel_2 等不同的 UVC instance。

4. UVC 的 monitor 偵測 channel_if 上的資料變化  
monitor 呼叫 vif.collect_pkt() 來在 bus 上監控：
  - data_vld 是否為 valid
  - suspend 是否解除
  - clock edge 到來
當上述條件都符合時，monitor 就會抓取 DUT output 上的長度、地址、payload、parity 等資訊。

5. monitor 將收集到的資料封裝成一個 channel_packet txn  
透過 analysis_port.write(pkt)，將 packet 傳給下游的 component（例如 scoreboard 或 coverage collector）。

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



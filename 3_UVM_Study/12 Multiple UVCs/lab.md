![image](https://github.com/user-attachments/assets/25faa009-d98c-4604-b9f6-460bcc474d64)
建立一個multiple UVC，並且連接&配置HBUS, channel, clock/reset UVC
# 介紹
YAPP 傳資料，HBUS 控制哪裡能收、何時送等，看 Router 是否能正確分配到 CH0~CH2。  



# 進度
1. 先讓run能動
2. 確認uvm topology : 沒辦法，因為沒設定對應的channel vif
![image](https://github.com/user-attachments/assets/321ec0d2-1dad-440b-988a-f51fa37c20f2)
3. 在tb level控制channel_env: uvm_config_int::set(this, "chan0", "channel_id", 0);
並把對應channel設定值
4. 發現hbus沒有設定好對應的vif，hbus還有分master/slave
可以透過以下設定一口氣把hbus裡有使用到interface get的全部set好
![image](https://github.com/user-attachments/assets/0189c6e1-7e22-48de-bb2a-078eb17d82d2)


# Summary
driver: 

# 問題
1. 為什麼hbus master/slave不需要monitor?
📌 為什麼不用 monitor？
在 UVM 裡，monitor 主要是用來觀察 DUT 傳出來的資料、做 scoreboard、coverage、protocol check 等
而 master/slave 都是主動參與傳輸的 agent，傳什麼、收什麼都在 driver 中明確定義了，不需要 monitor 來額外觀察，除非你有要做 bus snooping（像 AXI monitor），才需要加 monitor 來做 cross-check
2. 

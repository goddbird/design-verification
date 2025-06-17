![image](https://github.com/user-attachments/assets/25faa009-d98c-4604-b9f6-460bcc474d64)
建立一個multiple UVC，並且連接&配置HBUS, channel, clock/reset UVC
# 介紹
YAPP 傳資料，HBUS 控制哪裡能收、何時送等，看 Router 是否能正確分配到 CH0~CH2。  



# 進度
1. 先讓run能動
2. 確認uvm topology : 沒辦法，因為沒設定對應的channel vif
![image](https://github.com/user-attachments/assets/321ec0d2-1dad-440b-988a-f51fa37c20f2)


# Summary
driver: 

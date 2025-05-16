![image](https://github.com/user-attachments/assets/139d1022-58ef-4b70-8721-feddb7f82adf)
目標 : 產生一個yapp packet，並測試uvm的一些函式 : copy, clone, print

| 功能         | 說明                              |
|--------------|-----------------------------------|
| `copy`       | 複製 UVM 物件內容                 |
| `clone`      | 建立與原物件內容相同的新物件       |
| `print`      | 印出物件的內容資訊（debug 用）     |


| yapp_pkg.sv | yapp_packet.sv | top.sv | log |
|-------------|----------------|--------|-----|
| ![image](https://github.com/user-attachments/assets/65b370c4-d996-4ae2-8ef7-2d4ffa659263)  | ![image](https://github.com/user-attachments/assets/c4dca6be-ae93-43fb-82e9-44c73d98824b) | ![image](https://github.com/user-attachments/assets/b4325173-0854-4b59-b471-10ddb15381f1) | ![image](https://github.com/user-attachments/assets/be6078cb-55b4-4fab-88ab-57528359e3c3) |
|Pkg可以先import pkg, macro那些東西 <br> 然後再把設計的packet.sv檔include進來 <br> 讓他看到import pkg相關的檔案，避免compile error|----------------|--------|-----|

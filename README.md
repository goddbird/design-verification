# design-verification
This is my personal workspace for after-hours self-study. 
To accelerate my growth in the Design Verification (DV) field, I am focused on mastering the essential skills as efficiently as possible.
This repository show my practical projects and implementations—feel free to explore!
All these project file can be executed on simulation. My project environment is based on xrun.

## Protocol VIP (from easy -> hard)
### APB
[`/6_APB_VIP`](https://github.com/goddbird/design-verification/tree/main/6_APB_VIP)

----

### AHB
[`/5_AHB_VIP`](https://github.com/goddbird/design-verification/tree/main/5_AHB_VIP)

----

### AXI
[`/4_AXI_VIP`](https://github.com/goddbird/design-verification/tree/main/4_AXI_VIP)

----

### I2C
[`/9_I2C_VIP`](https://github.com/goddbird/design-verification/tree/main/9_I2C_VIP)

## Formal Verification
[`/8_Formal Verification`](https://github.com/goddbird/design-verification/tree/main/8_Formal_Verification)

## Verification Management
- Verification Plan: [`/dv_docs/verification_plan.md`](./dv_docs/verification_plan.md)
- Traceability Matrix: [`/dv_docs/traceability_matrix.md`](./dv_docs/traceability_matrix.md)

----

# Work Station
一、 MobaXterm 使用步驟（輕量 X11 轉發）
這是在 Windows 上操作 Linux 最簡單的方式，它內建了 X-Server，能直接把 Linux 的圖形介面「投射」到 Windows 視窗中。

1. 下載與安裝
去 MobaXterm 官網 下載 Home Edition (Portable) 版本，免安裝解壓縮即可使用。

2. 建立連線
點擊左上角的 Session -> SSH。

Remote host: 輸入你家 Linux 工作站的 IP（例如 192.168.1.100）。

Specify username: 勾選並輸入你的 Linux 帳號。

確認 Advanced SSH settings 分頁中的 X11-Forwarding 是勾選狀態。

點擊 OK 並輸入密碼。

3. 開啟圖形程式
在連線後的終端機直接輸入指令：

Bash
verdi &
# 或者測試用的簡單時鐘
xclock
這時你會發現 Verdi 的視窗直接跳出來在你的 Windows 桌面上，就像原生程式一樣。

二、 NoMachine 使用步驟（高效能遠端桌面）
如果你需要長時間 Debug，或希望斷線後模擬程式繼續跑、下次連回去畫面還在，請選 NoMachine。

1. 安裝端 (Linux 工作站)
去 NoMachine 官網 下載對應 Linux 版本（如 .deb 或 .rpm）。

安裝後，NoMachine 服務會自動啟動，並在系統列顯示一個 !M 圖示。

點擊圖示查看 Linux 的 IP 地址。

2. 使用端 (你的 Windows 筆電)
同樣下載 Windows 版的 NoMachine 並安裝。

開啟軟體，點擊 Add，輸入連線名稱與 Linux 的 IP 地址。

連線時選擇 NX 協定（預設 Port 4000）。

輸入 Linux 的帳號密碼，即可進入完整的 Linux 桌面。

# AXI Introduce
<img width="801" height="554" alt="image" src="https://github.com/user-attachments/assets/11a22ad9-3f7e-4386-8950-f2aa92292e7f" />
<img width="980" height="761" alt="image" src="https://github.com/user-attachments/assets/62da5180-b67a-4fef-9d67-e996ee877558" />

---

# My AXI VIP Architecture
<img width="853" height="583" alt="image" src="https://github.com/user-attachments/assets/0ed45c55-7a7c-4cec-ac0e-694ec7d14ca3" />

---

# My AXI VIP Topology
```
axi_vip/
├── axi_if.sv                ←【介面】實體訊號、modport
│
├── axi_pkg.sv               ←【總入口】import 所有 class
│
├── transaction/
│   └── axi_txn.sv     ←【交易】抽象的一次 write 行為
│
├── sequence/
│   └── axi_write_seq.sv     ←【刺激】產生一堆 write txn
│
├── agent/
│   ├── axi_driver.sv        ←【執行者】把 txn 變成 pin-level AXI
│   ├── axi_monitor.sv       ←【觀察者】從 pin-level 還原 txn
│   ├── axi_sequencer.sv     ←【排程器】管理 sequence
│   └── axi_agent.sv         ←【整合】driver + monitor
│
├── env/
│   └── axi_env.sv           ←【環境】放一個或多個 agent
│
├── test/
│   └── axi_write_test.sv    ←【測試】選 sequence 跑 
│
├── sva/
│   └── axi_assertions.sv    ←【SVA】確認WLAST訊號如預期變化
│
└── top/
    └── tb_top.sv            ←【最上層】DUT + VIP + vif config_db + clock/reset
```
# Feature - outstanding
Why do we need outstanding transaction on AXI?
There is latency due to bus interconnects and slave internal processing. Without outstanding, the Master would remain idle while waiting for responses.
With outstanding capabilities, the Master can utilize a pipeline to hide/cover the latency.

# Compare AXI - AHB
<img width="671" height="670" alt="image" src="https://github.com/user-attachments/assets/9b38076d-5007-460a-86c2-6c035edaf00f" />

TODO
transaction物件（axi_txn）
確認有id欄位，能區分不同transaction（你已經有id欄位）。

driver/monitor支援多筆追蹤

driver：能同時送出多個AW/W或AR，並追蹤每筆id。
monitor：能同時記錄多個id的write/read，並正確配對response。
scoreboard比對

scoreboard要能根據id比對每筆transaction的response。
sequence產生多筆同時的transaction

sequence可隨機產生多個id、同時送出多筆write/read。
建議步驟：

先從monitor下手，讓它能同時追蹤多個id的write/read（用queue或hash table記錄每個id的狀態）。
driver再調整，支援同時送出多筆AW/W或AR。
最後調整scoreboard與sequence。

---
TODO
總覽

測試層決定要不要開 multi-issue。
sequence 連續送出多筆交易（ID 會重複）。
driver 用 mailbox 把 AW 與 W 拆開，形成可重疊的 outstanding。
DUT 內部用 AW queue + 寫入狀態機消化請求，B 用 pending counter 回應。
checker/monitor/scoreboard 各自追蹤 outstanding 狀態，最後在 run phase 等 bus 清空再結束。
第一步到最後一步

在 test 開啟 outstanding 模式
在 axi_test.sv:14 設定 enable_multi_write_issue=1，
在 axi_test.sv:15 設定 max_outstanding_aw=4。
這代表 driver 允許最多 4 筆 AW 在外面飛。

sequence 產生多筆、可重複 ID 的交易
在 axi_write_seq.sv:13 到 axi_write_seq.sv:22 先送 10 筆 write。
ID 是 $urandom_range(0,7)，所以重複是正常設計。
接著在 axi_write_seq.sv:27 到 axi_write_seq.sv:43 混合 read/write。

driver 收到交易後，分流成 AW 路與 W 路
driver 宣告 aw_inflight 與三個 mailbox 在 axi_driver.sv:29。
啟動時讀設定在 axi_driver.sv:58。
多工流程是：

AW handshake 就 aw_inflight++： axi_driver.sv:72
B handshake 就 aw_inflight--： axi_driver.sv:74
發 AW 前先等 aw_inflight < max_outstanding_aw： axi_driver.sv:106
AW 與 W 拆成不同執行緒： axi_driver.sv:104, axi_driver.sv:119
AW 真的打到 bus 時會帶 debug id
driver 在 AW phase 把 tr.id 打到 DBG_AWID： axi_driver.sv:182。
這是目前 bench 的「ID 追蹤來源」。

DUT 端如何承接 outstanding write
DUT 內建 AW queue 深度 8： axi_write_slave.sv:50。
核心機制：

收到 AW 後，如果正在寫就 push queue： axi_write_slave.sv:80
空閒時可直接開新寫入或從 queue pop： axi_write_slave.sv:86, axi_write_slave.sv:91
寫完一筆 burst（w_last_hs）就 b_pending++： axi_write_slave.sv:118
B handshake 就 b_pending--： axi_write_slave.sv:119
AWREADY/WREADY/BVALID 由 queue/active/pending 狀態決定： axi_write_slave.sv:133, axi_write_slave.sv:134, axi_write_slave.sv:135
assertions 怎麼追 outstanding
checker 用三組資料：
pending_beats_q：每筆 burst 還有幾拍： axi_assertions.sv:2
pending_id_q：每筆 AW 的 ID： axi_assertions.sv:3
id_outstanding_count[16]：每個 ID 有幾筆未完成： axi_assertions.sv:4
行為：

AW handshake 時 push beats 與 ID： axi_assertions.sv:25, axi_assertions.sv:27
B handshake 時 pop_front 當作完成一筆： axi_assertions.sv:39
W handshake 時檢查 WLAST 是否對齊最後一拍： axi_assertions.sv:62, axi_assertions.sv:67
monitor/scoreboard 的 outstanding
monitor 也有 outstanding 表： axi_monitor.sv:49, axi_monitor.sv:50。
收完一筆就 ap.write 丟給 scoreboard： axi_monitor.sv:76, axi_monitor.sv:106。
scoreboard 以 id 索引 outstanding： axi_scoreboard.sv:10, axi_scoreboard.sv:32。

最後收尾，等 outstanding 排空
run phase 在 sequence 結束後，會等 bus 連續 idle 8 拍才 drop objection： axi_test.sv:25。

你現在這個 bench 的重點限制

DUT/top 沒有真正 AWID/ARID/BID/RID 介面，只有 debug AWID。可看 axi_if.sv:18 與 top_tb.sv:32。
checker 在 B 端是用 FIFO pop ID，不是比對 BID。
monitor 目前用地址低位當 ID： axi_monitor.sv:60, axi_monitor.sv:88。
所以結論是：
你現在的 outstanding 機制已經可以驗證「多筆 in-flight + burst/WLAST/B 通道排隊」；但還不是完整 AXI ID return-path 驗證。
如果你要，我可以下一步直接幫你整理一版「最小修改清單」，把它升級成可驗 BID/RID 的完整版本。





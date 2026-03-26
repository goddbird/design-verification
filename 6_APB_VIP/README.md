# APB Introduce
<img width="722" height="501" alt="image" src="https://github.com/user-attachments/assets/be413808-ce4e-4e76-b67f-16556a6e8cec" />



---
# APB Spec
|Name|Source|Description|
|---|---|---|
|PCLK|Clock Source|Bus Clock(posedge edge trigger)|
|PRESETn|Reset Controller|Bus reset(active low)|
|PADDR[31:0]|Master|32 bit address bus|
|PENABLE|Master|1 : indicate master can transfer data to slave|
|PWRITE|Master|indicate direction of tranmission|
|PWDATA[31:0]|Master|write data|
|PPROT[2:0]|Master|indicate which is data / instruction|
|PRDATA[31:0]|Slave|read data|
|PREADY|Slave|1 : slave is ready for next cmd|
|PSLVERR|Slave|show response result|


---
# My APB VIP Architecture
<img width="853" height="583" alt="image" src="https://github.com/user-attachments/assets/0ed45c55-7a7c-4cec-ac0e-694ec7d14ca3" />

---

# My APB VIP Topology
```
APB_vip/
├── APB_if.sv                ←【介面】實體訊號、modport
│
├── APB_pkg.sv               ←【總入口】import 所有 class
│
├── transaction/
│   └── APB_txn.sv     ←【交易】抽象的一次 write 行為
│
├── sequence/
│   ├── APB_virtual_seq        ← 裝seq的容器，並同步addr
│       └── APB_seq.sv         ←【刺激】產生write txn
│       └── APB_read_seq.sv    ←【刺激】產生read txn
│
├── agent/
│   ├── APB_driver.sv        ←【執行者】把 txn 變成 pin-level APB
│   ├── APB_monitor.sv       ←【觀察者】從 pin-level 還原 txn
│   ├── APB_sequencer.sv     ←【排程器】管理 sequence
│   └── APB_agent.sv         ←【整合】driver + monitor
│
├── env/
│   └── APB_env.sv           ←【環境】放一個或多個 agent
│
├── test/
│   └── APB_write_test.sv    ←【測試】選 sequence 跑 
│
├── sva/
│   └── APB_assertions.sv    ←【SVA】確認WLAST訊號如預期變化
│
└── top/
    └── tb_top.sv            ←【最上層】DUT + VIP + vif config_db + clock/reset
```

---

# My APB VIP Waveform
<img width="1910" height="257" alt="image" src="https://github.com/user-attachments/assets/140a1113-cd40-426a-b0c0-75edefef6067" />



---

# My APB VIP xrun.log
<img width="1876" height="760" alt="image" src="https://github.com/user-attachments/assets/18dfb0b5-9b3d-4a42-a773-f272fe7aa64d" />


---
# Coverage

| Feature           | Description         | Coverage Method |
| ----------------- | ------------------- | --------------- |
| Burst Type        | FIXED / INCR / WRAP | coverpoint      |
| Burst Length      | 1~16 beats          | coverpoint      |
| Transfer Size     | 1B / 2B / 4B / 8B   | coverpoint      |
| Address Alignment | aligned / unaligned | coverpoint      |





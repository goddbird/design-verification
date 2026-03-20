# AHB Introduce
<img width="801" height="554" alt="image" src="https://github.com/user-attachments/assets/11a22ad9-3f7e-4386-8950-f2aa92292e7f" />

---

# My AHB VIP Architecture
<img width="853" height="583" alt="image" src="https://github.com/user-attachments/assets/0ed45c55-7a7c-4cec-ac0e-694ec7d14ca3" />

---

# My AHB VIP Topology
```
AHB_vip/
├── AHB_if.sv                ←【介面】實體訊號、modport
│
├── AHB_pkg.sv               ←【總入口】import 所有 class
│
├── transaction/
│   └── AHB_txn.sv     ←【交易】抽象的一次 write 行為
│
├── sequence/
│   └── AHB_write_seq.sv     ←【刺激】產生一堆 write txn
│
├── agent/
│   ├── AHB_driver.sv        ←【執行者】把 txn 變成 pin-level AHB
│   ├── AHB_monitor.sv       ←【觀察者】從 pin-level 還原 txn
│   ├── AHB_sequencer.sv     ←【排程器】管理 sequence
│   └── AHB_agent.sv         ←【整合】driver + monitor
│
├── env/
│   └── AHB_env.sv           ←【環境】放一個或多個 agent
│
├── test/
│   └── AHB_write_test.sv    ←【測試】選 sequence 跑 
│
├── sva/
│   └── AHB_assertions.sv    ←【SVA】確認WLAST訊號如預期變化
│
└── top/
    └── tb_top.sv            ←【最上層】DUT + VIP + vif config_db + clock/reset
```

---

# My AHB VIP Waveform
<img width="1833" height="772" alt="image" src="https://github.com/user-attachments/assets/5fbc0dc1-2e37-410b-881e-8ca9b372b08a" />


---

# My AHB VIP xrun.log
<img width="1312" height="712" alt="image" src="https://github.com/user-attachments/assets/0173dd1a-1868-46eb-8865-ccf7dfed1049" />

---
# Coverage
![coverage](./Coverage.png)
| Feature           | Description         | Coverage Method |
| ----------------- | ------------------- | --------------- |
| Burst Type        | FIXED / INCR / WRAP | coverpoint      |
| Burst Length      | 1~16 beats          | coverpoint      |
| Transfer Size     | 1B / 2B / 4B / 8B   | coverpoint      |
| Address Alignment | aligned / unaligned | coverpoint      |





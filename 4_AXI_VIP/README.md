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

---






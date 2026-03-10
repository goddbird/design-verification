# AXI Introduce
<img width="801" height="554" alt="image" src="https://github.com/user-attachments/assets/11a22ad9-3f7e-4386-8950-f2aa92292e7f" />
<br>
<br>
# My AXI VIP Architecture
<img width="853" height="583" alt="image" src="https://github.com/user-attachments/assets/0ed45c55-7a7c-4cec-ac0e-694ec7d14ca3" />
<br>
<br>
# My AXI VIP Topology
```
axi_vip/
├── axi_if.sv                ←【介面】實體訊號、modport、clocking
│
├── axi_pkg.sv               ←【總入口】import 所有 class
│
├── transaction/
│   └── axi_write_txn.sv     ←【交易】抽象的一次 write 行為
│
├── sequence/
│   ├── axi_base_seq.sv
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
└── top/
    └── tb_top.sv            ←【最上層】DUT + VIP + clock/reset
```
<br>
<br>
# My AXI VIP Waveform
<img width="1828" height="521" alt="image" src="https://github.com/user-attachments/assets/9c62d751-7c0b-4dc1-8ab2-1f4de420d8b7" />
<br>
<br>
# My AXI VIP xrun.log
<img width="1312" height="712" alt="image" src="https://github.com/user-attachments/assets/0173dd1a-1868-46eb-8865-ccf7dfed1049" />
<br>
<br>

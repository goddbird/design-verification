


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

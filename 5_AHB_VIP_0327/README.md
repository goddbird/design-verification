# AHB Introduce
<img width="770" height="707" alt="image" src="https://github.com/user-attachments/assets/42b0e25c-b3f7-43ce-b8dd-770508140e5e" />


---
# AHB Spec
|Name|Source|Description|
|---|---|---|
|HCLK|Clock Source|Bus Clock(posedge edge trigger)|
|HRESETn|Reset Controller|Bus reset(active low)|
|HADDR[31:0]|Master|32 bit address bus|
|HTRANS[1:0]|Master|transmission type 00:IDLE, 01:BUSY, 10:NONSEQ , 11:SEQ |
|HWRITE|Master|indicate direction of tranmission|
|HSIZE[2:0]|Master|indicate width of every transmission|
|HBURST[2:0]|Master|AHB has 8 type of burst, indicate different length of burst|
|HPROT[3:0]|Master|indicate which is data / instruction|
|HWDATA[31:0]|Master|write data|
|HRDATA[31:0]|Slave|read data|
|HREADY|Slave|1 : slave is ready for next cmd|
|HRESP[1:0]|Slave|response from slave, which indicate the status of bus execution|
|HSELx|Decoder|choose slave|


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

<img width="1892" height="307" alt="image" src="https://github.com/user-attachments/assets/b696f63c-6b04-4f2c-a11f-c8c1e9e8cfe2" />



---

# My AHB VIP xrun.log
<img width="1730" height="982" alt="image" src="https://github.com/user-attachments/assets/d48aaefd-f497-4cf6-bc23-d137b8ccdb93" />


---
# Coverage
<img width="1694" height="824" alt="image" src="https://github.com/user-attachments/assets/87f8e957-5341-4d31-a49e-fcd2b7059ad6" />

| Feature           | Description         | Coverage Method |
| ----------------- | ------------------- | --------------- |
| Burst Type        | FIXED / INCR / WRAP | coverpoint      |
| Burst Length      | 1~16 beats          | coverpoint      |
| Transfer Size     | 1B / 2B / 4B / 8B   | coverpoint      |
| Address Alignment | aligned / unaligned | coverpoint      |





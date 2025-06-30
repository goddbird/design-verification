## 🔰 建議閱讀與實作順序（快速理解路線）

### 🔹 Step 1：掌握 VIP 結構

🔍 先了解這個 VIP 提供哪些元件與用途：

* `cdnUartUvmAgent.sv`：主代理，裡面包含 driver、monitor、sequencer
* `cdnUartUvmConfig.sv`：設定用，定義 VIP 行為與模式（重點）
* `cdnUartUvmSequence.sv` / `cdnUartUvmSequencer.sv`：用來下 stimulus
* `cdnUartUvmMonitor.sv`：監控 DUT 傳送的訊號
* `cdnUartUvmDriver.sv`：將 sequence 發送的命令驅動到 DUT
* `cdnUartUvmInstance.sv`：整合 config + agent + interface
  👉 這些模組在 `/cdn_uart/` 裡都看得到

---

### 🔹 Step 2：從官方 example 開始跑 simulation

Cadence 提供的 `examples/` 資料夾是**最容易開始的入口**，建議你：

```bash
cd ~/UART_Test/cdn_uart/examples/
```

挑選 `using_config_object/` 或 `simple_test/`，裡面會有：

* `top.sv`
* `test.sv`
* `run.f` 或 makefile

✅ **直接 compile & run**，觀察 waveform + log，可以快速幫助你對整體流程有概念。

---

### 🔹 Step 3：理解 config object 的設定方式（重點）

從文件的 `3.1 UVM Configuration Object Flow` 開始看是對的。

搭配檔案 `cdnUartUvmConfig.sv`，重點看：

* `is_master`：是否為主裝置（是否要送資料）
* `enable_parity`、`data_length`：控制資料傳輸細節
* `use_cts`、`use_rts`：是否啟用 flow control

➡️ 配合文件的 **第 3 章「SOMA Parameters」** 可以查到每個設定的意義。

---

### 🔹 Step 4：從 CTS/RTS 實作 testcase 入門

因為你 Mentor 要你看 parity / data length 和 CTS/RTS，你可以專注做：

* 修改 config：開啟 parity、設定 data length
* 設定 `use_cts = 1;` 並觀察 waveform 和 VIP 反應
* 寫一個簡單的 sequence：送出一包資料，觀察 CTS 為 high 時會不會停住

這樣你會對 config 與 VIP 的互動、以及 VIP 的 driver/monitor 功能有直觀理解。

---

## ✍️ 實作建議：從 CTS/RTS 測資寫起

你可以寫一個自己的 `uvm_test` class，像這樣：

```systemverilog
virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  uart_cfg = cdnUartUvmConfig::type_id::create("uart_cfg");
  uart_cfg.is_master = 1;
  uart_cfg.use_cts = 1;
  uart_cfg.use_rts = 1;
  uart_cfg.enable_parity = 1;
  uart_cfg.data_length = 8;
  uvm_config_db #(cdnUartUvmConfig)::set(this, "*", "config", uart_cfg);
endfunction
```

這樣你就能快速切換 VIP 行為，觀察反應。

---

## 📌 小總結：三個學習重點

| 重點          | 建議行動                      |
| ----------- | ------------------------- |
| VIP 架構      | 看 `cdnUartUvm*.sv` 檔案     |
| Config 使用方式 | 看文件第 3 章 + 實際設定跑 example  |
| 驗證重點        | 寫 CTS/RTS test case 並觀察反應 |

---

如果你要的話，我也可以：

* 幫你畫出模組關係圖
* 或幫你一步步寫出 CTS 測資的完整 code

你需要哪一種幫助？

# 筆記
uart_env.sv有下面這些agent
- apb_mst_agent : cdnApbUvmActiveMasterAgent
- uart_dev_agent : cdnUartUvmDeviceAgent
- uart_mon_agent : cdnUartUvmMonAgent
- pclk_agent : ntc_clk_agent
- rst_agent : ntc_rst_agent
- irq_agent : ntc_irq_agent
- ctrl_agent : uart_ctrl_agent

底層到上層
uvm_test -> uart_test_base -> uart_common -> ipsim_uart_common -> (uart_func_uart_txrx_trans, uart_ral_test, uart_func_lin_txrx_trans)

# Sequence種類 : uart_run_dut
1. write2dut__cpu_mode
2. write2dut__pdmav1_mode
3. write2dut__pdmav2_mode

# seq的body做的事情
<img width="789" height="466" alt="image" src="https://github.com/user-attachments/assets/c2b75ae5-8440-41b2-9073-d34a15ac2514" />

# 各function解釋
1. set_sequencer : 
設定這個 sequence 要用的 sequencer。
從 sequencer 拿到 RAL model。
存好你之後會用到的特定 register（例如 FIFO status 寄存器）。
這樣做的好處是：你在 sequence 裡可以直接控制 DUT 的寄存器，而不用再重複查找 RAL。

2. setup_vip
同步初始化一些 UART VIP 的設定（例如 IRQ, control 設定, watchdog）。
使用 fork...join_none 讓這些任務平行啟動。
確保在 NBA 結束之後才讓主要流程繼續進行，避免 race condition。

3. setup_cfg
產生config sequence，從RAL中取得所有register，並且排除m_bypass_rgs裡面的reg，剩下的放進mrgs後做shuffle，最後用update寫進DUT。

4. 

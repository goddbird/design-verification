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

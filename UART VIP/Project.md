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

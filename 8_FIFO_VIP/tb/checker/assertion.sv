module assertion(fifo_if fifo_slave);

	// Assertion summary (上方僅列 assert property)
	assert property (p_fifo_no_overflow)
		else $error("FIFO overflow: write when full");
	assert property (p_fifo_no_underflow)
		else $error("FIFO underflow: read when empty");
	assert property (p_fifo_empty_full_consistency)
		else $error("FIFO empty/full inconsistency");

	// Property definitions (下方集中定義)
	property p_fifo_no_overflow;
		@(posedge fifo_slave.clk)
		disable iff (!fifo_slave.rst_n)
		(fifo_slave.full && fifo_slave.wr_en) |-> ##1 1'b0;
	endproperty

	property p_fifo_no_underflow;
		@(posedge fifo_slave.clk)
		disable iff (!fifo_slave.rst_n)
		(fifo_slave.empty && fifo_slave.rd_en) |-> ##1 1'b0;
	endproperty

	property p_fifo_empty_full_consistency;
		@(posedge fifo_slave.clk)
		disable iff (!fifo_slave.rst_n)
		fifo_slave.empty |-> !fifo_slave.full;
	endproperty

	// 可根據需求擴充更多 assertion

endmodule
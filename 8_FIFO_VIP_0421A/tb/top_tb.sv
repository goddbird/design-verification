module top_tb #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter DEPTH = 32
);
	logic clk;
	logic resetn;

	// Gen clock
	initial begin
		clk = 0;
		forever #5 clk = ~clk; // 100MHz clock
	end

	initial begin
		resetn = 0;
		repeat(5) @(posedge clk);
		resetn = 1;
	end

	fifo_if  fifo_slave (
		.clk(clk),
		.rst_n(resetn)
	);

	fifo dut(
		.CLK(fifo_slave.clk),
		.RESETn(fifo_slave.rst_n),
		.wr(fifo_slave.wr_en),
		.rd(fifo_slave.rd_en),
		.data_in(fifo_slave.data_in),
		.data_out(fifo_slave.data_out)
	);

	initial begin
		$fsdbDumpfile("top_tb.fsdb");
		$fsdbDumpvars(0, top_tb);		
	end
endmodule
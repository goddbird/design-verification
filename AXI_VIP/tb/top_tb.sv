`timescale 1ns/1ps

module top_tb;
	// -----------------------------------------------
	// Clock / Reset
	// -----------------------------------------------	
	
	logic ACLK;
	logic ARESETn;
	
	// 10ns period clock
	initial ACLK = 0;
	always #5 ACLK = ~ACLK;
endmodule
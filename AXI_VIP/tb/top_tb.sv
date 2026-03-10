`timescale 1ns/1ps
import uvm_pkg::*;
import axi_write_pkg::*;
`include "uvm_macros.svh"

module top_tb;
	// -----------------------------------------------
	// Clock / Reset
	// -----------------------------------------------	
	
	logic ACLK;
	logic ARESETn;
	
	// 100MHz
	initial begin
		ACLK = 0;
		forever #5 ACLK = ~ACLK; // 100MHz
	end
	
	// Resetn
	initial begin
		ARESETn = 0;
		repeat (5) @(posedge ACLK);
		ARESETn = 1;
	end
	
	// Interface
	axi_if  axi_s(
		.ACLK		(ACLK),
		.ARESETn	(ARESETn)
	);
	
	// DUT
	axi_write_slave dut(
		.ACLK		(axi_s.ACLK),
		.ARESETn	(axi_s.ARESETn),
		.AWADDR		(axi_s.AWADDR),
		.AWVALID	(axi_s.AWVALID),
		.AWLEN		(axi_s.AWLEN),
		.AWSIZE		(axi_s.AWSIZE),
		.AWBURST	(axi_s.AWBURST),
		.AWREADY	(axi_s.AWREADY),
		.WDATA		(axi_s.WDATA),
		.WVALID		(axi_s.WVALID),
		.WLAST		(axi_s.WLAST),
		.WREADY		(axi_s.WREADY),
		.BRESP		(axi_s.BRESP),		
		.BVALID		(axi_s.BVALID),
		.BREADY		(axi_s.BREADY)	
	);
	
	// Assertions
	axi_assertions axi_assert_inst(.vif(axi_s));
	
	// Dump waveform
	initial begin
		$fsdbDumpfile("axi.fsdb");
		$fsdbDumpvars(0, top_tb);	

		uvm_config_db#(virtual interface axi_if)::set(null, "*", "vif", axi_s);
		run_test("axi_test");
	end
endmodule
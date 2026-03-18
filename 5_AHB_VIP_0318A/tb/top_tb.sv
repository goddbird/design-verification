`timescale 1ns/1ps
import uvm_pkg::*;
import ahb_write_pkg::*;
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
	ahb_if  ahb_s(
		.ACLK		(ACLK),
		.ARESETn	(ARESETn)
	);
	
	// DUT
	ahb_write_slave dut(
		.ACLK		(ahb_s.ACLK),
		.ARESETn	(ahb_s.ARESETn),
		.AWADDR		(ahb_s.AWADDR),
		.AWVALID	(ahb_s.AWVALID),
		.AWLEN		(ahb_s.AWLEN),
		.AWSIZE		(ahb_s.AWSIZE),
		.AWBURST	(ahb_s.AWBURST),
		.AWREADY	(ahb_s.AWREADY),
		.WDATA		(ahb_s.WDATA),
		.WVALID		(ahb_s.WVALID),
		.WLAST		(ahb_s.WLAST),
		.WREADY		(ahb_s.WREADY),
		.BRESP		(ahb_s.BRESP),		
		.BVALID		(ahb_s.BVALID),
		.BREADY		(ahb_s.BREADY)	
	);
	
	// Assertions
	ahb_assertions ahb_assert_inst(.vif(ahb_s));
	
	// Dump waveform
	initial begin
		$fsdbDumpfile("ahb.fsdb");
		$fsdbDumpvars(0, top_tb);	

		uvm_config_db#(virtual interface ahb_if)::set(null, "*", "vif", ahb_s);
		run_test("ahb_test");
	end
endmodule
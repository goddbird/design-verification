`timescale 1ns/1ps
import uvm_pkg::*;
import apb_pkg::*;
`include "uvm_macros.svh"

module top_tb;
	// -----------------------------------------------
	// Clock / Reset
	// -----------------------------------------------	
	
	logic PCLK;
	logic PRESETn;
	
	// 100MHz
	initial begin
		PCLK = 0;
		forever #5 PCLK = ~PCLK; // 100MHz
	end
	
	// Resetn
	initial begin
		PRESETn = 0;
		repeat (5) @(posedge PCLK);
		PRESETn = 1;
	end
	
	// Interface
	apb_if  apb_s(
		.PCLK		(PCLK),
		.PRESETn	(PRESETn)
	);
	
	// DUT
	apb_slave  dut(
		.PCLK		(apb_s.PCLK),
		.PRESETn	(apb_s.PRESETn),
		.PADDR		(apb_s.PADDR),
		.PENABLE	(apb_s.PENABLE),
		.PWRITE		(apb_s.PWRITE),
		.PWDATA		(apb_s.PWDATA),
		.PPROT		(apb_s.PPROT),
		.PSTRB		(apb_s.PSTRB),
		.PRDATA		(apb_s.PRDATA),
		.PREADY		(apb_s.PREADY),
		.PSLVERR	(apb_s.PSLVERR)
	);
	
	// Assertions
	//apb_assertions apb_assert_inst(.vif(apb_s));
	
	// Dump waveform
	initial begin
		$fsdbDumpfile("apb.fsdb");
		$fsdbDumpvars(0, top_tb);	

		uvm_config_db#(virtual interface apb_if)::set(null, "*", "vif", apb_s);
		run_test("apb_test");
	end
endmodule
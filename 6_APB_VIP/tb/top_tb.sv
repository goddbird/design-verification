`timescale 1ns/1ps
import uvm_pkg::*;
import ahb_pkg::*;
`include "uvm_macros.svh"

module top_tb;
	// -----------------------------------------------
	// Clock / Reset
	// -----------------------------------------------	
	
	logic HCLK;
	logic HRESETn;
	
	// 100MHz
	initial begin
		HCLK = 0;
		forever #5 HCLK = ~HCLK; // 100MHz
	end
	
	// Resetn
	initial begin
		HRESETn = 0;
		repeat (5) @(posedge HCLK);
		HRESETn = 1;
	end
	
	// Interface
	ahb_if  ahb_s(
		.HCLK		(HCLK),
		.HRESETn	(HRESETn)
	);
	
	// DUT
	ahb_slave dut(
		.HCLK		(ahb_s.HCLK),
		.HRESETn	(ahb_s.HRESETn),
		.HADDR		(ahb_s.HADDR),
		.HTRANS		(ahb_s.HTRANS),
		.HWRITE		(ahb_s.HWRITE),
		.HSIZE		(ahb_s.HSIZE),
		.HBURST		(ahb_s.HBURST),
		.HPROT		(ahb_s.HPROT),
		.HWDATA		(ahb_s.HWDATA),
		.HRDATA		(ahb_s.HRDATA),
		.HREADY		(ahb_s.HREADY),
		.HRESP		(ahb_s.HRESP)
	);
	
	// Assertions
	//ahb_assertions ahb_assert_inst(.vif(ahb_s));
	
	// Dump waveform
	initial begin
		$fsdbDumpfile("ahb.fsdb");
		$fsdbDumpvars(0, top_tb);	

		uvm_config_db#(virtual interface ahb_if)::set(null, "*", "vif", ahb_s);
		run_test("ahb_test");
	end
endmodule
package apb_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "./sequence/apb_txn.sv"
	`include "./uvm_component/apb_driver.sv"
	`include "./uvm_component/apb_monitor.sv"
	`include "./uvm_component/apb_seqr.sv"
	`include "./uvm_component/apb_agent.sv"
	`include "./uvm_component/apb_scoreboard.sv"	
	`include "./uvm_component/apb_env.sv"
	`include "./sequence/apb_seq.sv"
	`include "./sequence/apb_read_seq.sv"
	`include "./sequence/apb_virtual_seq.sv"		
	`include "./uvm_component/apb_test.sv"
endpackage
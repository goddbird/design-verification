package ahb_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "./sequence/ahb_txn.sv"
	`include "./uvm_component/ahb_driver.sv"
	`include "./uvm_component/ahb_monitor.sv"
	`include "./uvm_component/ahb_seqr.sv"
	`include "./uvm_component/ahb_agent.sv"
	`include "./uvm_component/ahb_scoreboard.sv"	
	`include "./uvm_component/ahb_env.sv"
	//`include "./sequence/ahb_write_seq.sv"
	`include "./uvm_component/ahb_test.sv"
endpackage
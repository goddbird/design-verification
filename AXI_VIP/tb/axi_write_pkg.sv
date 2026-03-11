package axi_write_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "./sequence/axi_txn.sv"
	`include "./uvm_component/axi_driver.sv"
	`include "./uvm_component/axi_monitor.sv"
	`include "./uvm_component/axi_seqr.sv"
	`include "./uvm_component/axi_agent.sv"
	`include "./uvm_component/axi_env.sv"
	`include "./sequence/axi_write_seq.sv"
	`include "./uvm_component/axi_test.sv"
endpackage
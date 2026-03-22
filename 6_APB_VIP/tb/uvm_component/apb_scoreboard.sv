class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)
	uvm_analysis_imp #(apb_txn)		sb_port;

	function new(string name = "apb_scoreboard", uvm_component parent);
	endfunction

	extern task write(apb_txn  tr);
endclass

function void apb_scoreboard::write(apb_txn  tr);
	
endfunction
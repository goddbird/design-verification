class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)
	uvm_analysis_imp #(apb_txn)		sb_port;
	bit [31:0] mem [bit[31:0]];

	function new(string name = "apb_scoreboard", uvm_component parent);
	endfunction

	extern task write(apb_txn  tr);
endclass

function void apb_scoreboard::write(apb_txn  tr);
	mem[tr.addr] = tr.data;
	`uvm_info(get_type_name(), $sformatf("Write addr=0x%0h, data=0x%0h", tr.addr, tr.data), UVM_NONE)
endfunction
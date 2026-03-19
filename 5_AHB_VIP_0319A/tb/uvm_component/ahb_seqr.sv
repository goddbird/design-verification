class ahb_seqr extends uvm_sequencer#(ahb_txn);
    `uvm_component_utils(ahb_seqr)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
endclass



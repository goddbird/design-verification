class apb_seqr extends uvm_sequencer #(apb_txn);
	`uvm_component_utils(apb_seqr)

	function new(string name = "ahb_seqr", uvm_component parent);
        super.new(name, this);
    endfunction
endclass



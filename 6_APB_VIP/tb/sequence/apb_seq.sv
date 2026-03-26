class apb_seq extends uvm_sequence #(apb_txn);
	`uvm_object_utils(apb_seq)
	logic [31:0] last_addr;


	function new(string name = "apb_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task apb_seq::body();
	apb_txn		tr;
	tr = apb_txn::type_id::create("tr");
	start_item(tr);
	assert(tr.randomize());
	tr.is_write = 1;
	tr.addr = 4 * tr.addr[31:2];
	last_addr = tr.addr;

	`uvm_info(get_type_name(), $sformatf("WRITE DATA"), UVM_NONE)
	finish_item(tr);
endtask
class apb_read_seq extends uvm_sequence #(apb_txn);
	`uvm_object_utils(apb_read_seq)
	logic [31:0] last_addr;
	

	function new(string name = "apb_read_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task apb_read_seq::body();
	apb_txn		tr;

	tr = apb_txn::type_id::create("tr");
	start_item(tr);

	assert(tr.randomize());
	tr.is_write = 0;
	tr.addr = last_addr;
	tr.addr = 4 * tr.addr[31:2];

	`uvm_info(get_type_name(), $sformatf("READ DATA"), UVM_NONE)
	finish_item(tr);

endtask
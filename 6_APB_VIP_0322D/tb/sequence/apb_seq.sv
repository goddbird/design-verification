class apb_seq extends uvm_sequence #(apb_txn);
	`uvm_object_utils(apb_seq)

	function new(string name = "apb_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task apb_seq::body();
	apb_txn		tr;
	repeat(10)  begin
		tr = apb_txn::type_id::create("tr");
		start_item(tr);
		assert(tr.randomize());
		`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
		finish_item(tr);
	end
endtask
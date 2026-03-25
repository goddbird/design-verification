class apb_read_seq extends uvm_sequence #(apb_txn);
	`uvm_object_utils(apb_read_seq)

	

	function new(string name = "apb_read_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task apb_read_seq::body();
	apb_txn		tr;
	repeat(10) begin
		tr = apb_txn::type_id::create("tr");
		start_item(tr);

		assert(tr.randomize());
		tr.is_write = 0;

		`uvm_info(get_type_name(), $sformatf("READ DATA %s", tr.sprint()), UVM_NONE)
		finish_item(tr);
	end
endtask
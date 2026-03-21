class ahb_seq extends uvm_sequence #(ahb_txn);	
	`uvm_object_utils(ahb_seq)

    function new(string name = "ahb_seq");
        super.new(name);
    endfunction
	
	extern task body();	
endclass

task ahb_seq::body();
	ahb_txn		tr;
	repeat(10) begin
		tr = ahb_txn::type_id::create("tr");
		start_item(tr);
		
		assert(tr.randomize());
		
		`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
		finish_item(tr);
	end
endtask
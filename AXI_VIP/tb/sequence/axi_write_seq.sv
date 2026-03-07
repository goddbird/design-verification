class axi_write_seq extends uvm_sequence#(axi_txn);	
    `uvm_object_utils(axi_write_seq)


    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction
	
	task body();
		axi_txn		tr;
		
		repeat(10) begin
			tr = axi_txn::type_id::create("tr");
			start_item(tr);
			
			assert(tr.randomize() with {
				is_write == 1;
				data.size() == 1;
			} );
			`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
			finish_item(tr);
		end
	endtask
endclass
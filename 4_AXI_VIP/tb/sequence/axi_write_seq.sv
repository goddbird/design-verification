class axi_write_seq extends uvm_sequence#(axi_txn);	
    `uvm_object_utils(axi_write_seq)


    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction
	
	task body();
		axi_txn		tr;
		bit local_write;
		// 先送 20 次 write
		repeat(10) begin
			tr = axi_txn::type_id::create("tr");
			start_item(tr);
			
			assert(tr.randomize() with {
				is_write 	== 1;
				data.size() inside {[1:5]};
				burst_len	== data.size() - 1;
			} );
			`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
			finish_item(tr);
		end
		// 再隨機送 read/write
		repeat(20) begin
			tr = axi_txn::type_id::create("tr");
			start_item(tr);
			local_write = $urandom_range(0,1);
			assert(tr.randomize() with {
				is_write == local_write;
				// write transaction
				is_write -> data.size() inside {[1:5]};
				is_write -> burst_len == data.size() - 1;
				// read transaction
				
				!is_write -> data.size() == 0;
				!is_write -> arlen inside {[0:7]};
				!is_write -> arsize inside {[0:2]};
				!is_write -> arburst inside {[0:1]};
			});
			`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
			finish_item(tr);
		end		
	endtask
endclass
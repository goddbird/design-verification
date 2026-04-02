class axi_write_seq extends uvm_sequence#(axi_txn);	
    `uvm_object_utils(axi_write_seq)
	task body();
		axi_txn tr;
		bit local_write;
		int id_pool[$];
		// 準備id pool (0~7)
		foreach (id_pool[i]) id_pool[i] = i;
		// 先送多筆不同id的write
		repeat(10) begin
			tr = axi_txn::type_id::create("tr");
			start_item(tr);
			int id = $urandom_range(0,7);
			assert(tr.randomize() with {
				is_write == 1;
				id == id;
				data.size() inside {[1:5]};
				burst_len == data.size() - 1;
			} );
			`uvm_info(get_type_name(), $sformatf("[seq] write id=%0d", id), UVM_LOW)
			finish_item(tr);
		end
		// 再隨機送read/write，id隨機
		repeat(20) begin
			tr = axi_txn::type_id::create("tr");
			start_item(tr);
			local_write = $urandom_range(0,1);
			int id = $urandom_range(0,7);
			assert(tr.randomize() with {
				is_write == local_write;
				id == id;
				// write transaction
				is_write -> data.size() inside {[1:5]};
				is_write -> burst_len == data.size() - 1;
				// read transaction
				!is_write -> data.size() == 0;
				!is_write -> arlen inside {[0:7]};
				!is_write -> arsize inside {[0:2]};
				!is_write -> arburst inside {[0:1]};
			});
			`uvm_info(get_type_name(), $sformatf("[seq] %s id=%0d", local_write?"write":"read", id), UVM_LOW)
			finish_item(tr);
		end        
	endtask
				!is_write -> arburst inside {[0:1]};
			});
			`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
			finish_item(tr);
		end		
	endtask
endclass
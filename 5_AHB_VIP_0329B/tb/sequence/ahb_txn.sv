class ahb_txn extends uvm_sequence_item;	
    rand bit [31:0]          addr;
	rand bit 				 write;
	rand bit [2:0]			 size;
	rand bit [2:0]			 hburst;
	rand int unsigned		 burst_len;
    rand bit [31:0]          data[$];   
    rand bit [3:0]			 hprot;	

	constraint hburst_c {
		hburst inside {0, 3, 5, 7}; 
		// SINGLE, INCR4, INCR8, INCR16, 
		//1 beat, 4 beat, 8 beat, 16 beat 
	}

    // 限制 address 在 0x100 以內
    constraint addr_range_c {
        addr inside {[0:32'hff]};
    }

	constraint burst_len_c {
		if(hburst == 3'b000) burst_len == 1;
		if(hburst == 3'b011) burst_len == 4;
		if(hburst == 3'b101) burst_len == 8;
		if(hburst == 3'b111) burst_len == 16;

		// burst_len 只允許 1, 4, 8, 16
		burst_len inside {1, 4, 8, 16};
	}
	
	constraint addr_align_c {
		addr % (burst_len * (1 << size)) == 0;
	}

	constraint data_len_c {
		data.size() == burst_len;
	}

    `uvm_object_utils_begin(ahb_txn)
        `uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(write, UVM_DEFAULT)
        `uvm_field_int(size, UVM_DEFAULT)		
		`uvm_field_int(hburst, UVM_DEFAULT)
        `uvm_field_queue_int(data, UVM_DEFAULT)
        `uvm_field_int(hprot, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "ahb_txn");
        super.new(name);
    endfunction
	
endclass
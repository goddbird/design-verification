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

	constraint burst_len_c {
		if(hburst == 3'b000) burst_len == 1;
		if(hburst == 3'b011) burst_len == 4;
		if(hburst == 3'b101) burst_len == 8;
		if(hburst == 3'b111) burst_len == 16;		
	}
	
	constraint addr_align_c {
		if(size == 3'b001) addr % 2 == 0;
		if(size == 3'b010) addr % 4 == 0;
		if(size == 3'b011) addr % 8 == 0;
		if(size == 3'b100) addr % 16 == 0;

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
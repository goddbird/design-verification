class ahb_txn extends uvm_sequence_item;	
    rand bit [31:0]          addr;
	rand bit 				 write;
	rand bit [2:0]			 size;
	rand bit [2:0]			 hburst;
	rand bit [3:0]			 burst_len;
    rand bit [31:0]          data[];   
    rand bit [3:0]			 HPROT;	

    `uvm_object_utils_begin(ahb_txn)
        `uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(write, UVM_DEFAULT)
        `uvm_field_int(size, UVM_DEFAULT)		
		`uvm_field_int(hburst, UVM_DEFAULT)
        `uvm_field_array_int(data, UVM_DEFAULT)
        `uvm_field_int(HPROT, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "ahb_txn");
        super.new(name);
    endfunction
	
endclass
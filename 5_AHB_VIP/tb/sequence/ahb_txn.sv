class ahb_txn extends uvm_sequence_item;	
    rand bit [31:0]          addr;
	rand bit [1:0]			 htrans;
	rand bit [2:0]			 size;
	rand bit [2:0]			 hburst;
    rand bit [31:0]          data[$];   
    rand bit [3:0]			 HPROT;
    
	rand bit [31 : 0]		 HWDATA;	
	rand bit [31 : 0]		 HRDATA;
	rand bit				 HREADY;
	rand bit				 HRESP;

    `uvm_object_utils_begin(ahb_txn)
        `uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(htrans, UVM_DEFAULT)
        `uvm_field_int(size, UVM_DEFAULT)		
		`uvm_field_int(hburst, UVM_DEFAULT)
        `uvm_field_queue_int(data, UVM_DEFAULT)
        `uvm_field_int(HPROT, UVM_DEFAULT)
        `uvm_field_int(HWDATA, UVM_DEFAULT)
        `uvm_field_int(HRDATA, UVM_DEFAULT)
        `uvm_field_int(HREADY, UVM_DEFAULT)
        `uvm_field_int(HRESP, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "ahb_txn");
        super.new(name);
    endfunction
	
endclass
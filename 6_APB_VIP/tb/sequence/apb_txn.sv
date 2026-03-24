class apb_txn  extends uvm_sequence_item;
	rand bit [31:0]		addr;
	rand bit [31:0]		data;
	rand bit 			is_write;

	`uvm_object_utils_begin(apb_txn)
		`uvm_field_int(addr, UVM_DEFAULT)
		`uvm_field_int(data, UVM_DEFAULT)
		`uvm_field_int(is_write, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "apb_txn");
		super.new(name);
	endfunction
endclass
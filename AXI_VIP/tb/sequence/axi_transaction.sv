class axi_tr extends uvm_sequence_item;
	rand bit [31:0] addr;
	rand bit [31:0] data;
	bit 	 [1:0]  resp;
	
	`uvm_object_utils(axi_tr)
	
	function new(string name = "axi_tr")
		super.new(name);
	endfunction
endclass
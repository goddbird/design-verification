class ahb_driver extends uvm_driver;
    `uvm_component_utils(ahb_driver)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction	
endclass



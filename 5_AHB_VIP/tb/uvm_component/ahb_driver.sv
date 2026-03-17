class ahb_driver extends uvm_driver #(ahb_txn);
    `uvm_component_utils(ahb_driver)
	
	virtual interface ahb_if		vif;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction	
	
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);	
	extern task drive_write();
endclass

function void ahb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);	
	if(!uvm_config_db#(virtual interface ahb_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "ahb_driver : virtual interface not set")
endfunction

task ahb_driver::run_phase(uvm_phase phase);	
	ahb_txn		tr;
	super.run_phase(phase);
	
	wait (vif.HRESETn === 1'b1);
	
	forever begin
		seq_item_port.get_next_item(tr);
		seq_item_port.item_done();
	end
endtask

task ahb_driver::drive_write();
	//address phase
	//data phase
endtask



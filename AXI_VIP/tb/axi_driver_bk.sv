class axi_driver extends uvm_driver#(axi_txn);
    `uvm_component_utils(axi_driver)

	virtual interface axi_if	vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF", "virtual interface not set")
	endfunction
	
    task run_phase(uvm_phase phase);
        axi_txn     tr;
        super.run_phase(phase);


        forever begin
			seq_item_port.get_next_item(tr);
			drive_write(tr); // send to dut
			seq_item_port.item_done();        
		end
    endtask

endclass
class axi_driver extends uvm_driver#(axi_txn);
    `uvm_component_utils(axi_driver)

	virtual interface axi_if	vif;

	function new(string name, uvm_component parent);
	    super.new(name, parent);
	endfunction
	
	
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_write(axi_txn tr);
endclass



function void axi_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "virtual interface not set")
endfunction

task axi_driver::run_phase(uvm_phase phase);
    axi_txn     tr;
    super.run_phase(phase);


    forever begin
		seq_item_port.get_next_item(tr);
		drive_write(tr); // send to dut
		seq_item_port.item_done();        
	end
endtask

task axi_driver::drive_write(axi_txn tr);

	`uvm_info(get_type_name(), "[drive_write]", UVM_NONE)

	@(posedge vif.ACLK);
	
	vif.AWADDR 		<= tr.addr;
	vif.AWVALID 	<= 1;
	
	wait(vif.AWREADY);
	
	vif.AWVALID		<= 0;
	vif.WDATA		<= tr.data[0];
	vif.WVALID		<= 1;
	
	wait(vif.WREADY);
	
	@(posedge vif.ACLK);
	
	vif.WVALID		<= 0;

endtask
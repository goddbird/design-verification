class ahb_driver extends uvm_driver #(ahb_txn);
    `uvm_component_utils(ahb_driver)
	
	virtual interface ahb_if		vif;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction	
	
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);	
	extern task drive_write(ahb_txn  tr);
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
		drive_write(tr);
		seq_item_port.item_done();
	end
endtask

task ahb_driver::drive_write(ahb_txn  tr);

	`uvm_info(get_type_name(), $sformatf("[drive_write]"), UVM_NONE)
	`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
	// first cycle 
	
	vif.HADDR 	<= tr.addr;
	vif.HWRITE	<= 1;
	vif.HSIZE	<= tr.size;
	vif.HBURST	<= tr.hburst;
	vif.HTRANS	<= 2'b10;  //NONSEQ
	@(posedge vif.HCLK);
	
	// burst loop
	for(int i = 0 ; i < tr.burst_len; i++) begin
		// wait ready
		while (!vif.HREADY)
			@(posedge vif.HCLK);

		@(posedge vif.HCLK);

		//data phase (previous address)
		vif.HWDATA	<= tr.data[i];

		//next address
		vif.HADDR	<= tr.addr + (i+1)*(1<<tr.size);

		//next HTRANS
		if(i == 0)
		vif.HTRANS	<= 2'b11; //SEQ
	end

	// end transfer
	@(posedge vif.HCLK);
	vif.HTRANS		<= 2'b00; // IDLE
endtask



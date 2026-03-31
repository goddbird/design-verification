class axi_driver extends uvm_driver#(axi_txn);
	`uvm_component_utils(axi_driver)

	virtual interface axi_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_write(axi_txn tr);
	extern task drive_read(axi_txn tr);
endclass



function void axi_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "axi_driver : virtual interface not set")
endfunction

task axi_driver::run_phase(uvm_phase phase);
	axi_txn tr;
	super.run_phase(phase);

	wait (vif.ARESETn === 1'b1);
	repeat (2) @(posedge vif.ACLK);
	vif.AWVALID <= 0;
	vif.WVALID  <= 0;
	vif.BREADY  <= 0;
	vif.ARVALID <= 0;
	vif.RREADY  <= 0;
	//READ
	vif.ARADDR  <= 0;
	vif.ARVALID <= 0;
	vif.ARLEN   <= 0;
	vif.ARSIZE  <= 0;
	vif.ARBURST <= 0;
	vif.RREADY  <= 0;

	forever begin
		seq_item_port.get_next_item(tr);
		if(tr.is_write)
			drive_write(tr);
		else
			drive_read(tr);
		seq_item_port.item_done();
	end
endtask

task axi_driver::drive_read(axi_txn tr);
	int i;
	`uvm_info(get_type_name(), $sformatf("[drive_read] addr = 0x%h, arlen = %0d", tr.addr, tr.arlen), UVM_NONE)
	// AR channel handshake
	vif.ARADDR   <= tr.addr;
	vif.ARLEN    <= tr.arlen;
	vif.ARSIZE   <= tr.arsize;
	vif.ARBURST  <= tr.arburst;
	vif.ARVALID  <= 1'b1;
	@(posedge vif.ACLK);
	wait(vif.ARREADY);
	vif.ARVALID  <= 1'b0;
	// 讀取資料
	tr.rdata.delete();
	tr.rresp.delete();
	i = 0;
	do begin
		wait(vif.RVALID);
		tr.rdata.push_back(vif.RDATA);
		tr.rresp.push_back(vif.RRESP);
		if(vif.RLAST) break;
		vif.RREADY <= 1'b1;
		@(posedge vif.ACLK);
		vif.RREADY <= 1'b0;
		i++;
	end while (1);
endtask


task axi_driver::drive_write(axi_txn tr);

	`uvm_info(get_type_name(), $sformatf("[drive_write] addr = 0x%h, beats = %0d", tr.addr, tr.data.size()), UVM_NONE)

	@(posedge vif.ACLK);
	
	`uvm_info(get_type_name(), "[drive_write] AW write", UVM_NONE)
	vif.AWADDR 		<= tr.addr;
	vif.AWLEN 		<= tr.data.size() - 1;
	vif.AWSIZE 		<= 3'b010; // 0: 1byte / 1: 2byte / 2: 4byte
	vif.AWBURST		<= 2'b01;	
	vif.AWVALID 	<= 1;
	
	do @(posedge vif.ACLK);
	while(!vif.AWREADY);

	`uvm_info(get_type_name(), "[drive_write] W write", UVM_NONE)	
	vif.AWVALID		<= 0;
	foreach (tr.data[i]) begin
		vif.WDATA		<= tr.data[i];
		vif.WVALID		<= 1;
		
		`uvm_info(get_type_name(), $sformatf("[drive_write] W write[%0d] = 0x%0h", i, tr.data[i]), UVM_NONE)
		if(i == tr.data.size() - 1) vif.WLAST <= 1;
		else vif.WLAST <= 0;
		
		do @(posedge vif.ACLK);
		while(!vif.WREADY);
	end

	

	
	@(posedge vif.ACLK);
	`uvm_info(get_type_name(), "[drive_write] BREADY", UVM_NONE)	
	vif.WVALID		<= 0;
	vif.WLAST		<= 0;
	vif.BREADY		<= 1;
	
	do @(posedge vif.ACLK);
	while(!vif.BVALID);

	@(posedge vif.ACLK);	
	vif.BREADY 		<= 0;
endtask
class axi_driver extends uvm_driver#(axi_txn);
	`uvm_component_utils(axi_driver)

	virtual interface axi_if vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_write(axi_txn tr);
	extern task drive_aw(axi_txn tr);
	extern task drive_w(axi_txn tr);
	extern task drive_read(axi_txn tr);
endclass



function void axi_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "axi_driver : virtual interface not set")
endfunction

task axi_driver::run_phase(uvm_phase phase);
	axi_txn tr;
	int aw_inflight;
	bit enable_multi_write_issue;
	int max_outstanding_aw;
	mailbox #(axi_txn) wr_aw_mb;
	mailbox #(axi_txn) wr_w_mb;
	mailbox #(axi_txn) rd_mb;
	
	super.run_phase(phase);


	wait (vif.ARESETn === 1'b1);
	repeat (2) @(posedge vif.ACLK);
	vif.AWADDR  <= 0;
	vif.AWLEN   <= 0;
	vif.AWSIZE  <= 0;
	vif.AWBURST <= 0;
	vif.DBG_AWID <= 0;
	vif.AWVALID <= 0;
	vif.WDATA   <= 0;
	vif.WVALID  <= 0;
	vif.WLAST   <= 0;
	vif.BREADY  <= 1;
	vif.ARADDR  <= 0;
	vif.ARVALID <= 0;
	vif.RREADY  <= 0;
	vif.ARLEN   <= 0;
	vif.ARSIZE  <= 0;
	vif.ARBURST <= 0;
	aw_inflight = 0;
	if(!uvm_config_db#(bit)::get(this, "", "enable_multi_write_issue", enable_multi_write_issue))
		enable_multi_write_issue = 0;
	if(!uvm_config_db#(int)::get(this, "", "max_outstanding_aw", max_outstanding_aw))
		max_outstanding_aw = 4;

	wr_aw_mb = new();
	wr_w_mb = new();
	rd_mb = new();

	`uvm_info(get_type_name(), $sformatf("[driver] multi_write_issue=%0d max_outstanding_aw=%0d", enable_multi_write_issue, max_outstanding_aw), UVM_LOW)

	fork
		forever begin
			@(posedge vif.ACLK);
			if(vif.AWVALID && vif.AWREADY)
				aw_inflight++;
			if(vif.BVALID && vif.BREADY && (aw_inflight > 0)) begin
				aw_inflight--;
			end
		end

		forever begin
			seq_item_port.get_next_item(tr);
			if(tr.is_write) begin
				if(enable_multi_write_issue)
					wr_aw_mb.put(tr);
				else begin
					drive_write(tr);
				end
			end
			else begin
				if(enable_multi_write_issue)
					rd_mb.put(tr);
				else
					drive_read(tr);
			end
			seq_item_port.item_done();
		end

		forever begin
			axi_txn wr_tr;
			if(!enable_multi_write_issue) begin
				@(posedge vif.ACLK);
				continue;
			end

			wr_aw_mb.get(wr_tr);
			do @(posedge vif.ACLK);
			while(aw_inflight >= max_outstanding_aw);

			drive_aw(wr_tr);
			wr_w_mb.put(wr_tr);
		end

		forever begin
			axi_txn wr_tr;
			if(!enable_multi_write_issue) begin
				@(posedge vif.ACLK);
				continue;
			end

			wr_w_mb.get(wr_tr);
			drive_w(wr_tr);
		end

		forever begin
			axi_txn rd_tr;
			if(!enable_multi_write_issue) begin
				@(posedge vif.ACLK);
				continue;
			end

			rd_mb.get(rd_tr);
			drive_read(rd_tr);
		end
	join
endtask

task axi_driver::drive_read(axi_txn tr);
	`uvm_info(get_type_name(), $sformatf("[drive_read] addr = 0x%h, arlen = %0d", tr.addr, tr.arlen), UVM_NONE)
	// AR channel handshake
	@(posedge vif.ACLK);
	vif.ARADDR   <= tr.addr;
	vif.ARLEN    <= tr.arlen;
	vif.ARSIZE   <= tr.arsize;
	vif.ARBURST  <= tr.arburst;
	vif.ARVALID  <= 1'b1;

	do @(posedge vif.ACLK);
	while(!(vif.ARVALID && vif.ARREADY));
	vif.ARVALID  <= 1'b0;

	// R channel - assert RREADY and capture data
	tr.rdata.delete();
	tr.rresp.delete();
	vif.RREADY <= 1'b1;

	forever begin
		@(posedge vif.ACLK);
		if(vif.RVALID) begin
			tr.rdata.push_back(vif.RDATA);
			tr.rresp.push_back(vif.RRESP);
			if(vif.RLAST) break;
		end
	end

	@(posedge vif.ACLK);
	vif.RREADY <= 1'b0;
endtask


task axi_driver::drive_write(axi_txn tr);
	`uvm_info(get_type_name(), $sformatf("[drive_write] addr = 0x%h, beats = %0d", tr.addr, tr.data.size()), UVM_NONE)
	drive_aw(tr);
	drive_w(tr);
endtask

task axi_driver::drive_aw(axi_txn tr);
	@(posedge vif.ACLK);
	`uvm_info(get_type_name(), "[drive_aw] AW write", UVM_NONE)
	vif.AWADDR 		<= tr.addr;
	vif.AWLEN 		<= tr.data.size() - 1;
	vif.AWSIZE 		<= 3'b010; // 0: 1byte / 1: 2byte / 2: 4byte
	vif.AWBURST		<= 2'b01;
	vif.DBG_AWID	<= tr.id;
	vif.AWVALID 	<= 1;

	do @(posedge vif.ACLK);
	while(!vif.AWREADY);

	vif.AWVALID		<= 0;
	vif.DBG_AWID	<= 0;
endtask

task axi_driver::drive_w(axi_txn tr);
	`uvm_info(get_type_name(), "[drive_w] W write", UVM_NONE)
	foreach (tr.data[i]) begin
		vif.WDATA		<= tr.data[i];
		vif.WVALID		<= 1;

		`uvm_info(get_type_name(), $sformatf("[drive_w] W write[%0d] = 0x%0h", i, tr.data[i]), UVM_NONE)
		if(i == tr.data.size() - 1) vif.WLAST <= 1;
		else vif.WLAST <= 0;

		do @(posedge vif.ACLK);
		while(!vif.WREADY);
	end

	@(posedge vif.ACLK);
	`uvm_info(get_type_name(), "[drive_w] W done", UVM_NONE)
	vif.WVALID		<= 0;
	vif.WLAST		<= 0;
endtask
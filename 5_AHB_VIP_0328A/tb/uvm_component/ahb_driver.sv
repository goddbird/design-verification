class ahb_driver extends uvm_driver #(ahb_txn);
    `uvm_component_utils(ahb_driver)
	virtual interface ahb_if		vif;
	ahb_txn addr_queue[$];

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction	

	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_address_phase(ahb_txn tr);
	extern task drive_data_phase(ahb_txn tr);
endclass

function void ahb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);	
	if(!uvm_config_db#(virtual interface ahb_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "ahb_driver : virtual interface not set")
endfunction

task ahb_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
	wait (vif.HRESETn === 1'b1);

	fork
		// Thread A: Sequencer 取 item 跑 Address Phase
		begin
			ahb_txn req;
			forever begin
				seq_item_port.get_next_item(req);
				addr_queue.push_back(req);
				drive_address_phase(req);
				seq_item_port.item_done();
			end
		end
		// Thread B: 跑 Data Phase
		begin
			ahb_txn data_req;
			forever begin
				wait(addr_queue.size() > 0);
				data_req = addr_queue.pop_front();
				drive_data_phase(data_req);
			end
		end
	join
endtask

task ahb_driver::drive_address_phase(ahb_txn tr);
	// Address phase: 設定 address, control, HTRANS
	vif.HADDR  <= tr.addr;
	vif.HWRITE <= 1;
	vif.HSIZE  <= tr.size;
	vif.HBURST <= tr.hburst;
	vif.HTRANS <= 2'b10; // NONSEQ
	@(posedge vif.HCLK);
	for(int i = 1; i < tr.burst_len; i++) begin
		vif.HADDR <= tr.addr + (i)*(1<<tr.size);
		vif.HTRANS <= 2'b11; // SEQ
		@(posedge vif.HCLK);
	end
endtask

task ahb_driver::drive_data_phase(ahb_txn tr);
	// Data phase: 寫入 HWDATA
	for(int i = 0; i < tr.burst_len; i++) begin
		while (!vif.HREADY)
			@(posedge vif.HCLK);
		vif.HWDATA <= tr.data[i];
		@(posedge vif.HCLK);
	end
endtask



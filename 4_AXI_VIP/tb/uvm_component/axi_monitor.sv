class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

	virtual interface axi_if	  vif;
    uvm_analysis_port #(axi_txn)  ap;    
	covergroup burst_cg with function sample(axi_txn   tr);
		coverpoint tr.burst_len{
			bins single = {0};
			bins short  = {[1:3]};
		}
		
		coverpoint tr.burst_type{
			bins FIXED 	= {0};
			bins INCR 	= {1};
			bins WRAP 	= {2};			
		}
		
		coverpoint tr.burst_size{
			bins size_1B = {0};
			bins size_2B = {1};
			bins size_4B = {2};
			bins size_8B = {3};
		}
	endgroup


    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
		burst_cg = new();
    endfunction



	extern function void build_phase(uvm_phase phase);
	extern task 		 run_phase(uvm_phase phase);
endclass

function void axi_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "axi_monitor : virtual interface not set")
endfunction

task axi_monitor::run_phase(uvm_phase phase);
	// Outstanding transaction追蹤表（用id為key）
	typedef axi_txn txn_t;
	txn_t outstanding_write[bit[3:0]];
	txn_t outstanding_read[bit[3:0]];
	int i;
	forever begin
		@(posedge vif.ACLK)
		// Write Address Channel: 記錄新write txn
		if(vif.AWVALID && vif.AWREADY) begin
			txn_t tr = txn_t::type_id::create("tr");
			tr.is_write = 1;
			tr.addr = vif.AWADDR;
			tr.burst_len = vif.AWLEN;
			tr.id = vif.AWADDR[3:0]; // 假設id來自addr[3:0]，請依實際AXI id訊號取值
			tr.data.delete();
			outstanding_write[tr.id] = tr;
			`uvm_info(get_type_name(), $sformatf("[monitor] new write id=%0d addr=0x%0h", tr.id, tr.addr), UVM_LOW)
		end
		// Write Data Channel: 收集data
		foreach (outstanding_write[id]) begin
			txn_t tr = outstanding_write[id];
			for(i = 0; i <= tr.burst_len; i++) begin
				@(posedge vif.ACLK);
				if(vif.WVALID && vif.WREADY) begin
					tr.data.push_back(vif.WDATA);
					if(vif.WLAST) break;
				end
			end
			burst_cg.sample(tr);
			ap.write(tr);
			`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
			outstanding_write.delete(id);
		end
		// Read Address Channel: 記錄新read txn
		if(vif.ARVALID && vif.ARREADY) begin
			txn_t tr = txn_t::type_id::create("tr");
			tr.is_write = 0;
			tr.addr = vif.ARADDR;
			tr.arlen = vif.ARLEN;
			tr.arsize = vif.ARSIZE;
			tr.arburst = vif.ARBURST;
			tr.id = vif.ARADDR[3:0]; // 假設id來自addr[3:0]，請依實際AXI id訊號取值
			tr.rdata.delete();
			tr.rresp.delete();
			outstanding_read[tr.id] = tr;
			`uvm_info(get_type_name(), $sformatf("[monitor] new read id=%0d addr=0x%0h", tr.id, tr.addr), UVM_LOW)
		end
		// Read Data Channel: 收集data
		foreach (outstanding_read[id]) begin
			txn_t tr = outstanding_read[id];
			i = 0;
			do begin
				@(posedge vif.ACLK);
				if(vif.RVALID && vif.RREADY) begin
					tr.rdata.push_back(vif.RDATA);
					tr.rresp.push_back(vif.RRESP);
					i++;
				end
			end while (!vif.RLAST);
			ap.write(tr);
			`uvm_info(get_type_name(), $sformatf("[read_monitor] id=%0d addr=0x%0h beats=%0d", tr.id, tr.addr, tr.rdata.size()), UVM_NONE)
			outstanding_read.delete(id);
		end
	end
endtask
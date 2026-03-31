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
	axi_txn		tr;
	int i;
	forever begin
		@(posedge vif.ACLK)
		// Write channel monitor
		if(vif.AWVALID && vif.AWREADY) begin
			tr = axi_txn::type_id::create("tr");
			tr.is_write = 1;
			tr.addr = vif.AWADDR;
			tr.burst_len = vif.AWLEN;
			tr.data.delete();
			// collect burst data
			for(int i = 0; i <= vif.AWLEN; i++) begin
				@(posedge vif.ACLK);
				wait(vif.WVALID && vif.WREADY);
				tr.data.push_back(vif.WDATA);
				if(vif.WLAST)
					break;
			end
			burst_cg.sample(tr);
			ap.write(tr);
			`uvm_info(get_type_name(), tr.sprint(), UVM_NONE)
		end
		// Read channel monitor
		if(vif.ARVALID && vif.ARREADY) begin
			tr = axi_txn::type_id::create("tr");
			tr.is_write = 0;
			tr.addr = vif.ARADDR;
			tr.arlen = vif.ARLEN;
			tr.arsize = vif.ARSIZE;
			tr.arburst = vif.ARBURST;
			tr.rdata.delete();
			tr.rresp.delete();
			i = 0;
			do begin
				@(posedge vif.ACLK);
				wait(vif.RVALID && vif.RREADY);
				tr.rdata.push_back(vif.RDATA);
				tr.rresp.push_back(vif.RRESP);
				i++;
			end while (!vif.RLAST);
			ap.write(tr);
			`uvm_info(get_type_name(), $sformatf("[read_monitor] addr=0x%0h, beats=%0d", tr.addr, tr.rdata.size()), UVM_NONE)
		end
	end
endtask
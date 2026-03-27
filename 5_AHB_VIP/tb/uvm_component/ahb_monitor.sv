class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)
	
	covergroup ahb_cov with function sample(ahb_txn  tr, bit [1:0] htrans_val);
		coverpoint htrans_val {
			bins idle		= {2'b00};
			bins busy		= {2'b01};
			bins nonseq		= {2'b10};
			bins seq		= {2'b11};
		}

		coverpoint tr.size {
			bins byte_8		= {3'b000};
			bins halfword	= {3'b001};
			bins word		= {3'b010};
		}

		coverpoint tr.hburst {
			bins single		= {3'b000};
			bins incr		= {3'b001};
			bins wrap4		= {3'b010};			
			bins incr4		= {3'b011};
			bins wrap8		= {3'b100};
			bins incr8		= {3'b101};
			bins wrap16		= {3'b110};
			bins incr16		= {3'b111};			
		}
	endgroup


	virtual interface ahb_if		vif;
	uvm_analysis_port #(ahb_txn)	ap;

	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		ap = new("ap", this);
		ahb_cov = new();
	endfunction	
	
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void ahb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);	
	if(!uvm_config_db#(virtual interface ahb_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "ahb_monitor : virtual interface not set")
endfunction

task ahb_monitor::run_phase(uvm_phase phase);
	ahb_txn		tr;
	wait(vif.HRESETn == 1);

	forever begin
		@(posedge vif.HCLK);
		if (vif.HTRANS == 2'b10 || vif.HTRANS == 2'b11) begin
			tr = ahb_txn::type_id::create("tr");
			tr.addr			= vif.HADDR;
			tr.write		= vif.HWRITE;
			tr.size			= vif.HSIZE;
			tr.hburst		= vif.HBURST;
			tr.data			= {};

			// wait next cycle 
			@(posedge vif.HCLK);
			while(!vif.HREADY)
			@(posedge vif.HCLK);

			if (vif.HWRITE) begin
				tr.data.push_back(vif.HWDATA);
			end
			else begin
				tr.data.push_back(vif.HRDATA);
			end
			ahb_cov.sample(tr, vif.HTRANS);
			ap.write(tr);
			
			`uvm_info(get_type_name(), $sformatf("[Monitor] tr.write"), UVM_NONE)
		end
	end
endtask
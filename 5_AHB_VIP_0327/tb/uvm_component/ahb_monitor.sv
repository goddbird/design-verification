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

function automatic int unsigned ahb_burst_length(bit [2:0] hburst);
    case (hburst)
        3'b000: return 1;
        3'b011: return 4;
        3'b101: return 8;
        3'b111: return 16;
        default: return 1;
    endcase
endfunction

task ahb_monitor::run_phase(uvm_phase phase);
	ahb_txn		tr;
	int unsigned stride;
	int unsigned beat;
	bit [31:0] addr;
	
	wait (vif.HRESETn === 1);

	forever begin
		@(posedge vif.HCLK);
		if ((vif.HTRANS == 2'b10 || vif.HTRANS == 2'b11) && vif.HREADY) begin
			tr = ahb_txn::type_id::create("tr");
			tr.addr		= vif.HADDR;
			tr.write	= vif.HWRITE;
			tr.size		= vif.HSIZE;
			tr.hburst	= vif.HBURST;
			tr.hprot	= vif.HPROT;
			tr.data		= {};
			tr.burst_len = ahb_burst_length(vif.HBURST);

			stride = (1 << tr.size);
			beat = 0;
			addr = tr.addr;

			while (beat < tr.burst_len) begin
				if (vif.HREADY && (vif.HTRANS == 2'b10 || vif.HTRANS == 2'b11)) begin
					if (tr.write)
						tr.data.push_back(vif.HWDATA);
					else
						tr.data.push_back(vif.HRDATA);

					`uvm_info(get_type_name(), $sformatf("[Monitor] tr beat=%0d addr=0x%0h data=0x%0h", beat, addr, tr.data[beat]), UVM_LOW);

					beat++;
					addr += stride;
				end
				@(posedge vif.HCLK);
			end

			ahb_cov.sample(tr, vif.HTRANS);
			ap.write(tr);
			`uvm_info(get_type_name(), $sformatf("[Monitor] txn done addr=0x%0h write=%0b size=%0d burst_len=%0d", tr.addr, tr.write, tr.size, tr.burst_len), UVM_LOW);
		end
	end
endtask
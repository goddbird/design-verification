class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)
	
	virtual interface ahb_if		vif;
	uvm_analysis_port #(ahb_txn)	ap;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		ap = new("ap", this);
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
	forever begin
		@(posedge vif.HCLK);
		if (1) begin
			tr = ahb_txn::type_id::create("tr");
			ap.write(tr);
			`uvm_info(get_type_name(), $sformatf("[Monitor] tr.write"), UVM_NONE)
		end
	end
endtask
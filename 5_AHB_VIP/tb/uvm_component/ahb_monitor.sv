class ahb_monitor extends uvm_monitor;
    `uvm_component_utils(ahb_monitor)
	
	virtual interface ahb_if		vif;
	uvm_analysis_port				ap;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		ap = new();
	endfunction	
	
	extern function void build_phase(uvm_phase phase);
endclass

function void ahb_agent::build_phase(uvm_phase phase);
	uvm_config_db#(virtual interface ahb_if)::get(this, "vif", vif);
	supre.build_phase(phase);	
endfunction


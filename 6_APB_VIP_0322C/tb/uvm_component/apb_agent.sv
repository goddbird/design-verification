class apb_agent extends uvm_agent;
	`uvm_component_utils(apb_agent)

	apb_seqr		seqr_a;
	apb_driver		driver_a;
	apb_monitor		monitor_a;

	function new(string name = "apb_monitor", uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function void apb_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	seqr_a 		= apb_seqr::type_id::create("seqr_a", this); 
	driver_a 	= apb_driver::type_id::create("driver_a", this);
	monitor_a	= apb_monitor::type_id::create("monitor_a", this);
endfunction

function void apb_agent::connect_phase(uvm_phase phase);
	super.build_phase(phase);
	driver_a.seq_item_port.connect(seqr_a.seq_item_export);
endfunction
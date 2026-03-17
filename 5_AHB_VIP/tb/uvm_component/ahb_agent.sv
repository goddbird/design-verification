class ahb_agent extends uvm_agent;
    `uvm_component_utils(ahb_agent)
    
    ahb_seqr        seqr_a;
    ahb_driver      driver_a;
    ahb_monitor     monitor_a;
	
	uvm_active_passive_enum		is_active = UVM_ACTIVE;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);	
endclass

function void ahb_agent::build_phase(uvm_phase phase);
	monitor_a	 = ahb_monitor::type_id::create("monitor_a", this);
	if(is_active) begin
		driver_a = ahb_driver::type_id::create("driver_a", this);
		seqr_a	 = ahb_seqr::type_id::create("seqr_a", this);
	end
endfunction

function void ahb_agent::connect_phase(uvm_phase phase);
	driver_a.seq_item_port.connect(seqr_a.seq_item_export);
endfunction
class ahb_test extends uvm_test;
    `uvm_component_utils(ahb_test)
    
    ahb_agent		agent_a;
	//ahb_scoreboard
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);	
endclass

function void ahb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	agent_a	 = ahb_agent::type_id::create("agent_a", this);
endfunction

function void ahb_test::connect_phase(uvm_phase phase);
	//scoreboard
	//ahb_agent.monitor_a.ap.connect();
endfunction
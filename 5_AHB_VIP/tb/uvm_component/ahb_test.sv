class ahb_test extends uvm_test;
    `uvm_component_utils(ahb_test)
    
    ahb_env		env_a;
	//ahb_scoreboard
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);	
endclass

function void ahb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_a	 = ahb_env::type_id::create("env_a", this);
endfunction

task ahb_test::run_phase(uvm_phase phase);
	//scoreboard
	//ahb_agent.monitor_a.ap.connect();
endtask
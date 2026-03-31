class axi_env extends uvm_env;
	axi_agent			agent_a;
	axi_scoreboard  	scoreboard_a;
    `uvm_component_utils(axi_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
	
	
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function void axi_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	agent_a = axi_agent::type_id::create("agent_a", this);
	scoreboard_a = axi_scoreboard::type_id::create("scoreboard_a", this);
endfunction

function void axi_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	agent_a.monitor_a.ap.connect(scoreboard_a.sb_port);
endfunction
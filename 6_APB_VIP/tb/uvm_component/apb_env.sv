class apb_env extends uvm_env;
	`uvm_component_utils(apb_env)

	apb_agent		agent_a;
	apb_scoreboard	scoreboard_a;

	function new(string name = "apb_env", uvm_component parent)
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass

function void apb_env::build_phase(uvm_phase phase);
	agent_a = apb_agent::type_id::create("agent_a", this);
endfunction

function void apb_env::connect_phase(uvm_phase phase);
	agent_a.apb_monitor.ap.connect(scoreboard_a.sb_port);
endfunction
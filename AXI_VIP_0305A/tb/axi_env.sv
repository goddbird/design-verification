class axi_env extends uvm_env;
	axi_agent		agent_a;
    `uvm_component_utils(axi_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agent_a = axi_agent::type_id::create("agent_a", this);
	endfunction
endclass
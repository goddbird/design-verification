class axi_test extends uvm_test;
	axi_env		env_a;
    `uvm_component_utils(axi_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env_a = axi_env::type_id::create("env_a", this);
	endfunction
	
	task run_phase(uvm_phase phase);
		axi_write_seq		seq;
		phase.raise_objection(this);
		seq = axi_write_seq::type_id::create("seq");
		seq.start(env_a.agent_a.seqr_a);
		phase.drop_objection(this);		
	endtask
endclass
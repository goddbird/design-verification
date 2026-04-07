class axi_test extends uvm_test;
	axi_env		env_a;
	virtual interface axi_if vif;
    `uvm_component_utils(axi_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF", "axi_test : virtual interface not set")
		uvm_config_db#(bit)::set(this, "env_a.agent_a.driver_a", "enable_multi_write_issue", 1'b1);
		uvm_config_db#(int)::set(this, "env_a.agent_a.driver_a", "max_outstanding_aw", 4);
		env_a = axi_env::type_id::create("env_a", this);
	endfunction
	
	task run_phase(uvm_phase phase);
		axi_write_seq		seq;
		int idle_cycles;
		phase.raise_objection(this);
		seq = axi_write_seq::type_id::create("seq");
		seq.start(env_a.agent_a.seqr_a);

		// Multi-issue mode completes sequence items before bus traffic is fully drained.
		// Wait for bus to be idle for a few cycles before ending run phase.
		idle_cycles = 0;
		while (idle_cycles < 8) begin
			@(posedge vif.ACLK);
			if (vif.AWVALID || vif.WVALID || vif.BVALID || vif.ARVALID || vif.RVALID)
				idle_cycles = 0;
			else
				idle_cycles++;
		end

		phase.drop_objection(this);		
	endtask
endclass
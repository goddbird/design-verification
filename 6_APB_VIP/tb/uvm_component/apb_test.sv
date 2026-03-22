class apb_test extends uvm_test;
	`uvm_component_utils(apb_test)
	apb_env		env_a;

	function new(string name = "apb_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern task run_phase();
endclass

function void apb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_a = apb_env::type_id::create("env_a", this);
endfunction

task apb_test::run_phase();
	apb_seq		seq;
	this.raise_objection()
	seq = apb_seq::type_id::create("seq", this);
	seq.start_item(env_a.agent_a.seqr_a);
	this.drop_objection()
endtask
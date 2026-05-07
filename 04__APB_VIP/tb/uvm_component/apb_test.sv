class apb_test extends uvm_test;
	`uvm_component_utils(apb_test)
	apb_env		env_a;

	function new(string name = "apb_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void apb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env_a = apb_env::type_id::create("env_a", this);
endfunction

task apb_test::run_phase(uvm_phase phase);
	apb_virtual_seq		vseq;
	vseq = apb_virtual_seq::type_id::create("vseq");


	phase.raise_objection(this);
	vseq.p_apb_seqr = env_a.agent_a.seqr_a;
	vseq.start(null);
	phase.drop_objection(this);
endtask
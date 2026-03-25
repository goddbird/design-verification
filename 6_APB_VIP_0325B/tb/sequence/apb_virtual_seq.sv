class apb_virtual_seq  extends uvm_sequence;
	`uvm_object_utils_begin(apb_virtual_seq)

	apb_sequencer		p_apb_seqr;

	extern task body();
endclass

task apb_virtual_seq::body();
	abp_seq			write_seq;
	apb_read_seq	read_seq;

	write_seq = abp_seq::type_id::create("write_seq");
	read_seq = abp_read_seq::type_id::create("read_seq");

	write_seq.start(p_apb_seqr);
	read_seq.addr = write_seq.addr;
	read_seq.start(p_apb_seqr);

endtask
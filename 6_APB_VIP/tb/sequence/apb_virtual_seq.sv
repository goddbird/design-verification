class apb_virtual_seq  extends uvm_sequence;
	`uvm_object_utils(apb_virtual_seq)

	apb_seqr		p_apb_seqr;

	function new(string name = "apb_virtual_seq");
		super.new(name);
	endfunction

	extern task body();
endclass

task apb_virtual_seq::body();
	apb_seq			write_seq;
	apb_read_seq	read_seq;
	repeat(20) begin
	write_seq = apb_seq::type_id::create("write_seq");
	read_seq = apb_read_seq::type_id::create("read_seq");

	write_seq.start(p_apb_seqr);
	read_seq.last_addr = write_seq.last_addr;
	`uvm_info(get_tyep_name(), $sformatf("wr_addr 0x%0h, rd_addr 0x%0h", write_seq.last_addr, read_seq.last_addr), UVM_NONE);
	read_seq.start(p_apb_seqr);
	end
endtask
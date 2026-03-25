class apb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(apb_scoreboard)
	uvm_analysis_imp #(apb_txn, apb_scoreboard)		sb_port;
	bit [31:0] mem [bit[31:0]];

	function new(string name = "apb_scoreboard", uvm_component parent);
		super.new(name, parent);
		sb_port = new("sb_port", this);
	endfunction

	extern task write(apb_txn  tr);
endclass

task apb_scoreboard::write(apb_txn  tr);
	if(tr.is_write == 1) begin
		mem[tr.addr] = tr.data;
		`uvm_info(get_type_name(), $sformatf("Write addr=0x%0h, data=0x%0h", tr.addr, tr.data), UVM_NONE)
	end 
	else begin
		if(mem.exists(tr.addr)) begin
			if (mem[tr.addr] == tr.data) begin
				`uvm_info(get_type_name(), $sformatf("PASS: Addr=0x%0h, Data=0x%0h", tr.addr, tr.data))
			end
			else begin
				`uvm_fatal(get_type_name(), $sformatf("FAIL: Addr=0x%0h, Expected Data=0x%0h, dut read", tr.addr, mem[tr.addr], tr.data), UVM_NONE)
			end
		end
		else begin
			`uvm_fatal(get_type_name(), $sformatf("Read from uninitialized addr: 0x%0h", tr.addr))
		end
	end
endtask
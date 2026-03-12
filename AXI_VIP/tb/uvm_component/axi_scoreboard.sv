class axi_scoreboard extends uvm_component;
	`uvm_component_utils(axi_scoreboard)
	
	uvm_analysis_imp #(axi_txn, axi_scoreboard) sb_port;
	bit [31:0] mem [bit[31:0]];


	function new(string name, uvm_component parent);
		super.new(name, parent);
		sb_port = new("sb_port", this);
	endfunction

	extern function void write (axi_txn tr);
endclass

function void axi_scoreboard::write(axi_txn tr);
	bit [31:0] addr;

	`uvm_info(get_type_name(), $sformatf("Received txn: addr=0x%0h, burst_len=%0d", tr.addr, tr.burst_len), UVM_NONE)

	if(tr.is_write) begin
		addr = tr.addr;

		foreach(tr.data[i]) begin
			mem[addr + i] = tr.data[i];
			`uvm_info(get_type_name(), $sformatf("Write: addr=0x%0h, data=0x%0h", addr + i, tr.data[i]), UVM_NONE)
			addr += 4; // Assuming 32-bit data width
		end
	end
endfunction
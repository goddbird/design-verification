class ahb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ahb_scoreboard)
    
	uvm_analysis_imp #(ahb_txn, ahb_scoreboard)		sb_port;
	bit [31:0] mem[bit[31:0]];
	
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		sb_port = new("sb_port", this);
	endfunction

	extern function void write(ahb_txn  tr);
endclass

function void ahb_scoreboard::write(ahb_txn  tr);
	bit [31:0] addr;
	bit [31:0] data;

	`uvm_info(get_type_name(), $sformatf("Received txn addr=0x%0h",tr.addr), UVM_NONE)
	
	foreach(tr.data[i]) begin
		addr = tr.addr + i * 4;
		if(tr.write) begin
			mem[addr] = tr.data[i];
			`uvm_info(get_type_name(), $sformatf("Write addr=0x%0h, data=0x%0h", addr + i, tr.data[i]), UVM_NONE)
			addr += (1 << tr.size);			
		end
		else begin
			data = mem.exists(addr) ? mem[addr] : 0;
			if (data != tr.data[i]) begin
				`uvm_error(get_type_name(), $sformatf("Data mismatch at addr=0x%0h, expected=0x%0h, actual=0x%0h", addr + i, data, tr.data[i]))
			end
			else begin
				`uvm_info(get_type_name(), $sformatf("Read data match at addr=0x%0h, data=0x%0h", addr + i, data), UVM_NONE)
			end
		end

	end
	
endfunction
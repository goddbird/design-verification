class axi_scoreboard extends uvm_component;
	`uvm_component_utils(axi_scoreboard)
	uvm_analysis_imp #(axi_txn, axi_scoreboard) sb_port;
	bit [31:0] mem [bit[31:0]];
	// Outstanding transaction追蹤表
	typedef struct {
		axi_txn tr;
		bit     completed;
	} txn_info_t;
	txn_info_t outstanding[bit[3:0]];

	function new(string name, uvm_component parent);
		super.new(name, parent);
		sb_port = new("sb_port", this);
	endfunction

	extern function void write (axi_txn tr);
endclass

function void axi_scoreboard::write(axi_txn tr);
	bit [31:0] addr;
	`uvm_info(get_type_name(), $sformatf("Received txn: id=%0d addr=0x%0h, burst_len=%0d", tr.id, tr.addr, tr.burst_len), UVM_NONE)
	// 以id追蹤outstanding transaction
	if(tr.is_write) begin
		addr = tr.addr;
		// 記錄/比對write transaction
		foreach(tr.data[i]) begin
			mem[addr + i] = tr.data[i];
			`uvm_info(get_type_name(), $sformatf("Write: id=%0d addr=0x%0h, data=0x%0h", tr.id, addr + i, tr.data[i]), UVM_NONE)
			addr += 4; // Assuming 32-bit data width
		end
		outstanding[tr.id].tr = tr;
		outstanding[tr.id].completed = 1;
	end else begin
		// read transaction比對
		if(outstanding.exists(tr.id)) begin
			// 可根據需求比對mem內容與tr.rdata
			`uvm_info(get_type_name(), $sformatf("Read: id=%0d addr=0x%0h, beats=%0d", tr.id, tr.addr, tr.rdata.size()), UVM_NONE)
			// ...可加上資料比對...
			outstanding.delete(tr.id);
		end
	end
endfunction
class axi_scoreboard extends uvm_component;
    `uvm_component_utils(axi_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

	uvm_analysis_imp #(axi_txn, axi_scoreboard) analysis_export;
	
	bit [31:0] mem [bit[31:0]];

	function void write(axi_txn tr);
		if(tr.is_write)
			mem[tr.addr] = tr.data[0];
	endfunction

endclass
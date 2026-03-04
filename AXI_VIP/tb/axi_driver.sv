class axi_driver extends uvm_driver#(axi_txn);
    `uvm_component_utils(axi_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void run_phase(uvm_phase phase);
        axi_txn     tr;
        super.run_phase(phase);


        
        seq_item_port.get_next_item(tr);
        // send to dut
        seq_item_port.item_done();        
    endfunction

endclass
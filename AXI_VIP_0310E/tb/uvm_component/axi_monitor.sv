class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    uvm_analysis_port #(axi_txn)  ap;    

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction


endclass
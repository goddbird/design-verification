class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)

    virtual i2c_if vif;
    uvm_analysis_port #(i2c_txn) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            i2c_txn tr = i2c_txn::type_id::create("tr");
            @(posedge vif.clk);
            wait (vif.sda == 1'b0); // START
            repeat (8) @(posedge vif.clk); // addr + rw

            // Simulate clock stretching by slave
            vif.scl_stretched = 1'b0;
            #20;
            vif.scl_stretched = 1'b1;

            @(posedge vif.clk);
            tr.ack = !vif.sda;
            repeat (8) @(posedge vif.clk); // 1st data
            @(posedge vif.clk);
            tr.ack = !vif.sda;
            ap.write(tr);
        end
    endtask
endclass

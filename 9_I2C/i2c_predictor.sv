class i2c_predictor extends uvm_component;
    `uvm_component_utils(i2c_predictor)

    uvm_analysis_imp #(i2c_txn, i2c_predictor) input_ap;
    uvm_analysis_port #(i2c_txn) expected_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        input_ap = new("input_ap", this);
        expected_ap = new("expected_ap", this);
    endfunction

    function void write(i2c_txn tr);
        i2c_txn exp_tr = new();
        exp_tr.addr = tr.addr;
        exp_tr.data = tr.data;
        exp_tr.rw = tr.rw;
        exp_tr.ack = tr.ack;
        expected_ap.write(exp_tr);
    endfunction
endclass

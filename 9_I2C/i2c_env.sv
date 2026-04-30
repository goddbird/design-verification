class env extends uvm_env;

    i2c_driver      drv;
    i2c_monitor     mon;
    i2c_predictor   pred;
    i2c_scoreboard  sco;

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Predictor receives transaction from driver
        drv.analysis_port.connect(pred.input_ap);

        // Monitor sends actual transactions to scoreboard
        mon.ap.connect(sco.actual_ap);

        // Predictor sends expected transactions to scoreboard
        pred.expected_ap.connect(sco.expected_ap);
    endfunction
endclass

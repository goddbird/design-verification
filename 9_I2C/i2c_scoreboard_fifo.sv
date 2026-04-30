// i2c_scoreboard using uvm_tlm_analysis_fifo
class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    uvm_tlm_analysis_fifo#(i2c_txn) expected_fifo;
    uvm_tlm_analysis_fifo#(i2c_txn) actual_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        expected_fifo = new("expected_fifo", this);
        actual_fifo   = new("actual_fifo", this);
    endfunction

    task run_phase(uvm_phase phase);
        i2c_txn exp, act;

        forever begin
            expected_fifo.get(exp);
            actual_fifo.get(act);

            if (exp.addr !== act.addr || exp.rw !== act.rw || exp.wdata.size() !== act.wdata.size()) begin
                `uvm_error("SCOREBOARD", "Address/RW/WData size mismatch")
                continue;
            end

            foreach (exp.wdata[i]) begin
                if (exp.wdata[i] !== act.wdata[i]) begin
                    `uvm_error("SCOREBOARD", $sformatf("Data mismatch at byte %0d: expected %0h, got %0h", i, exp.wdata[i], act.wdata[i]))
                end
            end

            if (exp.rw == 1) begin
                if (exp.rdata.size() !== act.rdata.size()) begin
                    `uvm_error("SCOREBOARD", "Read data size mismatch")
                    continue;
                end
                foreach (exp.rdata[i]) begin
                    if (exp.rdata[i] !== act.rdata[i]) begin
                        `uvm_error("SCOREBOARD", $sformatf("Read data mismatch at byte %0d: expected %0h, got %0h", i, exp.rdata[i], act.rdata[i]))
                    end
                end
            end

            if (exp.ack !== act.ack) begin
                `uvm_error("SCOREBOARD", $sformatf("ACK mismatch: expected %0b, got %0b", exp.ack, act.ack))
            end
        end
    endtask
endclass

// i2c_scoreboard using analysis_imp port + queues
class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    uvm_analysis_imp #(i2c_txn, i2c_scoreboard) actual_ap;
    uvm_analysis_imp #(i2c_txn, i2c_scoreboard) expected_ap;

    i2c_txn actual_q[$];
    i2c_txn expected_q[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        actual_ap = new("actual_ap", this);
        expected_ap = new("expected_ap", this);
    endfunction

    task write(i2c_txn tr);
        actual_q.push_back(tr);
        compare();
    endtask

    task write_expected(i2c_txn tr);
        expected_q.push_back(tr);
        compare();
    endtask

    function void compare();
        if (actual_q.size() > 0 && expected_q.size() > 0) begin
            i2c_txn a = actual_q.pop_front();
            i2c_txn e = expected_q.pop_front();

            if (a.addr !== e.addr || a.rw !== e.rw || a.wdata.size() !== e.wdata.size()) begin
                `uvm_error("SCOREBOARD", "Address/RW/WData length mismatch")
                return;
            end

            foreach (a.wdata[i]) begin
                if (a.wdata[i] !== e.wdata[i]) begin
                    `uvm_error("SCOREBOARD", $sformatf("Mismatch at byte %0d: expected %0h, got %0h", i, e.wdata[i], a.wdata[i]))
                end
            end
        end
    endfunction
endclass

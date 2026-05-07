// I2C driver (clock stretching version)
class i2c_driver extends uvm_driver #(i2c_txn);

    task wait_scl_ready();
        while (vif.scl_stretched == 1'b0) @(posedge vif.clk);
        vif.scl <= 1'b1;
        @(posedge vif.clk);
        vif.scl <= 1'b0;
    endtask

    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);

            // START
            vif.sda <= 1'b0;
            @(posedge vif.clk);
            vif.scl <= 1'b0;

            // Address + R/W
            bit [7:0] addr_rw = {tr.addr, tr.rw};
            for (int i = 7; i >= 0; i--) begin
                vif.sda <= addr_rw[i];
                @(posedge vif.clk);
                wait_scl_ready();
            end

            // ACK
            @(posedge vif.clk);
            wait_scl_ready();
            tr.ack = !vif.sda;
            vif.scl <= 1'b0;

            if (!tr.rw) begin
                foreach (tr.data[idx]) begin
                    bit [7:0] data_byte = tr.data[idx];
                    for (int i = 7; i >= 0; i--) begin
                        vif.sda <= data_byte[i];
                        @(posedge vif.clk);
                        wait_scl_ready();
                    end
                    @(posedge vif.clk);
                    wait_scl_ready();
                    tr.ack = !vif.sda;
                    vif.scl <= 1'b0;
                end
            end else begin
                bit [7:0] byte_data;
                for (int i = 7; i >= 0; i--) begin
                    wait_scl_ready();
                    @(posedge vif.clk);
                    byte_data[i] = vif.sda;
                    vif.scl <= 1'b0;
                end
                tr.data.push_back(byte_data);
                @(posedge vif.clk);
                vif.sda <= tr.ack ? 1'b1 : 1'b0;
            end

            // STOP
            vif.scl <= 1'b1;
            @(posedge vif.clk);
            vif.sda <= 1'b1;

            seq_item_port.item_done();
        end
    endtask
endclass

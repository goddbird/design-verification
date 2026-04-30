// I2C driver (basic)
class I2c_driver extends uvm_driver#(packet_transaction);
    packet_transaction tr;

    virtual task run_phase(uvm_phase phase);
        forever begin
            tr = packet_transaction::type_id::create("tr");
            seq_item_port.get_next_item(tr);

            // Start condition
            vif.sda <= 1'b0;
            @(posedge vif.clk);
            vif.scl <= 1'b0;

            // Address + R/W
            bit [7:0] addr_rw = {tr.addr, tr.rw};
            for (int i = 7; i >= 0; i--) begin
                vif.sda <= addr_rw[i];
                @(posedge vif.clk);
                vif.scl <= 1'b1;
                @(posedge vif.clk);
                vif.scl <= 1'b0;
            end

            // Receive acknowledge
            @(posedge vif.clk);
            vif.scl <= 1'b1;
            @(posedge vif.clk);
            tr.ack = !vif.sda;
            vif.scl <= 1'b0;

            if (!tr.rw) begin
                // Write mode
                for (int idx = 0; idx < tr.wdata.size(); idx++) begin
                    bit [7:0] data_byte = tr.wdata[idx];
                    for (int i = 7; i >= 0; i--) begin
                        vif.sda <= data_byte[i];
                        @(posedge vif.clk);
                        vif.scl <= 1'b1;
                        @(posedge vif.clk);
                        vif.scl <= 1'b0;
                    end

                    // ACK/NACK
                    @(posedge vif.clk);
                    vif.scl <= 1'b1;
                    @(posedge vif.clk);
                    tr.ack = !vif.sda;
                    vif.scl <= 1'b0;
                end
            end else begin
                // Read mode
                bit [7:0] byte_data = 0;
                for (int i = 7; i >= 0; i--) begin
                    vif.scl <= 1'b1;
                    @(posedge vif.clk);
                    byte_data[i] = vif.sda;
                    vif.scl <= 1'b0;
                end

                tr.rdata.push_back(byte_data);

                // ACK/NACK
                vif.sda <= tr.ack ? 1'b1 : 1'b0;
                @(posedge vif.clk);
            end

            // Stop condition
            vif.scl <= 1'b1;
            @(posedge vif.clk);
            vif.sda <= 1'b1;

            seq_item_port.item_done();
        end
    endtask
endclass

// I2C transaction and sequence
class i2c_transaction extends uvm_sequence_item;
    `uvm_object_utils(i2c_transaction)

    rand bit [6:0] addr;
    rand bit rw;
    bit [7:0] wdata[$];
    bit [7:0] rdata[$];
    bit ack;

    // Constraint for valid address
    constraint valid_addr {
        addr inside {[7'b00000000:7'h7F]};
    }

    // One way to fill the queue
    function void post_randomize();
        wdata.delete();
        for (int i = 0; i < $urandom_range(1, 32); i++) begin
            wdata.push_back($urandom_range(1, 255));
        end
    endfunction

endclass

class i2c_sequence extends uvm_sequence#(i2c_transaction);
    `uvm_object_utils(i2c_sequence)

    virtual task body();
        i2c_transaction tr;
        tr = i2c_transaction::type_id::create("tr");

        start_item(tr);
        assert(tr.randomize());
        if (!tr.rw) begin
            int num_bytes = $urandom_range(1, 32);
            tr.data = {};
            for (int i = 0; i < num_bytes; i++) begin
                tr.data.push_back($urandom_range(0, 255));
            end
        end
        finish_item(tr);
    endtask
endclass

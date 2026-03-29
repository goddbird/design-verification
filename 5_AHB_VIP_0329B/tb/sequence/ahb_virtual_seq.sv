// ahb_virtual_seq.sv
// Virtual sequence: 先寫20次，之後隨機讀寫

class ahb_virtual_seq extends uvm_sequence#(ahb_txn);
    `uvm_object_utils(ahb_virtual_seq)

    function new(string name = "ahb_virtual_seq");
        super.new(name);
    endfunction

    task body();
        ahb_seq write_seq;
        ahb_read_seq read_seq;
        ahb_txn tr;
        int i;
        
        // 先寫20次
        for (i = 0; i < 20; i++) begin
            write_seq = ahb_seq::type_id::create($sformatf("write_seq_%0d", i));
            write_seq.start(m_sequencer);
        end

        // 再隨機讀寫20次
        for (i = 0; i < 20; i++) begin
            if ($urandom_range(0,1) == 0) begin
                write_seq = ahb_seq::type_id::create($sformatf("write_seq_rnd_%0d", i));
                write_seq.start(m_sequencer);
            end else begin
                read_seq = ahb_read_seq::type_id::create($sformatf("read_seq_rnd_%0d", i));
                read_seq.start(m_sequencer);
            end
        end
    endtask
endclass

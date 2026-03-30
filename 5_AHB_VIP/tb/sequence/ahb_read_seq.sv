class ahb_read_seq extends uvm_sequence #(ahb_txn);
    `uvm_object_utils(ahb_read_seq)

    function new(string name = "ahb_read_seq");
        super.new(name);
    endfunction

    task body();
        ahb_txn tr;
        tr = ahb_txn::type_id::create("tr");
        
        start_item(tr);
        assert(tr.randomize());
        tr.write   = 0;             // 0 代表read
        finish_item(tr);
    endtask
endclass

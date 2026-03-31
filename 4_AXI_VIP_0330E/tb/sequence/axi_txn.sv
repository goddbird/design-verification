class axi_txn extends uvm_sequence_item;	
    rand bit [3:0]           id;
    rand bit [31:0]          addr;
    // write channel
    rand bit [7:0]           awlen;
    rand bit [2:0]           awsize;
    rand bit [1:0]           awburst;
    rand bit [31:0]          data[$];   // write data
    rand bit                 wlast;
    rand bit [3:0]           wstrb;
    // read channel
    rand bit [7:0]           arlen;
    rand bit [2:0]           arsize;
    rand bit [1:0]           arburst;
    rand bit [31:0]          rdata[$];  // read data
    rand bit [1:0]           rresp[$];
    // common
    rand bit [7:0]           burst_len;
    rand bit [2:0]           burst_size;
    rand bit [1:0]           burst_type;
    rand bit                 is_write; // 1: write, 0: read
    rand bit                 lock;
    rand bit [3:0]           qos;

    `uvm_object_utils_begin(axi_txn)
        `uvm_field_int(id, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT)
        // write
        `uvm_field_queue_int(data, UVM_DEFAULT)
        `uvm_field_int(awlen, UVM_DEFAULT)
        `uvm_field_int(awsize, UVM_DEFAULT)
        `uvm_field_int(awburst, UVM_DEFAULT)
        `uvm_field_int(wlast, UVM_DEFAULT)
        `uvm_field_int(wstrb, UVM_DEFAULT)
        // read
        `uvm_field_int(arlen, UVM_DEFAULT)
        `uvm_field_int(arsize, UVM_DEFAULT)
        `uvm_field_int(arburst, UVM_DEFAULT)
        `uvm_field_queue_int(rdata, UVM_DEFAULT)
        `uvm_field_queue_int(rresp, UVM_DEFAULT)
        // common
        `uvm_field_int(burst_len, UVM_DEFAULT)
        `uvm_field_int(burst_size, UVM_DEFAULT)
        `uvm_field_int(burst_type, UVM_DEFAULT)
        `uvm_field_int(is_write, UVM_DEFAULT)
        `uvm_field_int(lock, UVM_DEFAULT)
        `uvm_field_int(qos, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "axi_txn");
        super.new(name);
    endfunction
	
endclass
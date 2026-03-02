class axi_agent extends uvm agent;
    `uvm_component_utils(axi_agent)
    
    axi_seqr        seqr_a;
    axi_driver      driver_a;
    axi_monitor     monitor_a;

    uvm_active_passive_enum     is_active = UVM_ACTIVE; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor_a = axi_monitor::type_id::create("monitor_a", this);

        if (is_active) begin
            driver_a = axi_driver::type_id::create("driver_a", this);
            seqr_a   = axi_seqr::type_id::create("seqr_a", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver_a.item_port.connect(seqr_a.item_export);
    endfunction

endclass
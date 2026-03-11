class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

	virtual interface axi_if	  vif;
    uvm_analysis_port #(axi_txn)  ap;    

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

	extern function void build_phase(uvm_phase phase);
	extern task 		 run_phase(uvm_phase phase);
endclass

function void axi_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	if(!uvm_config_db#(virtual interface axi_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "axi_monitor : virtual interface not set")
endfunction

task axi_monitor::run_phase(uvm_phase phase);
	axi_txn		tr;
	forever begin
		@(posedge vif.ACLK)
		if(vif.AWVALID && vif.AWREADY) begin
			tr = axi_txn::type_id::create("tr");
			tr.addr = vif.AWADDR;
			tr.burst_len = vif.AWLEN;
		end
		
		if(vif.WVALID && vif.WREADY) begin
			tr.data = vif.WDATA;
		end
	end
endtask
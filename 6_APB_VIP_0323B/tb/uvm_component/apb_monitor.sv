class apb_monitor extends uvm_monitor;
	`uvm_component_utils(apb_monitor)
	uvm_analysis_port#(apb_txn)		ap;
	virtual interface apb_if		vif;


	function new(string name = "apb_monitor", uvm_component parent);
        super.new(name, parent);
		ap = new("ap", this);
    endfunction

	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function void apb_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual interface apb_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "apb_monitor : virtual interface not set")
endfunction

task apb_monitor::run_phase(uvm_phase phase);
	apb_txn			tr;
	forever begin
		@(posedge vif.PCLK)
		if(vif.PENABLE && vif.PWRITE) begin
			tr = apb_txn::type_id::create("tr");
			tr.addr <= vif.PADDR;
			tr.data <= vif.PWDATA;

			//scoreboard
			ap.write(tr);			
		end
	end
endtask
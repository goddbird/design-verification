class apb_driver extends uvm_driver #(apb_txn);
	`uvm_component_utils(apb_driver)

	virtual interface apb_if		vif;

	function new(string name = "apb_driver", uvm_component parent);
        super.new(name, this);
    endfunction

	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task drive_write(apb_txn  tr);
endclass

function void apb_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual interface apb_if)::get(this, "", "vif", vif))
		`uvm_fatal("NOVIF", "apb_driver : virtual interface not set")
endfunction

task apb_driver::run_phase(uvm_phase phase);
	apb_txn			tr;
	super.run_phase(phase);
	forever begin
		seq_item_port.get_next_item(tr);
		drive_write(tr);
		seq_item_port.item_done();
	end
endtask 

task apb_driver::drive_write(apb_txn  tr);
	@(posedge vif.PCLK)
	// send PDATA
	vif.PENABLE <= 1;
	vif.PWRITE	<= 1;
	vif.PADDR	<= tr.addr;
	vif.PWDATA	<= tr.data;

	// finish send
	@(posedge vif.PCLK)
	wait(vif.PREADY);

	`uvm_info(get_type_name(), tr.sprint, UVM_NONE)
endtask


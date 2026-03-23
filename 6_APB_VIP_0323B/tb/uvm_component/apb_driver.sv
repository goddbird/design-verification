class apb_driver extends uvm_driver #(apb_txn);
	`uvm_component_utils(apb_driver)

	virtual interface apb_if		vif;

	function new(string name = "apb_driver", uvm_component parent);
        super.new(name, parent);
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
	
	// initial reset
	vif.PENABLE		<= 0;
	vif.PWRITE		<= 0;
	wait(vif.PRESETn);
	`uvm_info(get_type_name(), "Reset released, starting driver...", UVM_NONE)

	forever begin
		seq_item_port.get_next_item(tr);
		drive_write(tr);
		seq_item_port.item_done();
	end
endtask 

task apb_driver::drive_write(apb_txn  tr);
	@(posedge vif.PCLK);
	// APB setup phase
	vif.PENABLE <= 0;
	vif.PWRITE	<= 1;
	vif.PADDR	<= tr.addr;
	vif.PWDATA	<= tr.data;

	// APB access phase
	@(posedge vif.PCLK);
	vif.PENABLE <= 1;

	// wait for slave
	@(posedge vif.PCLK)
	wait(vif.PREADY === 1);

	// back to  idle
	vif.PENABLE <= 0;

	`uvm_info(get_type_name(), tr.sprint, UVM_NONE)
endtask


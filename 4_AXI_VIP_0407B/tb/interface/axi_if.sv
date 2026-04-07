interface axi_if #(
	parameter	ADDR_WIDTH = 32,
	parameter	DATA_WIDTH = 32
	
)(
	input logic ACLK,
	input logic ARESETn
);
	// ---------------------
	// Write Address Channel
	// ---------------------	
	logic [ADDR_WIDTH - 1 : 0] 	AWADDR;	
	logic						AWVALID;
	logic						AWREADY;
	logic [7:0]					AWLEN;
	logic [2:0]					AWSIZE;
	logic [1:0]					AWBURST;
	logic [3:0]					DBG_AWID;
	// ---------------------
	// Write Data Channel
	// ---------------------		
	logic [DATA_WIDTH - 1 : 0]	WDATA;
	logic						WVALID;
	logic						WREADY;
	logic						WLAST;
	// ---------------------
	// Write Response Channel
	// ---------------------			
	logic [1:0]					BRESP; 
	logic						BVALID;
	logic						BREADY;

	// ---------------------
	// Read Address Channel
	// ---------------------
	logic [ADDR_WIDTH - 1 : 0]	ARADDR;
	logic						ARVALID;
	logic						ARREADY;
	logic [7:0]					ARLEN;
	logic [2:0]					ARSIZE;
	logic [1:0]					ARBURST;

	// ---------------------
	// Read Data Channel
	// ---------------------
	logic [DATA_WIDTH - 1 : 0]	RDATA;
	logic						RVALID;
	logic						RREADY;
	logic						RLAST;
	logic [1:0]					RRESP;
		
	// ---------------------
	// Master Modport (Driver)	
	// ---------------------	
	modport master(input ACLK, ARESETn, AWREADY, WREADY, BRESP, BVALID, 
	output AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, DBG_AWID,
	output WDATA, WVALID, WLAST,
	output BREADY
	);

	// Read Master Modport (Driver)
	modport read_master(input ACLK, ARESETn, ARREADY, RDATA, RVALID, RLAST, RRESP,
		output ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID,
		output RREADY
	);
	
	// ---------------------
	// Slave Modport (DUT)	
	// ---------------------	
	modport slave(input ACLK, ARESETn, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, 
	input WDATA, WVALID, WLAST,
	input BREADY, 
	output AWREADY, WREADY, BRESP, BVALID
	);	

	// Read Slave Modport (DUT)
	modport read_slave(input ACLK, ARESETn, ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID,
		input RREADY,
		output ARREADY, RDATA, RVALID, RLAST, RRESP
	);
endinterface
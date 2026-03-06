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

	// ---------------------
	// Write Data Channel
	// ---------------------		
	logic [DATA_WIDTH - 1 : 0]	WDATA;
	logic						WVALID;
	logic						WREADY;
	
	// ---------------------
	// Write Response Channel
	// ---------------------			
	logic [1:0]					BRESP; 
	logic						BVALID;
	logic						BREADY;
	
	// ---------------------
	// Master Modport (Driver)	
	// ---------------------	
	modport master(input ACLK, ARESETn, AWREADY, WREADY, BRESP, BVALID, output AWADDR, AWVALID, WDATA, WVALID, BREADY);
	
	// ---------------------
	// Slave Modport (DUT)	
	// ---------------------	
	modport slave(input ACLK, ARESETn, AWADDR, AWVALID, WDATA, WVALID, BREADY, output AWREADY, WREADY, BRESP, BVALID);	
endinterface
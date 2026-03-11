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
	// Master Modport (Driver)	
	// ---------------------	
	modport master(input ACLK, ARESETn, AWREADY, WREADY, BRESP, BVALID, 
	output AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID,
	output WDATA, WVALID, WLAST,
	output BREADY
	);
	
	// ---------------------
	// Slave Modport (DUT)	
	// ---------------------	
	modport slave(input ACLK, ARESETn, AWADDR, AWLEN, AWSIZE, AWBURST, AWVALID, 
	input WDATA, WVALID, WLAST,
	input BREADY, 
	output AWREADY, WREADY, BRESP, BVALID
	);	
endinterface
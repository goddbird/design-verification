interface axi_if #(
	parameter	ADDR_WIDTH = 32,
	parameter	DATA_WIDTH = 32,
	
)(
	input logic ACLK,
	input logic ARESETn
);
	// Write Address Channel
	logic [3:0]		AWID;
	logic [31:0] 	AWADDR;
	
	logic			AWVALID;
	logic			AWREADY;
	
	
	logic [31:0]	WDATA;
	logic			WVALID;
	logic			WREADY;
	logic [1:0]		BRESP;
	logic			BVALID;
	logic			BREADY;
endinterface
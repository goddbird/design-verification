module axi_write_slave #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32
)(
	input logic		ACLK;
	input logic		ARESETn;

	// Write Address Channel
	input logic [ADDR_WIDTH - 1 : 0] AWADDR,
	input logic		AWVALID,	
	output logic	AWREADY,

	// Write Data Channel
	input logic [DATA_WIDTH - 1 : 0] WDATA,
	input logic		WVALID,	
	output logic	WREADY,	
	
	// Write Response
	input logic 	BRESP,
	input logic		BREADY,
	output logic	BVALID
);
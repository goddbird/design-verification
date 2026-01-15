interface axi_if (input logic ACLK, input logic ARESETn);
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
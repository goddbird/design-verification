interface apb_if #(
	parameter	ADDR_WIDTH = 32,
	parameter	DATA_WIDTH = 32
	
)(
	input logic PCLK,
	input logic PRESETn
);
	// Master
	logic [ADDR_WIDTH - 1 : 0] 	PADDR;
	logic						PENABLE;
	logic						PWRITE;
	logic [DATA_WIDTH- 1 : 0]	PWDATA;
	logic [2:0]					PPROT;
	logic 						PSTRB;
	// Slave
	logic [DATA_WIDTH- 1 : 0]	PRDATA;
	logic 						PREADY;
	logic						PSLVERR;

endinterface

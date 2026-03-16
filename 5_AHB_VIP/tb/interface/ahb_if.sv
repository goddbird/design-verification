interface ahb_if #(
	parameter	ADDR_WIDTH = 32,
	parameter	DATA_WIDTH = 32
	
)(
	input logic HCLK,
	input logic HRESETn
);

	logic [ADDR_WIDTH - 1 : 0] 	HADDR;	
	logic [1:0]					HTRANS;
	logic 						HWRITE;	
	logic [2:0]					HSIZE;	
	logic [2:0]					HBURST;
	logic [3:0]					HPROT;
	
	logic [DATA_WIDTH- 1 : 0]	HWDATA;	
	logic [DATA_WIDTH- 1 : 0]	HRDATA;
	
	logic						HREADY;
	logic						HRESP;
endinterface
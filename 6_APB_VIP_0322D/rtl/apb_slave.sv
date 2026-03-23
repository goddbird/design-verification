module apb_slave#(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32
)(
	input logic 						PCLK,
	input logic 						PRESETn,
	input logic	[ADDR_WIDTH-1 : 0]		PADDR,
	input logic							PENABLE,
	input logic							PWRITE,
	input logic	[DATA_WIDTH-1 : 0]		PWDATA,
	input logic	[2:0]					PPROT,
	input logic							PSTRB,

	output logic [DATA_WIDTH-1 : 0]		PRDATA,
	output logic						PREADY,
	output logic						PSLVERR
);
	logic [DATA_WIDTH-1:0]	mem [0:3]; //FIFO [0:3]

	assign PREADY 	= 1'b1;
	assign PSLVERR	= 1'b0;

	always_ff @(posedge PCLK or negedge PRESETn) begin
		if(PRESETn) begin
			for (int i = 0; i < 4; i++) mem[i] <= '0;
		end
		else begin
			if(PENABLE && PWRITE) begin
				mem[PADDR]		<= PWDATA;
			end
		end
	end

	always_comb begin
		if(!PWRITE) begin
			PRDATA		= mem[PADDR];
		end
		else begin
			PRDATA = '0;
		end
	end
endmodule
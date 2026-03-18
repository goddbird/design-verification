module ahb_write_slave #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32
)(
	input logic						 	HCLK,
	input logic							HRESETn,

	// Write Address Channel
	input logic [ADDR_WIDTH - 1 : 0] 	HADDR,
	input logic	[1:0]					HTRANS,
	input logic 						HWRITE,	
	input logic [2:0]					HSIZE,
	input logic [2:0]					HBURST,
	input logic [3:0]					HPROT,	
	input logic [DATA_WIDTH- 1 : 0]		HWDATA,
	
	output logic [DATA_WIDTH- 1 : 0]	HRDATA,	
	output logic						HREADY,
	output logic						HRESP
);

	// memory	
	logic [DATA_WIDTH - 1 : 0]			mem [0:1023]; // Depth 1024
	//pipeline register
	logic [ADDR_WIDTH - 1 : 0]			addr_reg;
	logic								write_reg;
	logic								valid_reg;
	
	// -------------------------
	// HREADY / HRESP
	// -------------------------
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn) begin
			HREADY 		<= 1'b1;
			HRESP  		<= 1'b0;
		end
		else begin
			HREADY 		<= 1'b1;
			HRESP  		<= 1'b0;			
		end
	end

	// -------------------------
	// Address phase (pipeline)
	// -------------------------
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn) begin
			addr_reg 	<= 0;
			write_reg	<= 0;
			valid_reg	<= 0;
		end
		else if (HREADY) begin
			if (HTRANS == 2'b10 || HTRANS == 2'b11) begin
				addr_reg 	<= HADDR;
				write_reg	<= HWRITE;
				valid_reg 	<= 1;
			end
			else begin
				valid_reg	<= 0;
			end
		end
	end
	
	// -------------------------
	// Write phase (pipeline)
	// -------------------------
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if(valid_reg && write_reg && HREADY) begin
			mem[addr_reg[11:2]]	<= HWDATA;
		end	
	end	
	
	// -------------------------
	// Read phase (pipeline)
	// -------------------------
	always_ff @(posedge HCLK or negedge HRESETn) begin
		if(!HRESETn) begin
			HRDATA			<= 0;
		end
		else if(valid_reg && write_reg == 0 && HREADY) begin
			HRDATA			<= mem[addr_reg[11:2]];
		end	
	end		
endmodule
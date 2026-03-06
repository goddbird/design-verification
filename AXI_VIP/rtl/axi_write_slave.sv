module axi_write_slave #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32
)(
	input logic		ACLK,
	input logic		ARESETn,

	// Write Address Channel
	input logic [ADDR_WIDTH - 1 : 0] AWADDR,
	input logic		AWVALID,	
	output logic	AWREADY,

	// Write Data Channel
	input logic [DATA_WIDTH - 1 : 0] WDATA,
	input logic		WVALID,	
	output logic	WREADY,	
	
	// Write Response
	input logic		BREADY,
	output logic [1:0]	BRESP,	
	output logic	BVALID
);
	typedef enum logic [1:0]{
		IDLE, ADDR_ACCEPTED, RESP_SENT
	}state_t;

	state_t		state;
	
	logic [ADDR_WIDTH - 1 : 0] write_addr;// to receive addr
	logic [DATA_WIDTH - 1 : 0] write_data;// to receive data

	
	always @(posedge ACLK or negedge ARESETn) begin
		if (!ARESETn) begin
			state	<= IDLE;
		end
		else begin
			case (state)
				IDLE : 			if (AWVALID && AWREADY) begin write_addr <= AWADDR; state <= ADDR_ACCEPTED; end
				ADDR_ACCEPTED : if (WVALID && WREADY) 	begin write_data <= WDATA;  state <= RESP_SENT; end			
				RESP_SENT : 	if (BREADY)				begin state <= IDLE; end
			endcase
		end
	end
	
	assign AWREADY = (state == IDLE);
	assign WREADY  = (state == ADDR_ACCEPTED);
	assign BVALID  = (state == RESP_SENT);
	assign BRESP   = 2'b00; // 00: OKAY  01: EXOKAY  02: SLVERR  03: DECERR
	
endmodule
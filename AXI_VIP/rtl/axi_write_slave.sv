module axi_write_slave #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32
)(
	input logic						 	ACLK,
	input logic							ARESETn,

	// Write Address Channel
	input logic [ADDR_WIDTH - 1 : 0] 	AWADDR,
	input logic							AWVALID,	
	input logic [7:0]					AWLEN,
	input logic	[2:0]					AWSIZE,
	input logic	[1:0]					AWBURST,	
	output logic	AWREADY,

	// Write Data Channel
	input logic [DATA_WIDTH - 1 : 0] 	WDATA,
	input logic							WVALID,	
	input logic							WLAST,	
	output logic						WREADY,	
	
	// Write Response
	input logic							BREADY,
	output logic [1:0]					BRESP,	
	output logic						BVALID
);
	typedef enum logic [1:0]{
		IDLE, WRITE_DATA, RESP
	}state_t;

	state_t		state;
	
	logic [ADDR_WIDTH - 1 : 0] 			write_addr;// to receive addr
	logic [DATA_WIDTH - 1 : 0] 			write_data;// to receive data
	logic [7:0]							beat_cnt;
	logic [ADDR_WIDTH - 1 : 0]			curr_addr;
	
	always @(posedge ACLK or negedge ARESETn) begin
		if (!ARESETn) begin
			state	<= IDLE;
		end
		else begin
			case (state)
				IDLE		: if(AWVALID && AWREADY) begin
								curr_addr <= AWADDR;
								beat_cnt  <= AWLEN + 1;
								state	  <= WRITE_DATA;
							  end
				WRITE_DATA	: if(WVALID && WREADY) begin
								write_addr <= curr_addr;
								write_data <= WDATA;
								
								curr_addr  <= curr_addr + 4;
								beat_cnt   <= beat_cnt - 1;
								
								if(WLAST)
									state  <= RESP;
							  end				
				RESP		: if(BREADY)
								state 	   <= IDLE;
			endcase
		end
	end
	
	assign AWREADY = (state == IDLE);
	assign WREADY  = (state == WRITE_DATA);
	assign BVALID  = (state == RESP);
	assign BRESP   = 2'b00; // 00: OKAY  01: EXOKAY  02: SLVERR  03: DECERR
	
endmodule
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
	output logic						BVALID,

	// ---------------------
	// Read Address Channel
	// ---------------------
	input logic [ADDR_WIDTH - 1 : 0]	ARADDR,
	input logic						ARVALID,
	output logic						ARREADY,
	input logic [7:0]					ARLEN,
	input logic [2:0]					ARSIZE,
	input logic [1:0]					ARBURST,

	// ---------------------
	// Read Data Channel
	// ---------------------
	output logic [DATA_WIDTH - 1 : 0]	RDATA,
	output logic						RVALID,
	input logic							RREADY,
	output logic						RLAST,
	output logic [1:0]					RRESP
);
	typedef enum logic [1:0]{
		IDLE, WRITE_DATA, RESP
	}state_t;

	state_t	state;

	// Internal memory: 1K words
	logic [DATA_WIDTH-1:0] mem [0:1023];
	logic [ADDR_WIDTH - 1 : 0] write_addr;// to receive addr
	logic [DATA_WIDTH - 1 : 0] write_data;// to receive data
	logic [7:0] beat_cnt;
	logic [ADDR_WIDTH - 1 : 0] curr_addr;
	logic [ADDR_WIDTH - 1 : 0] read_addr;
	
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
				   WRITE_DATA   : if(WVALID && WREADY) begin
								   write_addr <= curr_addr;
								   write_data <= WDATA;
								   // Write to memory (word address)
								   mem[curr_addr[11:2]] <= WDATA;
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
	
	// --- Simple Read Channel ---
	typedef enum logic [1:0] {R_IDLE, R_SEND} rstate_t;
	rstate_t rstate;
	logic [7:0] r_cnt;

	always @(posedge ACLK or negedge ARESETn) begin
		if (!ARESETn) begin
			rstate <= R_IDLE;
			r_cnt <= 0;
			read_addr <= '0;
		end else begin
			case (rstate)
				R_IDLE: begin
					if (ARVALID) begin
						r_cnt <= ARLEN;
						read_addr <= ARADDR;
						rstate <= R_SEND;
					end
				end
				R_SEND: begin
					if (RREADY) begin
						if (r_cnt == 0) begin
							rstate <= R_IDLE;
						end else begin
							read_addr <= read_addr + 4;
							r_cnt <= r_cnt - 1;
						end
					end
				end
			endcase
		end
	end

	assign ARREADY = (rstate == R_IDLE);
	assign RVALID  = (rstate == R_SEND);
	assign RDATA   = mem[read_addr[11:2]];
	assign RLAST   = (rstate == R_SEND) && (r_cnt == 0);
	assign RRESP   = 2'b00;
endmodule
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
	// Internal memory: 1K words
	logic [DATA_WIDTH-1:0] mem [0:1023];
	logic [ADDR_WIDTH - 1 : 0] write_addr;// to receive addr
	logic [DATA_WIDTH - 1 : 0] write_data;// to receive data
	localparam int AWQ_DEPTH = 8;
	logic [ADDR_WIDTH - 1 : 0] awaddr_q [0:AWQ_DEPTH-1];
	logic [7:0] awlen_q [0:AWQ_DEPTH-1];
	int unsigned awq_wptr;
	int unsigned awq_rptr;
	int unsigned awq_count;
	logic wr_active;
	logic [ADDR_WIDTH - 1 : 0] curr_addr;
	logic [7:0] beat_cnt;
	logic [7:0] b_pending;
	logic [ADDR_WIDTH - 1 : 0] read_addr;
	logic aw_hs;
	logic aw_start_direct;
	logic aw_push_queue;
	logic aw_pop_queue;
	logic w_hs;
	logic b_hs;
	logic w_last_hs;
	
	always @(posedge ACLK or negedge ARESETn) begin
		if (!ARESETn) begin
			awq_wptr <= 0;
			awq_rptr <= 0;
			awq_count <= 0;
			wr_active <= 0;
			curr_addr <= '0;
			beat_cnt <= 0;
			b_pending <= 0;
		end
		else begin
			if (aw_push_queue) begin
				awaddr_q[awq_wptr] <= AWADDR;
				awlen_q[awq_wptr] <= AWLEN;
				awq_wptr <= (awq_wptr == AWQ_DEPTH-1) ? 0 : awq_wptr + 1;
			end

			if (!wr_active && aw_start_direct) begin
				curr_addr <= AWADDR;
				beat_cnt <= AWLEN + 1;
				wr_active <= 1;
			end
			else if (!wr_active && aw_pop_queue) begin
				curr_addr <= awaddr_q[awq_rptr];
				beat_cnt <= awlen_q[awq_rptr] + 1;
				awq_rptr <= (awq_rptr == AWQ_DEPTH-1) ? 0 : awq_rptr + 1;
				wr_active <= 1;
			end

			case ({aw_push_queue, aw_pop_queue})
				2'b10: awq_count <= awq_count + 1;
				2'b01: awq_count <= awq_count - 1;
				default: awq_count <= awq_count;
			endcase

			if (w_hs) begin
				write_addr <= curr_addr;
				write_data <= WDATA;
				mem[curr_addr[11:2]] <= WDATA;

				if (w_last_hs) begin
					wr_active <= 0;
				end else begin
					curr_addr <= curr_addr + 4;
					beat_cnt <= beat_cnt - 1;
				end
			end

			case ({w_last_hs, b_hs})
				2'b10: b_pending <= b_pending + 1;
				2'b01: b_pending <= b_pending - 1;
				default: b_pending <= b_pending;
			endcase
		end
	end

	assign aw_hs = AWVALID && AWREADY;
	assign aw_start_direct = aw_hs && !wr_active && (awq_count == 0);
	assign aw_push_queue = aw_hs && (wr_active || (awq_count > 0));
	assign aw_pop_queue = !wr_active && (awq_count > 0);
	assign w_hs = wr_active && WVALID && WREADY;
	assign b_hs = BVALID && BREADY && (b_pending > 0);
	assign w_last_hs = w_hs && ((beat_cnt == 1) || WLAST);
	
	assign AWREADY = (awq_count < AWQ_DEPTH);
	assign WREADY  = wr_active;
	assign BVALID  = (b_pending > 0);
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
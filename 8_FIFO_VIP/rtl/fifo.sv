module fifo #(
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter DEPTH = 32
)(
	input logic CLK,
	input logic RESETn,
	input logic wr,
	input logic rd,
	input logic [DATA_WIDTH-1:0] data_in,
	output logic [DATA_WIDTH-1:0] data_out
);
	logic [4:0] wptr, rptr;
	logic [DATA_WIDTH-1:0] mem [DEPTH];
	logic full, empty;

	always @(posedge CLK or negedge RESETn) begin
		if(RESETn == 0) begin
			wptr <= 0;
			rptr <= 0;
			foreach(mem[i]) begin
				mem[i] <= 0;
			end
		end else begin
			if((full && wr) || (empty && rd)) begin
				// Do nothing, can't write to full or read from empty
				$display("FIFO full or empty, operation ignored");
			end
			else if(wr) begin
				mem[wptr] <= data_in;
				wptr <= wptr + 1;
			end
			else if(rd) begin
				data_out <= mem[rptr];
				rptr <= rptr + 1;
			end
		end	
	end

	always_comb begin
		full = (wptr == rptr - 1) || (wptr == DEPTH - 1 && rptr == 0);
		empty = (wptr == rptr);
	end
endmodule
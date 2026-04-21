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
		full = ((wptr + 1) % DEPTH) == rptr;
		empty = (wptr == rptr);
	end
	// ================= Formal Assumptions (環境約束) =================
	// 告訴 Formal 工具：full 時外部不會發出 wr，empty 時外部不會發出 rd
	assume property (@(posedge CLK) disable iff (!RESETn) full  |-> !wr);
	assume property (@(posedge CLK) disable iff (!RESETn) empty |-> !rd);

	// ================= Formal Assertions =================
	// FIFO 不可 overflow: full 時 wptr 不可遞增
	property p_fifo_no_overflow;
		@(posedge CLK)
		disable iff (!RESETn)
		full |-> ##1 (wptr == $past(wptr));
	endproperty
	assert property (p_fifo_no_overflow)
		else $error("FIFO overflow: wptr changed when full");

	// FIFO 不可 underflow: empty 時 rptr 不可遞增
	property p_fifo_no_underflow;
		@(posedge CLK)
		disable iff (!RESETn)
		empty |-> ##1 (rptr == $past(rptr));
	endproperty
	assert property (p_fifo_no_underflow)
		else $error("FIFO underflow: rptr changed when empty");

	// empty/full 不可同時為 1
	property p_fifo_empty_full_consistency;
		@(posedge CLK)
		disable iff (!RESETn)
		empty |-> !full;
	endproperty
	assert property (p_fifo_empty_full_consistency)
		else $error("FIFO empty/full inconsistency");



	// =====================================================

	// ================= Cover Properties (驗證狀態可達) =================
	// 1. FIFO 真的可以被填滿 (full 狀態可達)
	cover property (@(posedge CLK) disable iff (!RESETn) full);

	// 2. FIFO 真的可以被清空 (empty 狀態可達)
	cover property (@(posedge CLK) disable iff (!RESETn) empty);

	// 3. wptr/rptr wrap-around 行為 (指標繞回)
	cover property (@(posedge CLK) disable iff (!RESETn) (wptr == 0) && ($past(wptr) == DEPTH-1));
	cover property (@(posedge CLK) disable iff (!RESETn) (rptr == 0) && ($past(rptr) == DEPTH-1));

	// 4. 寫入後讀出資料正確性 (簡單示意: 連續寫入再連續讀出)
	// 這裡僅 cover 行為，資料比對建議用 assertion 或 testbench 驗證
	// 例如: cover property (寫入一筆後，之後讀出同一筆)

	// 5. full 後 rd 一筆，full 應解除
	cover property (@(posedge CLK) disable iff (!RESETn) (full && rd && !$past(full)) |-> !full);


endmodule
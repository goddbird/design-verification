// FIFO assertion headfile，可被 include 進任意 module

// reference model
logic [DATA_WIDTH-1:0] assert_mem [DEPTH];
logic [4:0] assert_wptr, assert_rptr;
logic [DATA_WIDTH-1:0] golden_data_out;

always @(posedge CLK or negedge RESETn) begin
	if((full && wr) || (empty && rd)) begin
		// Do nothing, can't write to full or read from empty
		$display("FIFO full or empty, operation ignored");
	end
	else if(wr) begin
		assert_mem[assert_wptr] <= data_in;
		assert_wptr <= assert_wptr + 1;
	end
	else if(rd) begin
		golden_data_out <= assert_mem[assert_rptr];
		assert_rptr <= assert_rptr + 1;
	end
end


// ================= Formal Assumptions (環境約束) =================
assume property (@(posedge CLK) disable iff (!RESETn) full  |-> !wr);
assume property (@(posedge CLK) disable iff (!RESETn) empty |-> !rd);

// ================= Formal Assertions =================
property p_fifo_no_overflow;
	@(posedge CLK)
	disable iff (!RESETn)
	full |-> ##1 (wptr == $past(wptr));
endproperty
assert property (p_fifo_no_overflow)
	else $error("FIFO overflow: wptr changed when full");

property p_fifo_no_underflow;
	@(posedge CLK)
	disable iff (!RESETn)
	empty |-> ##1 (rptr == $past(rptr));
endproperty
assert property (p_fifo_no_underflow)
	else $error("FIFO underflow: rptr changed when empty");

property p_fifo_empty_full_consistency;
	@(posedge CLK)
	disable iff (!RESETn)
	empty |-> !full;
endproperty
assert property (p_fifo_empty_full_consistency)
	else $error("FIFO empty/full inconsistency");

property p_fifo_reset_status_check;
	@(posedge CLK)	
	!RESETn |-> (wptr == 0 && rptr == 0 && !full && empty);
endproperty
assert property (p_fifo_reset_status_check)
	else $error("FIFO reset status incorrect: wptr=%0d, rptr=%0d, full=%b, empty=%b", wptr, rptr, full, empty);

property p_full_empty_check;
	@(posedge CLK)
	disable iff (!RESETn)
	!(full && empty);
endproperty
assert property (p_full_empty_check);

property p_data_integrity_out;
	@(posedge CLK) 
	disable iff (!RESETn)
	(wr) |-> ##1 (data_out == $past(data_out));
endproperty
assert property (p_data_integrity_out);

property p_data_integrity_in;
	@(posedge CLK) 
	disable iff (!RESETn)
	(rd) |-> ##1 (data_in == $past(data_in));
endproperty
assert property (p_data_integrity_in);

property p_data_out_correctness;
	@(posedge CLK) 
	disable iff (!RESETn)
	(rd) |-> ##1 (data_out == assert_mem[$past(assert_rptr)]);
endproperty
assert property (p_data_out_correctness)
	else $error("FIFO data integrity error: expected %h, got %h", assert_mem[$past(assert_rptr)], data_out);

property p_wptr_liveness;
  @(posedge CLK) disable iff (!RESETn)
  (wr && !full) |=> ##[1:$] (wptr != $past(wptr));
endproperty
assert property (p_wptr_liveness)
  else $error("Liveness failed: wptr did not update under write pressure");

property p_rptr_liveness;
  @(posedge CLK) disable iff (!RESETn)
  (rd && !empty) |=> ##[1:$] (rptr != $past(rptr));
endproperty
assert property (p_rptr_liveness)
  else $error("Liveness failed: rptr did not update under read pressure");


// ================= Cover Properties (驗證狀態可達) =================
cover property (@(posedge CLK) disable iff (!RESETn) full);
cover property (@(posedge CLK) disable iff (!RESETn) empty);
cover property (@(posedge CLK) disable iff (!RESETn) (wptr == 0) && ($past(wptr) == DEPTH-1));
cover property (@(posedge CLK) disable iff (!RESETn) (rptr == 0) && ($past(rptr) == DEPTH-1));
cover property (@(posedge CLK) disable iff (!RESETn) (full && rd && !$past(full)) |=> !full);
cover property (@(posedge CLK) disable iff (!RESETn) (empty && wr && !$past(empty)) |=> !empty);

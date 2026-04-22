// FIFO assertion headfile，可被 include 進任意 module

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



// ================= Cover Properties (驗證狀態可達) =================
cover property (@(posedge CLK) disable iff (!RESETn) full);
cover property (@(posedge CLK) disable iff (!RESETn) empty);
cover property (@(posedge CLK) disable iff (!RESETn) (wptr == 0) && ($past(wptr) == DEPTH-1));
cover property (@(posedge CLK) disable iff (!RESETn) (rptr == 0) && ($past(rptr) == DEPTH-1));
cover property (@(posedge CLK) disable iff (!RESETn) (full && rd && !$past(full)) |=> !full);
cover property (@(posedge CLK) disable iff (!RESETn) (empty && wr && !$past(empty)) |=> !empty);
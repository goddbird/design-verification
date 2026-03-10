module axi_assertions (axi_if vif);
	logic [7:0] beat_cnt;
	
	always @(posedge vif.ACLK or negedge vif.ARESETn) begin
		if(!vif.ARESETn)
			beat_cnt <= 0;
		else begin
			// address handshake
			if(vif.AWVALID && vif.AWREADY)
				beat_cnt <= vif.AWLEN + 1;
			
			// data handshake
			if(vif.WVALID && vif.WREADY)
				beat_cnt <= beat_cnt - 1;
		end
	end
	
	property wlast_check;
		@(posedge vif.ACLK) disable iff(!vif.ARESETn)
		(vif.WVALID && vif.WREADY && beat_cnt == 1)
		|-> vif.WLAST;
	endproperty
	
	assert property (wlast_check)
	else begin
		$error("AXI protocol violation: WLAST missing");
		$finish;
	end
endmodule
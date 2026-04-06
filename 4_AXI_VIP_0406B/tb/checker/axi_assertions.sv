module axi_assertions (axi_if vif);
	int unsigned pending_beats_q[$];
	int unsigned active_beats;
	
	always @(posedge vif.ACLK or negedge vif.ARESETn) begin
		if(!vif.ARESETn) begin
			pending_beats_q.delete();
			active_beats = 0;
		end
		else begin
			if(vif.AWVALID && vif.AWREADY)
				pending_beats_q.push_back(vif.AWLEN + 1);

			if(vif.WVALID && vif.WREADY) begin
				if(active_beats == 0) begin
					if(pending_beats_q.size() == 0) begin
						$error("AXI protocol violation: W handshake without matched AW");
						$finish;
					end
					active_beats = pending_beats_q.pop_front();
				end

				if((active_beats == 1) && !vif.WLAST) begin
					$error("AXI protocol violation: WLAST missing on final beat");
					$finish;
				end

				if((active_beats > 1) && vif.WLAST) begin
					$error("AXI protocol violation: WLAST asserted before final beat");
					$finish;
				end

				if(active_beats > 0)
					active_beats = active_beats - 1;
			end
		end
	end
endmodule
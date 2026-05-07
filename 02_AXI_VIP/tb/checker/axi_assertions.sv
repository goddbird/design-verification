module axi_assertions (axi_if vif);
	int unsigned pending_beats_q[$];
	int unsigned pending_id_q[$];
	int unsigned id_outstanding_count[16];
	int unsigned active_beats;
	logic [3:0] active_id;
	logic active_id_valid;
	logic [15:0] outstanding_id_mask;
	int unsigned outstanding_txn;
	int unsigned i;
	
	always @(posedge vif.ACLK or negedge vif.ARESETn) begin
		if(!vif.ARESETn) begin
			pending_beats_q.delete();
			pending_id_q.delete();
			for(i = 0; i < 16; i++)
				id_outstanding_count[i] = 0;
			active_beats = 0;
			active_id = '0;
			active_id_valid = 0;
			outstanding_id_mask = '0;
			outstanding_txn = 0;
		end
		else begin
			if(vif.AWVALID && vif.AWREADY) begin
				pending_beats_q.push_back(vif.AWLEN + 1);
				pending_id_q.push_back(vif.DBG_AWID);
				id_outstanding_count[vif.DBG_AWID] = id_outstanding_count[vif.DBG_AWID] + 1;
				outstanding_txn = outstanding_txn + 1;
			end

			if(vif.BVALID && vif.BREADY) begin
				if(pending_id_q.size() == 0) begin
					$error("AXI protocol violation: B handshake without matched AW");
					$finish;
				end
				else begin
					int unsigned done_id;
					done_id = pending_id_q.pop_front();
					if(id_outstanding_count[done_id] > 0)
						id_outstanding_count[done_id] = id_outstanding_count[done_id] - 1;
					if(outstanding_txn > 0)
						outstanding_txn = outstanding_txn - 1;
				end
			end

			if(vif.WVALID && vif.WREADY) begin
				if(active_beats == 0) begin
					if(pending_beats_q.size() == 0) begin
						$error("AXI protocol violation: W handshake without matched AW");
						$finish;
					end
					active_beats = pending_beats_q.pop_front();
					if(pending_id_q.size() == 0) begin
						$error("AXI checker internal error: beat queue and id queue out of sync");
						$finish;
					end
					active_id = pending_id_q[0][3:0];
					active_id_valid = 1;
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

				if(active_beats == 1)
					active_id_valid = 0;
			end

			outstanding_id_mask = '0;
			for(i = 0; i < 16; i++) begin
				if(id_outstanding_count[i] > 0)
					outstanding_id_mask[i] = 1'b1;
			end
		end
	end
endmodule
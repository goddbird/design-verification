module testbench;
    reg clk;
    integer cycles1, cycles2, i;

    // 例化待測模組（DUT: Device Under Test）
    top uut (
        .clk(clk)
    );

    // **產生時脈信號**
    initial begin
        clk = 0; // ✅ 初始化 clk
        forever #10 clk = ~clk; // ✅ 讓 clk 擺動，時鐘週期 = 20
    end

    initial begin
        fork
            uut.start_device1();
            uut.start_device2();
          begin: TEST
              cycles1 = $time / uut.PERIOD; // 計算設備 1 延遲
              uut.test_device1();
              cycles1 = $time / uut.PERIOD - cycles1;

              cycles2 = $time / uut.PERIOD; // 計算設備 2 延遲
              uut.test_device2();
              cycles2 = $time / uut.PERIOD - cycles2;

              // 掃描測試：變化設備 2 的請求時間
              for (i = cycles1; i <= cycles2 + 2 * cycles1; i = i + 1) begin
                  fork
                      repeat (cycles1 + cycles2) @(posedge clk) uut.test_device1();
                      repeat (i) @(posedge clk) uut.test_device2();
                  join
              end

              $finish; // 結束模擬
          end
        join
    end
  
	initial begin
		$fsdbDumpfile("sweep.fsdb"); //產生的檔名
		$fsdbDumpvars("0, testbench"); //針對哪個module產生，要填入register的名稱
	end
endmodule
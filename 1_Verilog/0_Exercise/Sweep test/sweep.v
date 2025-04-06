module top (
    input clk  // 新增時脈輸入
);
    localparam PERIOD = 20, LATENCY1 = 3, LATENCY2 = 5;

    reg request1 = 0, request2 = 0; // ✅ 確保初始為 0
    reg busy1 = 0, busy2 = 0, done1 = 0, done2 = 0;


    // **模擬設備 1 的請求處理**
    task start_device1;
        forever begin
            wait (request1) @(posedge clk) busy1 = 1;
            repeat (LATENCY1) @(posedge clk);
            @(posedge clk) done1 = 1; busy1 = 0;
            @(posedge clk) done1 = 0;
        end
    endtask

    // **模擬設備 2 的請求處理**
    task start_device2;
        forever begin
            wait (request2) @(posedge clk) busy2 = 1;
            repeat (LATENCY2) @(posedge clk);
            @(posedge clk) done2 = 1; busy2 = 0;
            @(posedge clk) done2 = 0;
        end
    endtask

    // **測試設備 1**
    task test_device1;
        begin
            @(posedge clk) request1 = 1;
            @(posedge clk) request1 = 0;
            wait (done1) @(posedge clk);
        end
    endtask

    // **測試設備 2**
    task test_device2;
        begin
            @(posedge clk) request2 = 1;
            @(posedge clk) request2 = 0;
            wait (done2) @(posedge clk);
        end
    endtask
endmodule




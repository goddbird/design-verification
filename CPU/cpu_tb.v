module test;

  // nets and variables
  reg  CLK  ;
  reg  RST  ;
  wire HALT ;

  // instantiation of cpu
  cpu  cp ( CLK, RST, HALT );

  // display test header message
  task display_head;
    begin
      $display ( "To run n'th test enter:");
      $display ( "\tdeposit test.run.number n; task test.run; run\n" );
    end
  endtask

  // run a test
  task run;
    input [7:0] number;
    reg [9*8:1] testfile;
    begin
      testfile = { "PROG", 8'h30+number, ".txt" };
      $readmemb ( testfile, cp.mem );
      @(negedge CLK) RST = 1;
      @(negedge CLK) RST = 0;
    end
  endtask

  // display test tailing message
  task display_tail;
    reg [4:0] expected_pc;
    begin
      case ( run.number )
        1: expected_pc = 5'h17;
        2: expected_pc = 5'h10;
        3: expected_pc = 5'h0c;
      endcase
      $display ( "Halted at address = %h", cp.pc   );
      $display ( "Expected  address = %h", expected_pc );
      $display ( "TEST %s", ((cp.pc === expected_pc) ? "PASSED" : "FAILED"));
    end
  endtask

  // free-running clock
  initial forever begin CLK=1; #1; CLK=0; #1; end

  // upon halt display tail and head messages and wait for user input
  always @(posedge HALT)
    begin
      display_tail;
      display_head;
      $stop;
    end

  // display head message and wait for user input
  initial
    begin
      display_head;
      $stop;
    end

endmodule



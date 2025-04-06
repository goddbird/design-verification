module readmem();
	reg testfile;
	reg [7:0] mem;
	reg [4:0] addr;
	
	task readmem;
		testfile = "test1.txt";
		$readmemh(testfile, mem);
		$display("mem = 0x%x", mem);
		
		$readmemh(testfile, mem);
		$display("mem = 0x%x", mem);
	endtask
	
	initial
    begin
      $display("lets start");
      $stop;
    end
	
	
	
endmodule
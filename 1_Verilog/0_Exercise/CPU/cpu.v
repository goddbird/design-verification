module cpu
(
  input  wire CLK  ,
  input  wire RST  ,
  output wire HALT  
);

  reg [4:0] pc;         // program counter
  reg [7:0] ac;         // accumulator
  reg [7:0] mem [0:31]; // memory

  wire [7:0] instruction = mem[pc];			//memory上的內容
  wire [7:5] opcode      = instruction[7:5];//opcode
  wire [4:0] operand     = instruction[4:0];//預計跳轉的address or 預計改內容的address
  wire [7:0] rvalue      = mem[operand];	//選定address的data (感覺比較像是去Stack拿內容的概念)

  always @(posedge CLK)
    if ( RST )
      pc <= 0 ;
    else
      case ( opcode )
        0: begin                    pc<=pc;         end // HLT : 停止CPU
        1: begin                    pc<=pc+1+(!ac); end // SKZ : 當ac等於0，則跳過下一個指令
        2: begin ac <= ac + rvalue; pc<=pc+1;       end // ADD : ac + data
        3: begin ac <= ac & rvalue; pc<=pc+1;       end // AND : ac & data 
        4: begin ac <= ac ^ rvalue; pc<=pc+1;       end // XOR : ac ^ data
        5: begin ac <=      rvalue; pc<=pc+1;       end // LDA : ac = data
        6: begin mem[operand]<=ac;  pc<=pc+1;       end // STO : 直接改address上的data值，把ac塞入
        7: begin                    pc<=operand;    end // JMP : pc直接jump到address
      endcase

  assign HALT = opcode == 0;

endmodule



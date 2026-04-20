interface fifo_if #(
    parameter DATA_WIDTH = 32, 
    parameter DEPTH = 32
)(
    input logic clk,
    input logic rst_n
);    
    logic wr_en;
    logic rd_en;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0] data_out;
    logic full;
    logic empty;
endinterface
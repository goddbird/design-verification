`timescale 1ns / 1 ns 

module rcvr
#(
  parameter integer HEADER_SIZE      = 8     ,
  parameter integer HEADER_VALUE     = 8'ha5 ,
  parameter integer BODY_SIZE        = 16     
 )
 (
  input  wire       SCLK  ,
  input  wire       RST   ,
  input  wire       SDATA ,
  input  wire       ACK   ,
  output wire       READY ,
  output wire [7:0] DOUT   
 ) ;

  // might not yet be fully supported
  parameter  integer COUNTER_SIZE = /* $clog2(BODY_SIZE)                */ 4 ;
  parameter  integer ACK_COUNT    = /* $ceil($itor(BODY_SIZE)/$itor(8)) */ 2 ;
  parameter  integer ACK_SIZE     = /* $clog2(ACK_COUNT) + 1            */ 2 ;

  localparam integer SHIFTH = 0 ,
                     SHIFTB = 1 ;

  reg                         state  ;
  reg  [ COUNTER_SIZE-1 : 0 ] count  ;
  reg  [ HEADER_SIZE-1  : 0 ] header ;
  reg  [ BODY_SIZE-1    : 0 ] body   ;
  reg  [ BODY_SIZE-1    : 0 ] buffer ;
  reg  [ ACK_SIZE-1     : 0 ] rdycnt ;

  always @ ( posedge SCLK )
    if ( RST )
      begin
        state  <= SHIFTH ;
        header <= 0 ;
        count  <= 0 ;
        rdycnt <= 0 ;
      end
    else
      begin : BEHAVIOR

        // temporary variables
        reg  [ HEADER_SIZE-1 : 0 ] header_next ;
        reg  [ BODY_SIZE-1 : 0 ]   body_next   ;
        header_next = (header << 1) | SDATA ;
        body_next   = (  body << 1) | SDATA ;

        // state machine
        case ( state )
          SHIFTH : if (header_next == HEADER_VALUE) state <= SHIFTB ;
          SHIFTB : if (count == BODY_SIZE-1)        state <= SHIFTH ;
        endcase

        // header
        if ( state == SHIFTH )
          if ( header_next == HEADER_VALUE )
            header <= 0 ;
          else
            header <= header_next ;

        // body
        if ( state == SHIFTB )
          body <= body_next ;

        // counter
        if ( state == SHIFTB )
          if ( count == BODY_SIZE-1 )
            count <= 0 ;
          else
            count <= count + 1 ;

        // buffer
        if ( count == BODY_SIZE-1 )
          buffer <= body_next ;
        else
          if ( ACK )
            buffer <= buffer << 8 ;

        // ready
        if ( count == BODY_SIZE-1 )
          rdycnt <= 1 ;
        else
          if ( ACK )
            if ( rdycnt[ACK_SIZE-1:1] == ACK_COUNT-1 )
              rdycnt <= 0 ;
            else
              rdycnt <= rdycnt + 2 ;

      end // BEHAVIOR

  assign READY = rdycnt[0] ;
  assign DOUT  = buffer[BODY_SIZE-1:BODY_SIZE-8] ;

endmodule

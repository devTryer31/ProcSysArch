`timescale 1ns / 1ps

module RegsFile(
    input clk,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input WE3,
    input [31:0] WD3,
    output [31:0] RD1,
    output [31:0] RD2
    );
    
    reg [31:0] Reg [0:31];
    
    assign RD1 = (A1 == 0)? 0:Reg[A1];
    assign RD2 = (A2 == 0)? 0:Reg[A2];
    
    always @ (posedge clk)
        if (WE3) Reg[A3] <= WD3;
endmodule

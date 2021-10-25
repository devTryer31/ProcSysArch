`timescale 1ns / 1ps

module Memory64x32(
    input clk,
    input [5:0] adr,
    input [31:0] wd,
    input we,
    output reg [31:0] rd
    );
    reg [31:0] RAM [0:255];
    
    always @ (posedge clk)
    begin
        if (we) RAM[adr] <= wd;
        assign rd = RAM[adr];
    end
endmodule

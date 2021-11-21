`timescale 1ns / 1ps

module Memory64x32(
    input clk,
    input [5:0] adr,
//    input [31:0] wd,
//    input we,
    output [31:0] rd
    );
    reg [31:0] RAM [0:255];

    assign rd = RAM[adr];
// —ейчас нам не нужна запись в п€м€ть извне.
//    always @ (posedge clk)
//        if (we) RAM[adr] <= wd;
    
initial $readmemb("memF.mem", RAM);

endmodule

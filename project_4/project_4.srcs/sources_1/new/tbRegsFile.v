`timescale 1ns / 1ps

`define clk_period 20

module TbRegsFile();
reg clk;
reg [4:0] A1, A2, A3;
reg WE3;
reg [31:0] WD3;

wire [31:0] RD1, RD2;

RegsFile RF(
    .clk(clk),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .WE3(WE3),
    .WD3(WD3),
    .RD1(RD1),
    .RD2(RD2)
);

initial clk = 1'b0;
always #(`clk_period/10)
    clk = ~clk;

initial 
begin
    TestRegsFile(4'b00, 4'b00, 4'b01, 1'b1, 31);
    TestRegsFile(4'b00, 4'b00, 4'b10, 1'b1, 63);
    TestRegsFile(4'b01, 4'b10, 4'b00, 1'b0, 0);
    $stop;
end

task TestRegsFile(input [4:0] a1, a2, a3, input we3, input [31:0] wd3);
begin
    A1 = a1; A2 = a2; A3 = a3;
    WE3 = we3; WD3 = wd3;
    #80;
    
    if (WE3)
        $display($time, "\t Writing: *[%d] <- %d", A3, WD3);

    if (!WE3)
        $display($time, "\t Reading: *[%d] -> %d, *[%d] -> %d", a1, RD1, a2, RD2);
    
    $stop;
    
    #80;
end
endtask

endmodule

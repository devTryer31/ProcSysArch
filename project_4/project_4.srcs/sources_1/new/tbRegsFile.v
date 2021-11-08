`timescale 1ns / 1ps

module TbProgramDevice();
reg clk;

reg [31:0] TotalIN;
wire [31:0] TotalLedOut; 

ProgramDevice pd(
.clk(clk),
.IN(TotalIN),
.LedOut(TotalLedOut)
);

initial clk = 1'b0;
always #2 clk = ~clk;

initial 
begin
    #10 
    //$stop();
    Test();
    $stop;
end

task Test();
begin
//    TotalIN = 5;
//    #950;
//        $display($time, "!my logs: \t %b->%b", TotalIN, TotalLedOut);
//    TotalIN = 13;
//    #950;
//        $display($time, "!my logs: \t %b->%b", TotalIN, TotalLedOut);
    TotalIN = 61;
    #950;
        $display($time, "!my logs: \t %b->%b", TotalIN, TotalLedOut);
//    #180;
end
endtask

endmodule

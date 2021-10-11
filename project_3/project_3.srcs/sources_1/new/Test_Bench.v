`timescale 1ns / 1ps

`define ADD 5'b00000
`define SUB 5'b01000
`define LDSh 5'b00001 //left double shift <<
`define SMALLER 5'b00010
`define uSMALLER 5'b00011
`define XOR 5'b00100
`define RDSh 5'b00101
`define RTSh 5'b01101 //right triple shift
`define OR 5'b00110 
`define AND 5'b00111 

`define DEqual 5'b11000 //==
`define NEqual 5'b11001 //!=
`define ISLESS 5'b11100 //<
`define GRorEQ 5'b11101 //>=
`define uISLESS 5'b11110 //unsigned(<)
`define uGRorEQ 5'b11111 //unsigned(>=)

//`define Gf $display("Good flag value");
//`define Bf $display("Bad flag value");
//`define Gr $display("Good res value");
//`define Br $display("Bad res value");
//`define Pp $display("a = %d, b = %d, func = %d, res = %d, flag = %d | cor_flag = %d cor_ras = %d", a,b,func,res, correct_res, correct_flag);

module Test_Bench();
reg	func, a, b;
wire res, flag;

reg correct_res, correct_flag;

ALU_RISC_V alu_risc_v (func, a, b, res, flag);

initial begin

correct_res = 0; correct_flag = 0;

for (a=0; a<1024; a=a+1) begin 
    for (b=0; b<1024; b=b+1) begin 
        for (func=5'b00000; func<5'b11111; func=func+1) begin
//           res = 0; flag = 0;
           #10
            case (func)
                `ADD:	correct_res = a + b;
                `SUB:	correct_res = a - b;
                `LDSh:	correct_res = a << b;
                `SMALLER:	correct_res = a < b;
                `uSMALLER:	correct_res = $unsigned(a < b);
                `XOR:	correct_res = a ^ b;
                `RDSh:	correct_res = a >> b;
                `RTSh:	correct_res = a >>> b;
                `OR:	correct_res = a | b;
                `AND:	correct_res = a & b;
                
                `DEqual:	correct_flag = a == b;
                `NEqual:	correct_flag = a != b;
                `ISLESS:	correct_flag = a < b;
                `GRorEQ:	correct_flag = a >= b;
                `uISLESS:	correct_flag = $unsigned(a < b);
                `uGRorEQ:	correct_flag = $unsigned(a > b);
             endcase
             if(flag != correct_flag)
                $display("Bad flag value");
             else
                $display("Good flag value");
             if(res != correct_res)
                $display("Bad res value");
             else
                $display("Good res value");
             $display("a = %d, b = %d, func = %d, res = %d, flag = %d | cor_flag = %d cor_ras = %d", a,b,func,res,flag, correct_res, correct_flag);
             
           #10;
        end
    end
end


end
endmodule

`timescale 1ns / 1ps

module ProgramDevice(
input clk,
input [31:0] IN,
output [31:0] LedOut
);

wire [31:0] Instr;
wire [31:0] SE = Instr[27:5]; //Нужно добить старшими битами? 
wire [1:0] WS = Instr[29:28];

wire B = Instr[31];
wire C = Instr[30];
wire Flag;

reg [31:0] Input_to_regsFile;
wire [31:0] ALU_to_Input;

wire [31:0] RegsFileRD1_to_ALU, RegsFileRD2_to_ALU;
assign LedOut = RegsFileRD1_to_ALU;

reg [7:0] Instr_to_sum;

reg [7:0] PC = 7'b0000000;

    
Memory64x32 mem(
.clk(clk),
.adr(PC[7:0]),
//.wd(0),
//.we(1'b0),
.rd(Instr)
);

RegsFile regFile(
.clk(clk),
.A1(Instr[22:18]),
.A2(Instr[17:13]),
.A3(Instr[4:0]),
.WE3((Instr[29] | Instr[28])),
.WD3(Input_to_regsFile),
.RD1(RegsFileRD1_to_ALU),
.RD2(RegsFileRD2_to_ALU)
);

ALU_RISC_V alu(
.A(RegsFileRD1_to_ALU),
.B(RegsFileRD2_to_ALU),
.ALUop(Instr[27:23]),
.Result(ALU_to_Input),
.Flag(Flag)
);

always @ (posedge clk)
    PC <= $signed(PC) + $signed(Instr_to_sum);

always @ (*) begin
    case(WS)
        2'b01: 
             Input_to_regsFile <= IN; 
        2'b10: 
             Input_to_regsFile <= SE; 
        2'b11: 
             Input_to_regsFile <= ALU_to_Input;
        default: 
             Input_to_regsFile <= 0;
    endcase
end

always @ (*) begin
    case(((C && Flag) || B))
        2'b0:
            Instr_to_sum <= 1; 
        2'b1:
        begin
            Instr_to_sum <= Instr[12:5]; 
            $display($time, "!my logs: \t Instr_to_sum = %d", $signed(Instr[12:5]));
        end
        default: 
            Instr_to_sum <= 0;
    endcase
end


endmodule

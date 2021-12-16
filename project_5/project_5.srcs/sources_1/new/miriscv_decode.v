`timescale 1ns / 1ps

`include "miriscv_defines.v"

module miriscv_decode( 
    input [31:0] fetched_instr_i, 		    //инструкция 
    output reg [1:0] ex_op_a_sel_o, 		//Управляющий сигнал мультиплексора для выбора первого операнда АЛУ
    output reg [2:0] ex_op_b_sel_o, 		//Управляющий сигнал мультиплексора для выбора второго операнда АЛУ
    output reg [5:0] alu_op_o, 				//Операция АЛУ
    output reg mem_req_o, 				    //Запрос на доступ к памяти (часть интерфейса памяти)
    output reg mem_we_o, 					//Сигнал разрешения записи в память, «write enable» (при равенстве нулю происходит чтение)
    output reg [2:0] mem_size_o, 		    //Управляющий сигнал для выбора размера слова при чтении-записи в память(часть интерфейса памяти)
    output reg gpr_we_a_o, 				    //Сигнал разрешения записи в регистровый файл
    output reg wb_src_sel_o, 			    //Управляющий сигнал мультиплексора для выбора данных, записываемых в регистровый файл
    output reg illegal_instr_o, 		    //Сигнал о некорректной инструкции
    output reg branch_o, 					//Сигнал об инструкции условного перехода
    output reg jal_o, 						//Сигнал об инструкции безусловного перехода jal
    output reg jalr_o 						//Сигнал об инструкции безусловного перехода jarl
);

//defines clearing needed
`define OPCODE_WIDTH 5
`define LOAD 5'b00000
`define MISC_MEM 5'b00011
`define OP_IMM 5'b00100
`define AUIPC  5'b00101
`define STORE 5'b01000
`define OP 5'b01100
`define LUI 5'b01101
`define BRANCH 5'b11000
`define JALR 5'b11001
`define JAL 5'b11011

wire [6:0] opcode;
reg [2:0] func3;
reg [6:0] func7;
assign opcode = fetched_instr_i[6:0];

always @ (*) begin
    //default initializing
    ex_op_a_sel_o = 2'b00;
    ex_op_b_sel_o = 3'b000;
    mem_req_o = 1'b0;
    mem_we_o = 0;
    gpr_we_a_o = 0;
    wb_src_sel_o = 0;
    mem_size_o = 3'd0;
    jalr_o = 0;
    jal_o = 0;
    branch_o = 0;
    alu_op_o = 5'b00000;
    illegal_instr_o = 0;
    func3 = fetched_instr_i[14:12];
    
	if (opcode[1:0] != 2'b11) 
		illegal_instr_o = 1;
	else 
	begin
		case (opcode[6:2])
			`LOAD_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;//RD1
					ex_op_b_sel_o = `OP_B_IMM_I;//imm
					alu_op_o = `ALU_ADD;
					mem_req_o = 1'b1;//from Mem
					gpr_we_a_o = 1;//to rd
					wb_src_sel_o = `WB_LSU_DATA;
					
					case (func3)
						`LDST_B:
							mem_size_o = 3'd0;
						`LDST_H:
							mem_size_o = 3'd1;
						`LDST_W:
							mem_size_o = 3'd2;
						`LDST_BU:
							mem_size_o = 3'd4;
						`LDST_HU:
							mem_size_o = 3'd5;
						default:
							illegal_instr_o = 1;
					endcase
				    //$stop();
				end
			`OP_IMM:
				begin
					ex_op_a_sel_o = 2'b00;//RD1
					ex_op_b_sel_o = 3'b001;////imm
					gpr_we_a_o = 1;
					illegal_instr_o = 0;
					func7 = fetched_instr_i[31:25];
					case (func3)
						3'b000:
							alu_op_o = `ALU_ADD;
						3'b100:
							alu_op_o = `ALU_XOR;
						3'b110:
							alu_op_o = `ALU_OR;
						3'b111:
							alu_op_o = `ALU_AND;
						3'b001://0x1
							begin
								if (func7 == 7'b0000000)//must be 0x00
									alu_op_o = `ALU_SLL;
								else
									illegal_instr_o = 1;
							end
						3'b011:
							alu_op_o = `ALU_SLTU;
						3'b010:
							alu_op_o = `ALU_SLTS;
						3'b101: //0x5
							begin							
								case (func7)//must be 0x00 or 0x20
									7'b0000000: 
										alu_op_o = `ALU_SRL;
									7'h20: 
										alu_op_o = `ALU_SRA;
									default:
										illegal_instr_o = 1;
								endcase
								
							end
						default:
							illegal_instr_o = 1;
					endcase
					
				end
			`AUIPC:
				begin
					ex_op_a_sel_o = 2'b01;//PC
					ex_op_b_sel_o = 3'b010;//imm_u
					gpr_we_a_o = 1;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
				end
			`STORE_OPCODE:
				begin
					ex_op_a_sel_o = `OP_A_RS1;
					ex_op_b_sel_o = `OP_B_IMM_S;
					mem_req_o = 1'b1;
					mem_we_o = 1;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
					wb_src_sel_o = `WB_EX_RESULT;
					
				case (func3)//half part
					3'b000:
						mem_size_o = `LDST_B;
					3'b001:
						mem_size_o = `LDST_H;
					3'b010:
						mem_size_o = `LDST_W;
					default:
						illegal_instr_o = 1;
				endcase
				
				    //$stop();
				
				end
			`OP:
				begin
					ex_op_a_sel_o = 2'b00;//RD1
					ex_op_b_sel_o = 3'b000;//RD2
					gpr_we_a_o = 1;
					
					func7 = fetched_instr_i[31:25];
					
					case (func3)
						3'b000:
							case (func7)
								7'b0000000:
									alu_op_o = `ALU_ADD;
								7'h20:
									alu_op_o = `ALU_SUB;
								default: 
									illegal_instr_o = 1;
							endcase
						3'b100:
							if (func7 == 7'h0)
								alu_op_o = `ALU_XOR;
							else
								illegal_instr_o = 1;
						3'b110:
							if (func7 == 7'h0)
								alu_op_o = `ALU_OR;
							else
								illegal_instr_o = 1;
						3'b111:
							if (func7 == 7'h0)
								alu_op_o = `ALU_AND;
							else
								illegal_instr_o = 1;
						3'b001:
							if (func7 == 7'h0)
								alu_op_o = `ALU_SLL;
							else
								illegal_instr_o = 1;
						3'b101:
							case (func7)
								7'h0:
									alu_op_o = `ALU_SRL;
								7'h20:
									alu_op_o = `ALU_SRA;
								default: 
									illegal_instr_o = 1;
							endcase
						3'b010:
							if (func7 == 7'h0)
								alu_op_o = `ALU_SLTS;
							else
								illegal_instr_o = 1;
						3'b011:
							if (func7 == 7'h0)
								alu_op_o = `ALU_LTU;
							else
								illegal_instr_o = 1;
						default: 
							illegal_instr_o = 1;
					endcase
					
				end
			`LUI:
				begin
					ex_op_a_sel_o = 2'b10;
					ex_op_b_sel_o = 3'b010; //take instr[31:12]=imm_u
					gpr_we_a_o = 1;
					wb_src_sel_o = 0;
					illegal_instr_o = 0;
				end
			`BRANCH:
				begin
					branch_o = 1;
					illegal_instr_o = 0;
					
				case (func3)
					3'b000:
						alu_op_o = `ALU_EQ;
					3'b001:
						alu_op_o = `ALU_NE;
					3'b100:
						alu_op_o = `ALU_LTS;
					3'b101:
						alu_op_o = `ALU_GES;
					3'b110:
						alu_op_o = `ALU_LTU;
					3'b111:
						alu_op_o = `ALU_GEU;
					default:
						illegal_instr_o = 1;
				endcase
				end
			`JALR:
				begin
					ex_op_a_sel_o = 2'b01;
					ex_op_b_sel_o = 3'b100;
					gpr_we_a_o = 1;
					jalr_o = 1;
					alu_op_o = `ALU_ADD;
					illegal_instr_o = 0;
					
					if (func3 != 3'h0) //func3 must be equal 0x0
						illegal_instr_o = 1;
				end
			`JAL:
				begin
					ex_op_a_sel_o = 2'b01; //PC
					ex_op_b_sel_o = 3'b100; //4
					gpr_we_a_o = 1;
					jal_o = 1;
					alu_op_o = `ALU_ADD;
				end
			`SYSTEM_OPCODE:
                begin
                    ex_op_a_sel_o = `OP_A_RS1;
                    ex_op_b_sel_o = `OP_B_RS2;
                    wb_src_sel_o = `WB_EX_RESULT;
                    mem_size_o = `LDST_B;
                    alu_op_o = `ALU_ADD;
                end
			`MISC_MEM:
			     begin
                    ex_op_a_sel_o = `OP_A_RS1;
                    ex_op_b_sel_o = `OP_B_RS2;
                    wb_src_sel_o = `WB_EX_RESULT;
                    mem_size_o = `LDST_B;
                    alu_op_o = `ALU_ADD;
			     end
			 default:
                illegal_instr_o = 1;
		endcase
		
	end
	if(illegal_instr_o == 1)
        $display($time, "!my logs: \t illegal instr opcode=%b", opcode); 
end

endmodule
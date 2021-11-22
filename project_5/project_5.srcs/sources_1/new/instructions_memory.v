`timescale 1ns / 1ps

module instructions_memory(
    input [31:0] pc_adr,
    output [31:0] rd //read data
    );
    
    reg [31:0] mem[0:255];
    
    assign rd = mem[pc_adr[9:2]]; 
    
    initial $readmemb("memF.mem", mem);

endmodule

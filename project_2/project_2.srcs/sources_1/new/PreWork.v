`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2021 09:24:23
// Design Name: 
// Module Name: PreWork
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PreWork(
    input [15:0] SW,
    output [15:0] LED
    );

summator32bit addModel(
    .A( {24'b0, SW[7:0]} ),
    .B( {24'b0, SW[15:8]} ),
    .S( {17'b0, LED[14:0]} ),
    .cin(0),
    .cout(LED[15])
);

endmodule

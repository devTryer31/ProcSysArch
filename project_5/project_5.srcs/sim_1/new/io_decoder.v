`timescale 1ns / 1ps

module io_decoder(
    input we,
    input req,
    input[31:0] addr,
    output we_d1,
    output we_d0,
    output we_m,
    output req_m,
    output reg [1:0] RDsel
);

assign req_m = req && (addr < 256);
assign we_m = req_m && we;

wire req_d0 = req & ({addr[31:4], 4'b0} == 32'h80001000); //displays
wire req_d1 = req & ({addr[31:1], 1'b0} == 32'h80003000);//keyboard

assign we_d0 = we & req_d0;
assign we_d1 = we & req_d1;

always @(*)begin
    if(req_d0)
        RDsel = 2'b01;//дисплей не имеет возврата
    else if(req_d1)
        RDsel = 2'b10;
    else
        RDsel = 2'b00;//На внешнюю память
end

endmodule

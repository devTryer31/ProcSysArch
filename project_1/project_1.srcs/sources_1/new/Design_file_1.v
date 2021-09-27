module main(
    input clk, a, b,
    output k
); 
wire c;    

assign c = a & b;

always @(posedge clk)
    q <= c;

genvar i;
generate 
    for (i=0; i<3;i=i+1) begin : 
        newgen adder new(
        //inp out links   
        );
    end


endgenerate 

endmodule

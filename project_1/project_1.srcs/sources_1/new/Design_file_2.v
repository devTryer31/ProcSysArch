module summator32bit(
        input [32:0] A,
        input [32:0] B,
        input cin,
        output [32:0] S,
        output cout
);

wire [33:0] C;
assign C[0] = cin;
assign C[32] = cout;

genvar i;
generate 
    for (i=0; i<32; i=i+1) begin : 
        newgen summatorOneBit adder(
        //inp out links   
            .cin(C[i]),
            .a(A[i]),
            .b(B[i]),
            .cout(C[i+1]),
            .s(S[i])
        );
    end
endgenerate 
    
endmodule

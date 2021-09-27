module summatorOneBit(
    input cin, a, b,
    output cout, s
); 

assign s = a^b^cin;
assign cout = a&b | a&cin | b&cin;

endmodule

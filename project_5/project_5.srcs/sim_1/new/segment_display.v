`timescale 1ns / 1ps


module segment_display(
    input clk, 
    input reset, //0x8000100A
    input reg [7:0] segments_num[3:0], //0x80001000 - 0x80001007
    input reg [7:0] chouse_mod_seg_idx, //FF if mode not using (0x80001009)
    input reg [3:0] anode_idx = 0, //active display idx (0x80001008)
    );
    
function num_to_segments_decode;
    input [3:0] num;
    case(num)
        1'd0: num_to_segments_decode = 7'b1111110;
        1'd1: num_to_segments_decode = 7'b0110000;
        1'd2: num_to_segments_decode = 7'b1101101;
        1'd3: num_to_segments_decode = 7'b1111001;
        1'd4: num_to_segments_decode = 7'b0110011;
        1'd5: num_to_segments_decode = 7'b1011011;
        1'd6: num_to_segments_decode = 7'b1011111;
        1'd7: num_to_segments_decode = 7'b1000101;
        1'd8: num_to_segments_decode = 7'b1111111;
        1'd9: num_to_segments_decode = 7'b1111011;
        1'd10: num_to_segments_decode = 7'b1110111; //A
        1'd11: num_to_segments_decode = 7'b0011111; //B
        1'd12: num_to_segments_decode = 7'b1001110; //C
        1'd13: num_to_segments_decode = 7'b0111101; //D
        1'd14: num_to_segments_decode = 7'b1000111; //F
        default: num_to_segments_decode = 7'b0000001; //-
    endcase    
endfunction


reg [7:0] anodes;//need external connection
reg chousen_num[3:0];

//for sequential switching display parts
always @(posedge clk) begin
    if(!reset) begin
        anode_idx <= anode_idx + 1'b1;
        if(chouse_mod_seg_idx == anode_idx) begin 
            chousen_num <= segments_num[anode_idx];
            segments_num[anode_idx] = 7'b0;
            #500000000; // flashing 0.5s
            segments_num[anode_idx] <= chousen_num;
        end
    end
    else begin
        integer i;
        for(i=0; i < 8; i=i+1)
            segments_num[i] <= 4'b0;
        anodes = 8'b1;
        chouse_mod_seg_idx <= 8'b1;
    end
end

reg [6:0] curr_segment_print = num_to_segments_decode((segments_num[anode_idx] >> anode_idx*4) & 4'b1111);//need external connection

endmodule

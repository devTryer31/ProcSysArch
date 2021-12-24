`timescale 1ns / 1ps


module segment_display(
    input clk, we,
    input [31:0] addr, wdata
    );

reg reset; //0x8000100A
reg [7:0] segments_num[3:0]; //0x80001000 - 0x80001007
reg [7:0] chouse_mod_seg_idx; //FF if mode not using (0x80001009)
reg [3:0] anode_idx; //active display idx (0x80001008)  

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

reg [6:0] curr_segment_print = num_to_segments_decode((segments_num[anode_idx] >> anode_idx*4) & 4'b1111);//need external connection
reg [7:0] anodes;//need external connection
reg chousen_num[3:0];

//for sequential switching display parts
always @(negedge clk) begin
    if(!reset) begin
        anode_idx <= anode_idx + 1'b1; //для последовательного переключения активных дисплеев
        if(chouse_mod_seg_idx == anode_idx) begin // система мерциний
            chousen_num <= segments_num[anode_idx];
            segments_num[anode_idx] = 7'b0;
            #500000000; // flashing 0.5s
            segments_num[anode_idx] <= chousen_num;
        end
    end
    else begin //сброс значений
        integer i;
        for(i=0; i < 8; i=i+1)
            segments_num[i] <= 4'b0;
        anodes = 8'b1;
        chouse_mod_seg_idx <= 8'b1;
    end
end

wire[3:0] local_addr  = addr[3:0]; //На вход подается целый адрес, а здесь разбирается

//работа с данными перед проприсовкой: верно ли на нисходящем сигнале? 
always @(posedge clk) begin
    if(we) begin
        case(local_addr)
            1'hA: reset <= wdata[0];
            1'h9: chouse_mod_seg_idx = wdata[7:0];
            1'h8: anode_idx = wdata[3:0];
            default: begin // запись в регистры значений дисплеев
                if(local_addr <= 7 && local_addr >= 0)
                    segments_num[local_addr] = wdata[3:0];
            end
        endcase 
    
    end

end



endmodule

module miriscv_top
#(
  parameter RAM_SIZE      = 256, // bytes
  parameter RAM_INIT_FILE = ""
)
(
  // clock, reset
  input clk_i,
  input rst_n_i
);

wire addr_decoder_to_ram_req,
 addr_decoder_to_ram_we,
 addr_decoder_we_d0,
 addr_decoder_we_d1;

wire[1:0] RDsel_fro_decoder;
wire[31:0] data_from_keys;

  logic  [31:0]  instr_rdata_core;
  logic  [31:0]  instr_addr_core;
  
  logic          data_rvalid_core;
  logic  [31:0]  data_rdata_core;
  logic          data_req_core;
  logic          data_we_core;
  logic  [3:0]   data_be_core;
  logic  [31:0]  data_addr_core;
  logic  [31:0]  data_wdata_core;


  logic          data_rvalid_ram;
  logic  [31:0]  data_rdata_ram;
  logic          data_req_ram;
  logic          data_we_ram;
  logic  [3:0]   data_be_ram;
  logic  [31:0]  data_addr_ram;
  logic  [31:0]  data_wdata_ram;

  logic  data_mem_valid;
  //now it always valid cause displays and keyboard.
  assign data_mem_valid = 1'b1;//(data_addr_core >= RAM_SIZE) ?  1'b0 : 1'b1;//addr validation

  //assign data_rvalid_core = (data_mem_valid) ? (data_rvalid_ram) : 1'b0;//reading opportunity signal
  //assign data_rdata_core  = (data_mem_valid) ? data_rdata_ram : 1'b0;//data from mem
  assign data_req_ram     = (data_mem_valid) ? data_req_core : 1'b0;//data prom proc
  assign data_we_ram      =  data_we_core;
  assign data_be_ram      =  data_be_core;//byte to write
  assign data_addr_ram    =  data_addr_core;
  assign data_wdata_ram   =  data_wdata_core;

  programmable_device core (
    .clk   ( clk_i   ),
    .reset ( rst_n_i ),

    
    .instr_rdata_i ( instr_rdata_core ),//isnt to proc
    .instr_addr_o  ( instr_addr_core  ),//addr from proc

    .data_rdata_i (data_rdata_core),
    .data_received_i (data_rvalid_core),
    .data_req_o    ( data_req_core    ),
    .data_we_o     ( data_we_core     ),
    .data_be_o     ( data_be_core     ),
    .data_addr_o   ( data_addr_core   ),
    .data_wdata_o  ( data_wdata_core  )
  );

  miriscv_ram
  #(
    .RAM_SIZE      (RAM_SIZE),
    .RAM_INIT_FILE (RAM_INIT_FILE)
  ) ram (
    .clk_i   ( clk_i   ),
    .rst_n_i ( rst_n_i ),

    .instr_rdata_o ( instr_rdata_core ),
    .instr_addr_i  ( instr_addr_core  ),

    .data_received_o(data_rvalid_ram),
    .data_rdata_o  ( data_rdata_ram  ),
    .data_req_i    ( addr_decoder_to_ram_req    ),
    .data_we_i     ( addr_decoder_to_ram_we     ),
    .data_be_i     ( data_be_ram     ),
    .data_addr_i   ( data_addr_ram   ),
    .data_wdata_i  ( data_wdata_ram  )
  );

io_decoder addr_decoder(
    .req(data_req_ram),
    .we(data_we_ram),
    .addr(data_addr_ram),
    
    .req_m(addr_decoder_to_ram_req),
    .we_m(addr_decoder_to_ram_we),
    
    .we_d0(addr_decoder_we_d0),
    .we_d1(addr_decoder_we_d1),
    
    .RDsel(RDsel_fro_decoder)
);



always @(*) begin //?????? ???????? ?????? ?? ??????? ?????? - ???????????? ??????????
    case(RDsel_fro_decoder)
        //2'b00 //default reading from ram
        //2'b01: data_rvalid_core = 1'b1;//data_rdata_core = nothing received from displays 
        2'b10: // if from keys
            begin
                data_rdata_core = data_from_keys;
                #1;
                data_rvalid_core = 1'b1;
            end
        default: //if from ram
            begin
                data_rvalid_core = (data_mem_valid) ? (data_rvalid_ram) : 1'b0;
                data_rdata_core  = (data_mem_valid) ? data_rdata_ram : 1'b0;
            end
    endcase
end

//assign data_rvalid_core = data_rvalid_ram ? 1'b1 : (RDsel_fro_decoder == 2'b10);

segment_display displays(
    .we(addr_decoder_we_d0),
    .wdata(data_wdata_ram),
    .addr(data_addr_ram),
    .clk(clk_i)    
);

reg sig_to_sp2_dat;
ps2_keyboard keys_controller(
    .we(addr_decoder_we_d1),
    .wdata(data_wdata_ram[0]),
    .addr(data_addr_ram),
    .out(data_from_keys),
    .clk_50(clk_i),
    .ps2_clk(clk_i),
    .ps2_dat(sig_to_sp2_dat)
);

//emulation key typing
reg[3:0] i = 3'b0;
reg[7:0] num_from_key = 8'b10001101;
always @(negedge  clk_i) begin
    if(data_wdata_ram[0] == 0 && !addr_decoder_we_d1) begin//if not reset
        if(i == 4'b1011)
            i <= 3'b0;
            
        if(i == 0)
            sig_to_sp2_dat = 0;
        if(i == 9)
            sig_to_sp2_dat = 0;//paritet
        if(i == 10)
            sig_to_sp2_dat = 1;
            
        else begin
            sig_to_sp2_dat <= num_from_key[i];
        end
        i = i + 1'b1;
    end
end

endmodule

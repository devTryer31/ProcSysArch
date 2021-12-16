module miriscv_ram
#(
  parameter RAM_SIZE      = 256,
  parameter RAM_INIT_FILE = ""
)
(
  // clock, reset
  input clk_i,
  input rst_n_i,

  // instruction memory interface
  output logic  [31:0]  instr_rdata_o,
  input         [31:0]  instr_addr_i,

  // data memory interface
  output logic data_received_o, //new data on data_rdata_o got
  output logic  [31:0]  data_rdata_o,
  input                 data_req_i,//request to mem
  input                 data_we_i,
  input         [3:0]   data_be_i,
  input         [31:0]  data_addr_i,//read addr
  input         [31:0]  data_wdata_i
);

  reg [31:0]    mem [0:RAM_SIZE/4-1];
  reg [31:0]    data_int;

  //Init RAM
  integer ram_index;

  initial begin
    if(RAM_INIT_FILE != "")
      $readmemh(RAM_INIT_FILE, mem);
    else
      for (ram_index = 0; ram_index < RAM_SIZE/4-1; ram_index = ram_index + 1)
        mem[ram_index] = {32{1'b0}};
  end


  //Instruction port
  assign instr_rdata_o = mem[(instr_addr_i / 4) % RAM_SIZE];

  logic is_writed;

  always@(posedge clk_i) begin
    if(rst_n_i) begin //reset
      data_received_o <= 1'b0;
      data_rdata_o  <= 32'b0;
    end
    else if(data_req_i) begin //memory request
      //$display($time, "!my logs: \tmem[%d]=%d", data_addr_i/4, mem[(data_addr_i / 4) % RAM_SIZE]);
      data_rdata_o <= mem[(data_addr_i / 4) % RAM_SIZE];
      //$display($time, "!my logs: \t%d = data_rdata_o <= mem[%d]", data_rdata_o, data_addr_i/4);
      data_received_o <= 1'b1;//data received  signal on data_rdata_o
          
          if(data_we_i && data_be_i[0])//if need write 0th byte
            mem [data_addr_i[31:2]] [7:0]  <= data_wdata_i[7:0];
    
          if(data_we_i && data_be_i[1])
            mem [data_addr_i[31:2]] [15:8] <= data_wdata_i[15:8];
    
          if(data_we_i && data_be_i[2])
            mem [data_addr_i[31:2]] [23:16] <= data_wdata_i[23:16];
    
          if(data_we_i && data_be_i[3])
            mem [data_addr_i[31:2]] [31:24] <= data_wdata_i[31:24];

      //$stop();
    end 
        else data_received_o <= 1'b0;//if data_req_i = 0
  end


endmodule

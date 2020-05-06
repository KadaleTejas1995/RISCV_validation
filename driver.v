`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.02.2020 21:15:59
// Design Name: 
// Module Name: driver
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


module driver( 

input clk,
input [31:0] instruction, // from Program counter module
input [1:0]core_sel ,   // user input from the USER
input reset, // user input from the program counter module
input [31:0] input_output_write_data, // From Program counter module,  write data to be verified witht the chip's output
input [31:0] output_addr_data ,// from Program counter module  , write address data to be verified with the chip's output
input pc_ready , // Program counter ready 

output reg  output_write_data_pass, // to Program counter module , after verifying the data output
output reg  output_addr_data_pass, // to Program counter module  , after verifying address output
output reg [15:0] output_mem_addr,// to program counter module
output reg [31:0] output_mem_wdata ,// to program counter module
output reg [3:0] output_wstrb,  
output reg pc_valid,
output reg pc_instr,
//##########################################################################################################

input [15:0] mem_addr, //output data address from the chip 
input [31:0] mem_wdata ,//output write data  from the chip
input [3:0] wstrb , // output bit write value from the chip
input mem_instr ,  // instruction execution signal from the chip
input mem_valid , // processor ready for next instruction signal from the chip


output reg [31:0] mem_rdata , // input to chip , new instruction 
output reg mem_ready , // input to chip , ready for next instruction 
output reg chip_reset, // input to chip , reset
output  [1:0]chip_core // input to chip , core select



    );
    
    //######### Inputs from program counter
   reg [31:0] opcode_pc2driver; // regs for internal storage
   reg [31:0] i_o_wdata_pc2driver; // regs for internal storage
   reg [31:0] i_o_addr_pc2driver; // regs for internal storage
  // reg  core_select_pc2driver;// regs for internal storage 
    
    
    //########### inputs from Riscv 
    
    reg [15:0] mem_addr_risc2driver;
    reg [31:0] mem_wdata_risc2driver;
    reg [3:0] wstrb_risc2driver; 
    reg mem_instr_risc2driver;
    //################################################
    
    
    reg [3:0] state; 
    reg [3:0] next_state; 
    
    parameter idle = 0000; 
    parameter write = 0001;
    parameter busy1 = 0010;
    parameter busy2= 0100; 
    parameter idle2 = 0011;
    
    
    
    assign chip_core = core_sel; 
    
    always@(posedge clk) begin 
    if(reset) begin 
    state <= idle;
    end
    
    else 
    begin 
    state <= next_state;
    end
    end
    
    always@(posedge clk) begin 
    case(state)
    
    idle : begin 
           next_state <= idle2;
          end
          
    idle2 : begin 
            if(mem_valid) begin
            next_state <= write; 
            end
            else begin 
            next_state <= idle2;
            end
            end
    write :begin 
           if(!mem_valid) begin 
           next_state <= busy1;
           end
           else begin 
           next_state <= write;
           end 
           end
    busy1 : begin
           if(!mem_valid) begin // read next values from the Program counter
           next_state <= busy2;
           end
           else begin 
           next_state <= write; 
           end
    
           end
    busy2: begin
           if(!mem_valid) begin // dont ready any new values from the Program counter
           next_state <= busy2;
           end
            else begin 
            next_state <= write;
            end
           end
    
    
    default : begin 
            next_state <= idle;
    end
    endcase
    end
    
    
    always@(posedge clk) begin // outputs and other values transfer
    case(state) 
    idle : begin 
    
    chip_reset <= 1;
    mem_rdata <=0;
    mem_ready <=0 ;
    mem_addr_risc2driver <= 0;
    mem_wdata_risc2driver <=0;
    wstrb_risc2driver<=0; 
    mem_instr_risc2driver <=0; 
    pc_valid <= 0 ; 
    opcode_pc2driver <= 0 ;
    i_o_wdata_pc2driver <= 0 ;
    i_o_addr_pc2driver <= 0 ;
    output_mem_addr <= 0 ; 
    output_mem_wdata <= 0 ;
    output_addr_data_pass <= 0; 
    output_write_data_pass <=0;
    pc_instr <=0;
    output_wstrb <= 0;


           
           end
           
    idle2 :begin 
    chip_reset <= 0;
    pc_valid <= 1;
    end
    
    write : begin 
         
           mem_rdata <= opcode_pc2driver;// to chip
           mem_ready <=1 ;// to chip
           
           mem_addr_risc2driver <=mem_addr;// read value from prev instruction
           mem_wdata_risc2driver <=mem_wdata;// read value from prev instruction
           wstrb_risc2driver <= wstrb;// read value from prev instruction
           mem_instr_risc2driver <= mem_instr; // read value from prev instrution
           
          
          // chip_core <= core_select_pc2driver;// to chip 
           pc_valid <=1 ; // ready to read next values
           end
           
    busy1: begin 
        
           opcode_pc2driver <= instruction;// update instruction from PC
           mem_ready <= 0; //
           
           i_o_wdata_pc2driver<=input_output_write_data;
           i_o_addr_pc2driver <=output_addr_data;
          // core_select_pc2driver <= core_sel;
           
           
           
           
           output_mem_addr <=mem_addr_risc2driver;
           output_mem_wdata <= mem_wdata_risc2driver;
            output_wstrb <= wstrb_risc2driver ;
           
           
   // Check instructions data   /////////////////////////////////////////      
           if(mem_addr_risc2driver ==i_o_addr_pc2driver) begin 
           output_addr_data_pass <=1;
           end
           else begin 
            output_addr_data_pass <=0;
           end
           
           if(mem_wdata_risc2driver==i_o_wdata_pc2driver) begin
           output_write_data_pass <=1 ;
           end
           else begin 
           output_write_data_pass <=0 ;
           end 
    ////////////////////////////// /////////////////      ////////////////////
           pc_instr <= mem_instr_risc2driver; 
           pc_valid <= 0 ; 
           end
           
           
    busy2: begin 

    
    opcode_pc2driver <= opcode_pc2driver;// update instruction from PC
           mem_ready <= mem_ready ; //
           
           i_o_wdata_pc2driver<=i_o_wdata_pc2driver;
           i_o_addr_pc2driver <=i_o_addr_pc2driver;
           //core_select_pc2driver <= core_select_pc2driver ;
           
           
           
           
           output_mem_addr <= output_mem_addr;
           output_mem_wdata <=  output_mem_wdata;
           
              // Check instructions data   /////////////////////////////////////////      
           if(mem_addr_risc2driver ==i_o_addr_pc2driver) begin 
           output_addr_data_pass <=1;
           end
           else begin 
            output_addr_data_pass <=0;
           end
           
           if(mem_wdata_risc2driver==i_o_wdata_pc2driver) begin
           output_write_data_pass <=1 ;
           end
           else begin 
           output_write_data_pass <=0 ;
           end 
    ////////////////////////////// /////////////////      ////////////////////
           pc_instr <= pc_instr; 
           pc_valid <= pc_valid ; 
           
           
    
           end
    default: begin 
    
    chip_reset <= 0;
    mem_rdata <=0;
    mem_ready <=0 ;
    mem_addr_risc2driver <= 0;
    mem_wdata_risc2driver <=0;
    wstrb_risc2driver<=0; 
    mem_instr_risc2driver <=0; 
    pc_valid <= 1 ; 
    opcode_pc2driver <= 0 ;
    i_o_wdata_pc2driver <= 0 ;
    i_o_addr_pc2driver <= 0 ;
    output_mem_addr <= 0 ; 
    output_mem_wdata <= 0 ;
    output_addr_data_pass <= 0; 
    output_write_data_pass <=0;
    pc_instr <=0;
     output_wstrb <= 0;

    
    
            end
    endcase
    end
    
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Driver to PC logic 
  
    
    
    
    
    
    
    
endmodule




 

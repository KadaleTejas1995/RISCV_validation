`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2020 02:34:08
// Design Name: 
// Module Name: program_counter
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


module program_counter( 
input clk , 
input reset ,
input [15:0] output_mem_addr ,
input [31:0] output_mem_wdata,
input [3:0] output_wstrb,
input pc_valid, 
input pc_instr,

output reg [31:0] instruction ,
output reg [31:0] expected_output_write_data, 
output reg [31:0] expected_output_addr_data,
output reg pc_ready

    );
    
 wire ena ;
wire [31:0] dout ; 
wire rsta_busy; 

Program_Memory PM ();
Data_Memory DM();
    
endmodule

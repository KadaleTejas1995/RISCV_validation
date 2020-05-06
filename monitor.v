`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.02.2020 11:23:17
// Design Name: 
// Module Name: monitor
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


module monitor( input write_address_pass , input write_data_pass,
output reg [31:0] instruction_count , input clk, input reset

    );
    
    always@(posedge clk) begin 
    if(reset) begin 
    instruction_count <= 0 ;
    end
    
    else if(write_address_pass && write_data_pass) begin 
    instruction_count <= instruction_count +1 ; 
    end
    
    end
    
    
endmodule

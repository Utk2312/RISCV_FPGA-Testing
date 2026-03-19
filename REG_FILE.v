`timescale 1ns / 1ps
module REG_FILE(
    input [4:0] read_reg_num1, read_reg_num2, write_reg,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2,
    input regwrite, clock, reset,
    output [31:0] a0_out // <-- NEW PORT
);
    reg [31:0] register_file [31:0];
    integer i;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                register_file[i] <= 32'b0;
        end else if (regwrite && write_reg != 5'b00000) begin
            register_file[write_reg] <= write_data;
        end
    end

    assign read_data1 = register_file[read_reg_num1];
    assign read_data2 = register_file[read_reg_num2];
    
    // Continuously expose register x10
    assign a0_out = register_file[10]; 
endmodule
`timescale 1ns / 1ps
module PROCESSOR( 
    input clock, reset,
    input [31:0] instruction_code,
    output [31:0] pc,
    output [31:0] result_out,
    output halt,
    output [31:0] a0_out // <-- NEW PORT
);
    wire [3:0] alu_control;
    wire regwrite, alusrc, mem_to_reg, mem_read, mem_write;

    IFU IFU_module(.clock(clock), .reset(reset), .PC(pc));

    CONTROL control_module(
        .funct7(instruction_code[31:25]), 
        .funct3(instruction_code[14:12]), 
        .instr(instruction_code), 
        .alu_control(alu_control), 
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .mem_to_reg(mem_to_reg), 
        .mem_read(mem_read), 
        .mem_write(mem_write), 
        .halt(halt)
    );

    DATAPATH datapath_module(
        .instr(instruction_code), 
        .alu_ctrl(alu_control), 
        .regwrite(regwrite), 
        .alusrc(alusrc), 
        .mem_read(mem_read), 
        .mem_write(mem_write), 
        .mem_to_reg(mem_to_reg), 
        .clk(clock), 
        .rst(reset), 
        .result_out(result_out),
        .a0_out(a0_out) // Wire it here
    );
endmodule
`timescale 1ns / 1ps
module DATAPATH(
    input [31:0] instr,
    input [3:0] alu_ctrl,
    input regwrite, alusrc, mem_read, mem_write, mem_to_reg,
    input clk, rst,
    output [31:0] result_out,
    output [31:0] a0_out // <-- NEW PORT
);
    wire [31:0] rd1, rd2, alu_in2, alu_res, mem_data;
    reg [31:0] imm;
    wire zero;

    wire [4:0] rs1_addr = (instr[6:0] == 7'b0110111 || instr[6:0] == 7'b0010111) ? 5'b00000 : instr[19:15];

    always @(*) begin
        case (instr[6:0])
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            7'b0110111, 7'b0010111: imm = {instr[31:12], 12'b0};
            7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = {{20{instr[31]}}, instr[31:20]};
        endcase
    end

    REG_FILE reg_file (.read_reg_num1(rs1_addr), .read_reg_num2(instr[24:20]), .write_reg(instr[11:7]), .write_data(result_out), .read_data1(rd1), .read_data2(rd2), .regwrite(regwrite), .clock(clk), .reset(rst), .a0_out(a0_out)); // Wire it here
    
    assign alu_in2 = (alusrc) ? imm : rd2;
    ALU alu (.in1(rd1), .in2(alu_in2), .alu_control(alu_ctrl), .alu_result(alu_res), .zero(zero));
    DATA_MEM data_mem (.clk(clk), .mem_read(mem_read), .mem_write(mem_write), .addr(alu_res), .write_data(rd2), .read_data(mem_data));
    assign result_out = (mem_to_reg) ? mem_data : alu_res;
endmodule
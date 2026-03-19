module INST_MEM(input clk, write_en, input [31:0] write_addr, write_data, read_addr, output [31:0] read_data);
    reg [31:0] memory [0:1023]; // 4KB Depth
    assign read_data = memory[read_addr >> 2];
    always @(posedge clk) if (write_en) memory[write_addr >> 2] <= write_data;
endmodule
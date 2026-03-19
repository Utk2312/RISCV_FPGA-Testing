module DATA_MEM (input clk, mem_read, mem_write, input [31:0] addr, write_data, output [31:0] read_data);
    reg [31:0] memory [0:1023]; // 4KB Depth
    assign read_data = (mem_read) ? memory[addr[11:2]] : 32'h0;
    always @(posedge clk) if (mem_write) memory[addr[11:2]] <= write_data;
    integer i; initial for(i=0; i<1024; i=i+1) memory[i] = 32'h0;
endmodule
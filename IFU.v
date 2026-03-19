module IFU(
    input clock, reset,
    output reg [31:0] PC
);
    always @(posedge clock or posedge reset) begin
        if (reset) 
            PC <= 32'b0;
        else 
            PC <= PC + 4;
    end
endmodule
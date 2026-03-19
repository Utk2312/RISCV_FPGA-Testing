module ALU(input [31:0] in1, in2, input [3:0] alu_control, output reg [31:0] alu_result, output zero);
    always @(*) begin
        case(alu_control)
            4'b0000: alu_result = in1 & in2;
            4'b0001: alu_result = in1 | in2;
            4'b0010: alu_result = in1 + in2;
            4'b0011: alu_result = in1 ^ in2;
            4'b0110: alu_result = in1 - in2;
            4'b0100: alu_result = in1 - in2;
            4'b1011: alu_result = in2;
            4'b1100: alu_result = in1 * in2;
            4'b1101: alu_result = (in1 * in2) >> 32;
            4'b1110: alu_result = (in2 == 0) ? 32'h11223344 : (in1 / in2);
            4'b1111: alu_result = (in2 == 0) ? 32'h11223344 : (in1 % in2);
            default: alu_result = 32'b0;
        endcase
    end
    assign zero = (alu_result == 0);
endmodule
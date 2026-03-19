module CONTROL(input [6:0] funct7, input [2:0] funct3, input [31:0] instr, output reg [3:0] alu_control, output reg regwrite, alusrc, mem_to_reg, mem_read, mem_write, output halt);
    wire [6:0] opcode = instr[6:0];
    assign halt = (instr == 32'h00100073); // EBREAK
    always @(*) begin
        regwrite = 0; alusrc = 0; alu_control = 4'b0010;
        mem_to_reg = 0; mem_read = 0; mem_write = 0;
        case(opcode)
            7'b0110011: begin regwrite = 1; alusrc = 0;
                if (funct7 == 7'b0000001) case(funct3) 3'b000: alu_control = 4'b1100; 3'b100: alu_control = 4'b1110; 3'b110: alu_control = 4'b1111; default: alu_control = 4'b1100; endcase
                else case(funct3) 3'b000: alu_control = (funct7 == 7'b0100000) ? 4'b0110 : 4'b0010; 3'b111: alu_control = 4'b0000; 3'b110: alu_control = 4'b0001; 3'b100: alu_control = 4'b0011; default: alu_control = 4'b0010; endcase
            end
            7'b0010011: begin regwrite = 1; alusrc = 1; alu_control = 4'b0010; end
            7'b0000011: begin regwrite = 1; alusrc = 1; mem_read = 1; mem_to_reg = 1; end
            7'b0100011: begin alusrc = 1; mem_write = 1; end
            7'b0110111, 7'b0010111, 7'b1101111: begin regwrite = 1; alusrc = 1; end
            7'b1100011: begin alusrc = 0; alu_control = 4'b0100; end 
            7'b0101111, 7'b1010111, 7'b0001111: begin regwrite = 1; alu_control = 4'b1011; end
        endcase
    end
endmodule
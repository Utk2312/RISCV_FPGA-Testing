// UART RX
module uart_rx #(parameter CLKS_PER_BIT = 868) (input clk, reset, rx, output reg [7:0] rx_data, output reg rx_valid);
    reg [2:0] state, bit_index; reg [9:0] clk_count;
    always @(posedge clk or posedge reset) begin
        if (reset) begin state <= 0; clk_count <= 0; bit_index <= 0; rx_valid <= 0; rx_data <= 0; end
        else case (state)
            0: begin rx_valid <= 0; clk_count <= 0; bit_index <= 0; if (rx == 0) state <= 1; end
            1: if (clk_count == CLKS_PER_BIT/2) begin if (rx == 0) begin clk_count <= 0; state <= 2; end else state <= 0; end else clk_count <= clk_count + 1;
            2: if (clk_count == CLKS_PER_BIT-1) begin clk_count <= 0; rx_data[bit_index] <= rx; if (bit_index < 7) bit_index <= bit_index + 1; else begin bit_index <= 0; state <= 3; end end else clk_count <= clk_count + 1;
            3: if (clk_count == CLKS_PER_BIT-1) begin rx_valid <= 1; state <= 0; end else clk_count <= clk_count + 1;
        endcase
    end
endmodule
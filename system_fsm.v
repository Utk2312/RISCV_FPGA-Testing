`timescale 1ns / 1ps
module system_fsm (
    input clk, rst_n, dma_done, end_marker_seen, tx_done, cpu_halt,
    input [31:0] proc_result,
    output reg cpu_reset, start_tx,
    output reg [7:0] raw_tx_data
);
    localparam HALT = 3'd0, WAIT_DMA = 3'd1, RUN = 3'd2, REPORT = 3'd4, DONE = 3'd5;
    reg [2:0] state, next_state; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= HALT;
            raw_tx_data <= 8'h00;
        end else begin
            state <= next_state;
            if (state == RUN && cpu_halt) raw_tx_data <= proc_result[7:0]; 
        end
    end

    always @(*) begin
        next_state = state; cpu_reset = 0; start_tx = 0;
        case (state)
            HALT: next_state = WAIT_DMA;
            WAIT_DMA: begin cpu_reset = 1; if (end_marker_seen) next_state = RUN; end
            RUN: begin cpu_reset = 0; if (cpu_halt) next_state = REPORT; end
            REPORT: begin cpu_reset = 1; start_tx = 1; if (tx_done) next_state = DONE; end
            DONE: next_state = DONE;
            default: next_state = HALT;
        endcase
    end
endmodule
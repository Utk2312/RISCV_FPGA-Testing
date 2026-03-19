`timescale 1ns / 1ps
module top(input clk, reset_btn, uart_rx_pin, output uart_tx_pin, output error_led);
    wire [31:0] proc_result, pc, instruction_code; 
    wire [31:0] final_answer; // New wire for x10
    wire [7:0] rx_byte, tx_byte; 
    wire rx_valid, proc_reset, start_tx, tx_busy, proc_halt;
    
    reg [31:0] mem_write_data, mem_write_addr; reg [1:0] byte_idx; reg mem_we, rx_end_marker;

    assign error_led = 0;

    always @(posedge clk or posedge reset_btn) begin
        if (reset_btn) begin 
            mem_write_addr <= 0; byte_idx <= 0; mem_we <= 0; rx_end_marker <= 0; 
        end else begin
            mem_we <= 0;
            if (rx_valid) begin 
                if ({rx_byte, mem_write_data[23:0]} == 32'hFFFFFFFF) rx_end_marker <= 1;
                else begin
                    case (byte_idx) 
                        2'd0: mem_write_data[7:0] <= rx_byte; 
                        2'd1: mem_write_data[15:8] <= rx_byte; 
                        2'd2: mem_write_data[23:16] <= rx_byte; 
                        2'd3: mem_write_data[31:24] <= rx_byte; 
                    endcase
                    if (byte_idx == 2'd3) begin byte_idx <= 0; mem_we <= 1; end else byte_idx <= byte_idx + 1;
                end
            end
            if (mem_we) mem_write_addr <= mem_write_addr + 4;
        end
    end

    uart_rx receiver(.clk(clk), .reset(reset_btn), .rx(uart_rx_pin), .rx_data(rx_byte), .rx_valid(rx_valid));

    // FEED THE REGISTER (final_answer) INSTEAD OF ALU (proc_result)
    system_fsm controller(
        .clk(clk), .rst_n(~reset_btn), .dma_done(rx_end_marker), .end_marker_seen(rx_end_marker), 
        .tx_done(~tx_busy), .cpu_reset(proc_reset), .start_tx(start_tx), 
        .raw_tx_data(tx_byte), .cpu_halt(proc_halt), 
        .proc_result(final_answer) 
    );

    INST_MEM memory_unit(.clk(clk), .write_en(mem_we), .write_addr(mem_write_addr), .write_data(mem_write_data), .read_addr(pc), .read_data(instruction_code));
    
    // Wire up the new a0_out port
    PROCESSOR core(
        .clock(clk), .reset(proc_reset), .instruction_code(instruction_code), 
        .pc(pc), .result_out(proc_result), .halt(proc_halt), 
        .a0_out(final_answer)
    );

    uart_tx transmitter(.clk(clk), .reset(reset_btn), .tx_start(start_tx), .tx_data(tx_byte), .tx(uart_tx_pin), .tx_busy(tx_busy));
endmodule
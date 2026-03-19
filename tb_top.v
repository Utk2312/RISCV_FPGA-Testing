`timescale 1ns / 1ps
module tb_top();
    reg clk = 0, reset_btn = 0, uart_rx_pin = 1; 
    wire uart_tx_pin, error_led;

    top uut (.clk(clk), .reset_btn(reset_btn), .uart_rx_pin(uart_rx_pin), .uart_tx_pin(uart_tx_pin), .error_led(error_led));
    always #5 clk = ~clk;

    integer file_id, scan_file; 
    reg [31:0] current_word;

    task send_uart_byte(input [7:0] data);
        integer i;
        begin
            uart_rx_pin = 0; #(868 * 10);
            for (i = 0; i < 8; i = i + 1) begin uart_rx_pin = data[i]; #(868 * 10); end
            uart_rx_pin = 1; #(868 * 100); 
        end
    endtask

    initial begin
        reset_btn = 1; #1000; reset_btn = 0;
        file_id = $fopen("C:/project files for PINE/FPGA_TEST_17_03/FPGA_TEST_17_03.srcs/sim_1/new/program.hex", "r");
        
        while (!$feof(file_id)) begin
            scan_file = $fscanf(file_id, "%h\n", current_word);
            if (scan_file == 1) begin
                if (current_word == 32'hFFFFFFFF) begin
                                send_uart_byte(8'hFF); send_uart_byte(8'hFF);
                                send_uart_byte(8'hFF); send_uart_byte(8'hFF);
                                end
                else begin
                    send_uart_byte(current_word[7:0]); send_uart_byte(current_word[15:8]);
                    send_uart_byte(current_word[23:16]); send_uart_byte(current_word[31:24]);
                end
            end
        end
        $fclose(file_id);
        #10_000_000; $finish;
    end

    always @(posedge clk) begin
        if (uut.controller.state == 3'd2) begin
            $display("[CPU] PC: %h | Inst: %h | ALU: %0d", uut.core.pc, uut.core.instruction_code, $signed(uut.core.result_out));
        end
    end
endmodule
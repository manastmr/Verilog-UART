`timescale 1ns / 1ps

module uart_reciever(
    input clk,
    input rst,
    input rx,
    input rdy_clr,
    input clk_en,

    output reg rdy,
    output reg [7:0] data_out
);

    localparam START = 2'b00;
    localparam DATA  = 2'b01;
    localparam STOP  = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] bit_index;
    reg [7:0] shift_reg;

    always @(posedge clk) begin

        if (rst) begin
            state     <= START;
            sample    <= 4'd0;
            bit_index <= 3'd0;
            shift_reg <= 8'd0;
            data_out  <= 8'd0;
            rdy       <= 1'b0;
        end

        else begin

            if (rdy_clr)
                rdy <= 1'b0;

            if (clk_en) begin

                case (state)

                    START: begin
                        if (!rx) begin
                            if (sample == 4'd15) begin
                                state     <= DATA;
                                sample    <= 4'd0;
                                bit_index <= 3'd0;
                            end
                            else begin
                                sample <= sample + 1'b1;
                            end
                        end
                        else begin
                            sample <= 4'd0;
                        end
                    end

                    DATA: begin

                        if (sample == 4'd8)
                            shift_reg[bit_index] <= rx;

                        if (sample == 4'd15) begin
                            sample <= 4'd0;

                            if (bit_index == 3'd7)
                                state <= STOP;
                            else
                                bit_index <= bit_index + 1'b1;
                        end
                        else begin
                            sample <= sample + 1'b1;
                        end

                    end

                    STOP: begin

                        if (sample == 4'd15) begin
                            sample <= 4'd0;

                            if (rx) begin
                                data_out <= shift_reg;
                                rdy <= 1'b1;
                            end

                            state <= START;
                        end
                        else begin
                            sample <= sample + 1'b1;
                        end

                    end

                    default: begin
                        state     <= START;
                        sample    <= 4'd0;
                        bit_index <= 3'd0;
                    end

                endcase

            end

        end

    end

endmodule
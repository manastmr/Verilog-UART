`timescale 1ns / 1ps

module uart_top (
    input rst,
    input clk,
    input wr_en,
    input rdy_clr,
    input [7:0] data_in,

    output rdy,
    output busy,
    output [7:0] data_out
);

    // Baud rate generator outputs
    wire tx_clk_en;
    wire rx_clk_en;

    // Transmitter output connected to receiver input
    wire tx_temp;

    baud_rate_genrator bg (
        clk,
        rst,
        tx_clk_en,
        rx_clk_en
    );

    uart_sender us (
        clk,
        wr_en,
        tx_clk_en,
        rst,
        data_in,
        tx_temp,
        busy
    );

    uart_reciever ur (
        clk,
        rst,
        tx_temp,
        rdy_clr,
        rx_clk_en,
        rdy,
        data_out
    );

endmodule
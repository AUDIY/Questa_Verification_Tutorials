/******************************************************************************
* altpll_ctrl_tb.sv
* 
*   Author: AUDIY
*   Date  : 2025/08/14
*
* License under CERN-OHL-P v2
--------------------------------------------------------------------------------
| Copyright AUDIY 2025 - 2026.                                                 |
|                                                                              |
| This source describes Open Hardware and is licensed under the CERN-OHL-P v2. |
|                                                                              |
| You may redistribute and modify this source and make products using it under |
| the terms of the CERN-OHL-P v2 (https:/cern.ch/cern-ohl).                    |
|                                                                              |
| This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,          |
| INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A         |
| PARTICULAR PURPOSE. Please see the CERN-OHL-P v2 for applicable conditions.  |
--------------------------------------------------------------------------------
*
******************************************************************************/
`default_nettype none

module altpll_ctrl_tb ();

    // Timescale
    timeunit 1ns / 1ps;

    // Parameters
    localparam int clk0_cycle = 50;

    localparam int CLKSWITCH_CYCLE = 3;
    localparam int ARESET_CYCLE    = 2;
    localparam int WAIT_CYCLE      = 4;

    localparam int TOTAL_CYCLE = CLKSWITCH_CYCLE + ARESET_CYCLE + WAIT_CYCLE;

    // Input/Output
    reg  inclk0    = 1'b0;
    reg  clksel    = 1'b0;
    reg  activeclk = 1'b0;
    reg  locked    = 1'b0;
    wire clkswitch;
    wire areset   ;

    // Other variables
    int clksel_time;
    int i;
    int activeclk_time;
    int locked_time;
    string seq_now;

    // Instanciation
    altpll_ctrl #(
        .CLKSWITCH_CYCLE(CLKSWITCH_CYCLE),
        .ARESET_CYCLE   (ARESET_CYCLE   ),
        .WAIT_CYCLE     (WAIT_CYCLE     )
    ) dut (
        .clk      (inclk0   ),
        .clksel   (clksel   ),
        .activeclk(activeclk),
        .locked   (locked   ),
        .clkswitch(clkswitch),
        .areset   (areset   )
    );

    // VCD generation & finish
    initial begin
        $dumpfile("altpll_ctrl_tb.vcd");
        $dumpvars(0, altpll_ctrl_tb);

        #(clk0_cycle * 1600) $finish();
    end

    // Clock generation
    always begin
        #(clk0_cycle) inclk0 <= ~inclk0;
    end

    // Signal generation
    initial begin
        i = 0;

        forever begin
            clksel         = ~clksel;
            locked         = 1'b0;
            activeclk_time = $urandom_range(CLKSWITCH_CYCLE, CLKSWITCH_CYCLE + ARESET_CYCLE);
            locked_time    = $urandom_range(CLKSWITCH_CYCLE + ARESET_CYCLE, TOTAL_CYCLE - 1);
            case (i % 8)
                3      : begin
                    seq_now = "UNLOCK";
                    #(clk0_cycle * activeclk_time) activeclk = clksel;
                    #(clk0_cycle * locked_time) locked = 1'b0;
                end
                7      : begin
                    seq_now = "UNSWITCH";
                    #(clk0_cycle * activeclk_time);
                    #(clk0_cycle * locked_time) locked = 1'b0;
                end
                default: begin
                    seq_now = "NORMAL";
                    #(clk0_cycle * activeclk_time) activeclk = clksel;
                    #(clk0_cycle * locked_time) locked = 1'b1;
                end
            endcase
            i = i + 1;
            #(clk0_cycle * 80);
        end
    end

endmodule

`default_nettype wire


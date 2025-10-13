/******************************************************************************
* altpll_ctrl_sva_tb.sv
* 
*   Author: AUDIY
*   Date  : 2025/10/10
*
* License under CERN-OHL-P v2
--------------------------------------------------------------------------------
| Copyright AUDIY 2025.                                                        |
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

module altpll_ctrl_sva_tb ();

    // Timescale
    timeunit 1ns / 1ps;

    // Parameters
    localparam int clk0_cycle = 50; // 10MHz
    localparam int clk1_cycle = 42; // 12MHz

    localparam int CLKSWITCH_CYCLE = 3;
    localparam int ARESET_CYCLE    = 2;
    localparam int WAIT_CYCLE      = 5;

    localparam int TOTAL_CYCLE = CLKSWITCH_CYCLE + ARESET_CYCLE + WAIT_CYCLE;

    // Input/Output
    reg  inclk0    = 1'b0;
    reg  inclk1    = 1'b0;
    reg  clksel    = 1'b0;
    wire activeclk;
    wire locked   ;
    wire clkswitch;
    wire areset   ;

    // Other variables
    int clksel_time;
    int i;
    int activeclk_time;
    int locked_time;
    string seq_now;
    wire c0;
    reg init_done;

    // Instanciation
    altpll_ctrl_sva #(
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

    ALTPLL_10M50 pll_sim (
        .areset     (areset   ),
        .clkswitch  (clkswitch),
        .inclk0     (inclk0   ),
        .inclk1     (inclk1   ),
        .activeclock(activeclk),
        .c0         (c0       ),
        .locked     (locked   )
    );

    // VCD generation & finish
    initial begin
        $dumpfile("altpll_ctrl_sva_tb.vcd");
        $dumpvars(0, altpll_ctrl_sva_tb);

        #(clk0_cycle * 1600) $finish();
    end

    // Clock generation
    always begin
        #(clk0_cycle) inclk0 <= ~inclk0;
    end

    always begin
        #(clk1_cycle) inclk1 <= ~inclk1;
    end

    // Signal generation
    initial begin
        i = 0;

        forever begin
            clksel_time = $urandom_range(2000, 4000);
            #(clksel_time) clksel = ~clksel;
            i = i + 1;
        end
    end

    // Assertions
    // Assertion 1: clkswitch must 1'b1 when clksel and activeclk doesn't equal.
    assert_1: assert property (
        @(posedge inclk0) disable iff (i == 0) (clksel ^ activeclk) |=> ##[0:1] clkswitch
    );

    // Assertion 2: clkswitch must have CLKSWITCH_CYCLE pulse width.
    assert_2: assert property (
        @(posedge inclk0) disable iff (i == 0) $rose(clkswitch) |-> clkswitch [*CLKSWITCH_CYCLE]
    );

    // Assertion 3: when clkswitch is 1'b1, areset must NOT be 1'b1
    assert_3: assert property (
        @(posedge inclk0) disable iff (i == 0) clkswitch |-> !areset
    );

    // Assertion 4: when clkswitch is negated, areset must be asserted.
    assert_4: assert property (
        @(posedge inclk0) disable iff (i == 0) $fell(clkswitch) |-> $rose(areset)
    );

    // Assertion 5: areset must have ARESET_CYCLE pulse width.
    assert_5: assert property (
        @(posedge inclk0) disable iff (i == 0) $rose(areset) |-> areset [*ARESET_CYCLE]
    ); 

endmodule

`default_nettype wire

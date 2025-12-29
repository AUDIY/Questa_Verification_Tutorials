/******************************************************************************
* multadd_tb.sv
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

module multadd_tb ();

    // Timescale
    timeunit 1ns / 1ps;

    // Parameters
    localparam add_width  = 3;
    localparam mult_width = 4;

    // Input/Output
    reg                                      clk     = 1'b0;
    reg  signed [(add_width - 1):0]          add_a   = {(add_width){1'b0}};
    reg  signed [(add_width - 1):0]          add_b   = {(add_width){1'b0}};
    reg  signed [(mult_width - 1):0]         mult_c  = {(mult_width){1'b0}};
    reg                                      aresetn = 1'b0;
    wire signed [(add_width + mult_width):0] y;

    // Instantiation
    multadd #(
        .add_width (add_width ),
        .mult_width(mult_width)
    ) dut (
        .clk    (clk    ),
        .add_a  (add_a  ),
        .add_b  (add_b  ),
        .mult_c (mult_c ),
        .aresetn(aresetn),
        .y      (y      )
    );

    // VCD generation & finish
    initial begin
        $dumpfile("multadd_tb.vcd");
        $dumpvars(0, multadd_tb);

        #10000 $finish(0);
    end

    // Clock generation
    always begin
        #2 clk <= ~clk;
    end

    // Signal generation
    always @(posedge clk) begin
        //add_a
        add_a <= add_a + 1'b1;
        
        // add_b
        if (add_a == {1'b0, {(add_width-1){1'b1}}}) begin
            add_b <= add_b + 1'b1;
        end

        // add_c
        if ((add_a == {1'b0, {(add_width-1){1'b1}}}) && (add_b == {1'b0, {(add_width-1){1'b1}}})) begin
            mult_c <= mult_c + 1'b1;
        end
    end

    // Asynchronous reset
    initial begin
        #1   aresetn = 1'b1;
        #58  aresetn = 1'b0;
        #8   aresetn = 1'b1;
        #790 aresetn = 1'b0;
        #3   aresetn = 1'b1;
    end
    
endmodule

`default_nettype wire



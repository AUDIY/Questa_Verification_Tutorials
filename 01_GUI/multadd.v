/******************************************************************************
* multadd.v
* 
*   Author: AUDIY
*   Date  : 2025/08/14
*
*   Inputs
*       clk    : Clock
*       add_a  : Adder Input a
*       add_b  : Adder Input b
*       mult_c : Multiplier Input c
*       aresetn: Asynchronous Reset (Active Low)
*
*   Outputs
*       y      : Calcurated result
*
*   Parameters
*       add_width : Adder Input width
*       mult_width: Multiplier Input width
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

module multadd #(
    // Parameter Definitions
    parameter add_width  = 8,
    parameter mult_width = 8
) (
    // Port Definitions
    input  wire                                      clk,
    input  wire signed  [(add_width - 1):0]          add_a,
    input  wire signed  [(add_width - 1):0]          add_b,
    input  wire signed  [(mult_width - 1):0]         mult_c,
    input  wire                                      aresetn,
    output wire signed  [(add_width + mult_width):0] y
);

    // Internal wire/reg definitions
    wire signed [add_width:0] add;
    reg  signed [add_width:0] add_reg = {(add_width + 1){1'b0}};

    wire signed [(add_width + mult_width):0] mult;
    reg  signed [(add_width + mult_width):0] mult_reg = {(add_width + mult_width + 1){1'b0}};

    // Design
    assign add = {add_a[add_width - 1], add_a} + {add_b[add_width - 1], add_b}; // Full Adder

    always @(posedge clk or negedge aresetn) begin
        if ( !aresetn ) begin
            // Asynchronous Reset
            add_reg <= {(add_width+1){1'b0}};
        end else begin
            // Pipeline
            add_reg <= add;
        end
    end

    assign mult = {{(mult_width){add_reg[add_width]}}, add_reg} * {{(add_width + 1){mult_c[mult_width - 1]}}, mult_c}; // Multiplier

    always @(posedge clk or negedge aresetn) begin
        if ( !aresetn ) begin
            // Asynchronous Reset
            mult_reg <= {(add_width + mult_width + 1){1'b0}};
        end else begin
            // Pipeline
            mult_reg <= mult;
        end
    end

    // Output assign
    assign y = mult_reg;
    
endmodule

`default_nettype wire



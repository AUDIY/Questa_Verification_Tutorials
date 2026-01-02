/******************************************************************************
* altpll_ctrl_sva.v
*
*   Author: AUDIY
*   Date  : 2025/08/19
*
*   Inputs
*       clk      : Clock (ALTPLL slower input clock)
*       clksel   : Clock select (1'b0: inclk0, 1'b1: inclk1)
*       activeclk: Active clock (1'b0: inclk0, 1'b1: inclk1)
*       locked   : ALTPLL lock status (1'b0: unlocked, 1'b1: locked)
*
*   Outputs
*       clkswitch: ALTPLL clkswitch
*       areset   : ALTPLL asynchronous reset
*
*   Parameters
*       CLKSWICTH_CYCLE: ALTPLL clkswitch assert cycle
*       ARESET_CYCLE   : ALTPLL areset assert cycle
*       WAIT_CYCLE     : ALTPLL lock wait cycle
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

module altpll_ctrl_sva #(
    // Parameter Definitions
    parameter CLKSWITCH_CYCLE = 3,
    parameter ARESET_CYCLE    = 2,
    parameter WAIT_CYCLE      = 4
) (
    // Port Definitions
    input  wire clk      ,
    input  wire clksel   ,
    input  wire activeclk,
    input  wire locked   ,
    output wire clkswitch,
    output wire areset
);

    // State Definitions
    localparam IDLE   = 2'd0; // 2'b00
    localparam SWITCH = 2'd1; // 2'b01
    localparam ARESET = 2'd2; // 2'b10
    localparam WAIT   = 2'd3; // 2'b11

    // Local parameter Definitions
    localparam CLKSWITCH_COUNT_WIDTH = log2(CLKSWITCH_CYCLE); // $clog2(CLKSWITCH_CYCLE)
    localparam ARESET_COUNT_WIDTH    = log2(ARESET_CYCLE   ); // $clog2(ARESET_CYCLE   )
    localparam WAIT_COUNT_WIDTH      = log2(WAIT_CYCLE     ); // $clog2(WAIT_CYCLE     )

    // Internal wire/reg definitions
    reg [1:0] state = 2'd0;

    reg [(CLKSWITCH_COUNT_WIDTH - 1):0] clkswitch_count = {(CLKSWITCH_COUNT_WIDTH){1'b0}};
    reg [(ARESET_COUNT_WIDTH    - 1):0] areset_count    = {(ARESET_COUNT_WIDTH   ){1'b0}};
    reg [(WAIT_COUNT_WIDTH      - 1):0] wait_count      = {(WAIT_COUNT_WIDTH     ){1'b0}};

    reg clkswitch_reg = 1'b0;
    reg areset_reg    = 1'b0;

    // Design
    always @(posedge clk ) begin
        case (state)
            IDLE   : begin
                if (clksel != activeclk) begin
                    // IDLE -> SWITCH
                    state           <= SWITCH;
                    clkswitch_reg   <= 1'b1;
                    areset_reg      <= 1'b0;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end else if (!locked) begin
                    // IDLE -> ARESET
                    state           <= ARESET;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b1;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end else begin
                    // Keep IDLE
                    state           <= IDLE;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b0;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end
            end

            SWITCH : begin
                if (clkswitch_count == (CLKSWITCH_CYCLE - 1)) begin
                    // SWITCH -> ARESET
                    state           <= ARESET;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b1;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end else begin
                    // Keep SWITCH
                    state           <= SWITCH;
                    clkswitch_reg   <= 1'b1;
                    areset_reg      <= 1'b0;
                    clkswitch_count <= clkswitch_count + 1'b1;
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end
            end

            ARESET : begin
                if (areset_count == (ARESET_CYCLE - 1)) begin
                    // ARESET -> WAIT
                    state           <= WAIT;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b0;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end else begin
                    // Keep ARESET
                    state           <= ARESET;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b1;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= areset_count + 1'b1;
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end
            end
            
            WAIT   : begin
                if (wait_count == (WAIT_CYCLE - 1)) begin
                    // WAIT -> IDLE
                    state           <= IDLE;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b0;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= {(WAIT_COUNT_WIDTH){1'b0}};
                end else begin
                    // Keep WAIT
                    state           <= WAIT;
                    clkswitch_reg   <= 1'b0;
                    areset_reg      <= 1'b0;
                    clkswitch_count <= {(CLKSWITCH_COUNT_WIDTH){1'b0}};
                    areset_count    <= {(ARESET_COUNT_WIDTH){1'b0}};
                    wait_count      <= wait_count + 1'b1;
                end
            end
        endcase
    end

    // Output assign
    assign clkswitch = clkswitch_reg;
    assign areset    = areset_reg   ;

    /**************************************************************************
        log2 function

        Equivalent to $clog2() system task.
        Use $clog2 if you use Verilog-2005 (IEEE 1364-2005) or later.
    **************************************************************************/
    function integer log2;
        input integer addr;
        begin
            addr = addr - 1;
            for (log2=0; addr>0; log2=log2+1)
                addr = addr >> 1;
        end
    endfunction

endmodule

`default_nettype wire


/*
*  File            :   nf_ahb_pwm.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.02.08
*  Language        :   SystemVerilog
*  Description     :   This is AHB PWM module
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_settings.svh"
`include "../../inc/nf_ahb.svh"

module nf_ahb_pwm
#(
    parameter                   pwm_width = 8
)(
    // clock and reset
    input   logic   [0  : 0]    hclk,       // hclk
    input   logic   [0  : 0]    hresetn,    // hresetn
    // AHB PWM slave side
    input   logic   [31 : 0]    haddr_s,    // AHB - PWM-slave HADDR
    input   logic   [31 : 0]    hwdata_s,   // AHB - PWM-slave HWDATA
    output  logic   [31 : 0]    hrdata_s,   // AHB - PWM-slave HRDATA
    input   logic   [0  : 0]    hwrite_s,   // AHB - PWM-slave HWRITE
    input   logic   [1  : 0]    htrans_s,   // AHB - PWM-slave HTRANS
    input   logic   [2  : 0]    hsize_s,    // AHB - PWM-slave HSIZE
    input   logic   [2  : 0]    hburst_s,   // AHB - PWM-slave HBURST
    output  logic   [1  : 0]    hresp_s,    // AHB - PWM-slave HRESP
    output  logic   [0  : 0]    hready_s,   // AHB - PWM-slave HREADYOUT
    input   logic   [0  : 0]    hsel_s,     // AHB - PWM-slave HSEL
    // PWM side
    input   logic   [0  : 0]    pwm_clk,    // PWM_clk
    input   logic   [0  : 0]    pwm_resetn, // PWM_resetn
    output  logic   [0  : 0]    pwm         // PWM output signal
);

    logic               pwm_request;
    logic               pwm_wrequest;
    logic   [31 : 0]    pwm_work_addr;

    assign  pwm_request = hsel_s && ( htrans_s != `AHB_HTRANS_IDLE);

    nf_register_we #( 32 ) pwm_waddr_ff     ( hclk, hresetn, pwm_request, haddr_s, pwm_work_addr );
    nf_register    #( 1  ) pwm_wreq_ff      ( hclk, hresetn, pwm_request && hwrite_s, pwm_wrequest );
    nf_register    #( 1  ) hready_ff        ( hclk, hresetn, pwm_request, hready_s );

    logic   [31 : 0]    pwm_addr;
    logic   [31 : 0]    pwm_rd;
    logic   [31 : 0]    pwm_wd;
    logic   [0  : 0]    pwm_we;

    assign  pwm_addr  = pwm_work_addr;
    assign  pwm_we    = pwm_wrequest;
    assign  pwm_wd    = hwdata_s;
    assign  hrdata_s  = pwm_rd;

    assign  hresp_s   = `AHB_HRESP_OKAY;

    nf_pwm
    #(
        .pwm_width  ( pwm_width         )
    )
    nf_pwm_0
    (
        .clk        ( hclk              ),
        .resetn     ( hresetn           ),
        // bus side
        .addr       ( pwm_addr          ),  // address
        .we         ( pwm_we            ),  // write enable
        .wd         ( pwm_wd            ),  // write data
        .rd         ( pwm_rd            ),  // read data
        // pmw_side
        .pwm_clk    ( pwm_clk           ),  // PWM clock input
        .pwm_resetn ( pwm_resetn        ),  // PWM reset input
        .pwm        ( pwm               )   // PWM output signal
    );
    
endmodule : nf_ahb_pwm

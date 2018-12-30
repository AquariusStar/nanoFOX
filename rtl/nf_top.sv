/*
*  File            :   nf_top.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.27
*  Language        :   SystemVerilog
*  Description     :   This is top unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_top
(
    input   logic                           clk,
    input   logic                           resetn,
    input   logic   [25 : 0]                div,
    //pwm side
    output  logic                           pwm,
    //gpio side
    input   logic   [`NF_GPIO_WIDTH-1 : 0]  gpi,
    output  logic   [`NF_GPIO_WIDTH-1 : 0]  gpo,
    output  logic   [`NF_GPIO_WIDTH-1 : 0]  gpd
`ifdef debug
    ,
    input   logic   [4  : 0]                reg_addr,
    output  logic   [31 : 0]                reg_data
`endif
);
    //instruction memory
    logic   [31 : 0]    instr_addr;
    logic   [31 : 0]    instr;
    logic               cpu_en;
    //data memory and others's
    logic   [31 : 0]    addr_dm;
    logic               we_dm;
    logic   [31 : 0]    wd_dm;
    logic   [31 : 0]    rd_dm;

    nf_cpu nf_cpu_0
    (
        .clk        ( clk               ),
        .resetn     ( resetn            ),
        .instr_addr ( instr_addr        ),
        .instr      ( instr             ),
        .cpu_en     ( '1                ),
        .addr_dm    ( addr_dm           ),
        .we_dm      ( we_dm             ),
        .wd_dm      ( wd_dm             ),
        .rd_dm      ( rd_dm             )
    `ifdef debug
        ,
        .reg_addr   ( reg_addr          ),
        .reg_data   ( reg_data          )
    `endif
    );
    //creating one instruction/data memory
    nf_dp_ram
    #(
        .depth      ( 64                ) 
    )
    nf_dp_ram_0
    (
        .clk        ( clk               ),
        .addr_p1    ( instr_addr >> 2   ),
        .we_p1      ( '0                ),
        .wd_p1      ( '0                ),
        .rd_p1      ( instr             ),
        .addr_p2    ( addr_dm >> 2      ),
        .we_p2      ( we_dm             ),
        .wd_p2      ( wd_dm             ),
        .rd_p2      ( rd_dm             )
    );

endmodule : nf_top

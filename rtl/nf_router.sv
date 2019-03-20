/*
*  File            :   nf_router.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.29
*  Language        :   SystemVerilog
*  Description     :   This is unit for routing lw sw command's
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../inc/nf_settings.svh"

module nf_router
#(
    parameter                                   Slave_n = `slave_number
)(
    // clock and reset
    input   logic                               clk,        // clock
    input   logic                               resetn,     // reset
    // cpu side (master)
    input   logic   [31 : 0]                    addr_dm_m,  // master address
    input   logic   [0  : 0]                    we_dm_m,    // master write enable
    input   logic   [31 : 0]                    wd_dm_m,    // master write data
    output  logic   [31 : 0]                    rd_dm_m,    // master read data
    // devices side (slave's)
    output  logic                               clk_s,      // slave clock
    output  logic                               resetn_s,   // slave reset
    output  logic   [Slave_n-1 : 0][31 : 0]     addr_dm_s,  // slave address
    output  logic   [Slave_n-1 : 0][0  : 0]     we_dm_s,    // slave write enable
    output  logic   [Slave_n-1 : 0][31 : 0]     wd_dm_s,    // slave write data
    input   logic   [Slave_n-1 : 0][31 : 0]     rd_dm_s     // slave read data
);

    logic   [Slave_n-1 : 0]     slave_sel;

    assign clk_s     = clk;
    assign resetn_s  = resetn;
    assign wd_dm_s   = { `slave_number { wd_dm_m } };
    assign addr_dm_s = { `slave_number { addr_dm_m } };
    assign we_dm_s   = { `slave_number { we_dm_m } } & slave_sel ; // {we_dm_m && slave_sel[n-1] , we_dm_m && slave_sel[n-2] , ... , we_dm_m && slave_sel[0] };

    nf_router_dec
    #(
        .Slave_n        ( `slave_number     )
    )
    nf_router_dec_0
    (
        .addr_m         ( addr_dm_m         ),  // master address
        .slave_sel      ( slave_sel         )   // slave select
    );

    nf_router_mux
    #(
        .Slave_n        ( `slave_number     )
    )
    nf_router_mux_0
    (
        .slave_sel      ( slave_sel         ),  // slave select
        .rd_s           ( rd_dm_s           ),  // read data array slave
        .rd_m           ( rd_dm_m           )   // read data master
    );  

endmodule : nf_router

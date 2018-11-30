/*
*  File            :   nf_settings.svh
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.20
*  Language        :   SystemVerilog
*  Description     :   This is file with common settings
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`define debug 1

`define RV32I

`ifdef RV32I
`define reg_number 32
`endif

`ifdef RV32E
`define reg_number 16
`endif

`ifndef reg_number
`define reg_number 32
`endif

`define ram_depth  64

`define slave_number 4

`define NF_RAM_ADDR_MATCH   2'b00
`define NF_GPIO_ADDR_MATCH  12'h7f0
`define NF_PWM_ADDR_MATCH   12'h7f1

`define NF_GPIO_GPI         'h0
`define NF_GPIO_GPO         'h4
`define NF_GPIO_DIR         'h8
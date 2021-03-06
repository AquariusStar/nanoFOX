/*
*  File            :   nf_hz_stall_unit.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is stall and flush hazard unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "../../inc/nf_hazard_unit.svh"
`include "../../inc/nf_cpu.svh"

module nf_hz_stall_unit
(
    // scan wires
    input   logic   [0 : 0]     we_rf_imem,     // write enable register from memory stage
    input   logic   [4 : 0]     wa3_iexe,       // write address from execution stage
    input   logic   [4 : 0]     wa3_imem,       // write address from execution stage
    input   logic   [0 : 0]     we_rf_iexe,     // write enable register from memory stage
    input   logic   [0 : 0]     rf_src_iexe,    // register source from execution stage
    input   logic   [4 : 0]     ra1_id,         // read address 1 from decode stage
    input   logic   [4 : 0]     ra2_id,         // read address 2 from decode stage
    input   logic   [3 : 0]     branch_type,    // branch type
    input   logic   [0 : 0]     we_dm_imem,     // write enable data memory from memory stage
    input   logic   [0 : 0]     req_ack_dm,     // request acknowledge data memory
    input   logic   [0 : 0]     req_ack_i,      // request acknowledge instruction
    input   logic   [0 : 0]     rf_src_imem,    // register source from memory stage
    input   logic   [0 : 0]     lsu_busy,       // load store unit busy
    input   logic   [0 : 0]     lsu_err,        // load store error
    // control wires
    output  logic   [0 : 0]     stall_if,       // stall fetch stage
    output  logic   [0 : 0]     stall_id,       // stall decode stage
    output  logic   [0 : 0]     stall_iexe,     // stall execution stage
    output  logic   [0 : 0]     stall_imem,     // stall memory stage
    output  logic   [0 : 0]     stall_iwb,      // stall write back stage
    output  logic   [0 : 0]     flush_id,       // flsuh decode stage
    output  logic   [0 : 0]     flush_iexe,     // flush execution stage
    output  logic   [0 : 0]     flush_imem,     // flush memory stage
    output  logic   [0 : 0]     flush_iwb       // flush write back stage
);

    logic   lw_stall_id_iexe;       // stall pipe if load data instructions ( id and exe stages )
    logic   branch_exe_id_stall;    // stall pipe if branch operations
    logic   sw_lw_data_stall;       // stall pipe if store or load data instructions
    logic   lw_instr_stall;         // stall pipe if load instruction from memory

    assign lw_stall_id_iexe     =   ( ( ra1_id == wa3_iexe ) || ( ra2_id == wa3_iexe )  || ( ra1_id == wa3_imem ) || ( ra2_id == wa3_imem ) ) && 
                                    ( we_rf_iexe || we_rf_imem ) && 
                                    ( rf_src_iexe || rf_src_imem );


    assign branch_exe_id_stall  =   ( ! ( ( branch_type == B_NONE ) ) ) && 
                                    we_rf_iexe && 
                                    ( ( wa3_iexe == ra1_id ) || ( wa3_iexe == ra2_id ) ) && 
                                    ( ( | ra1_id ) || ( | ra2_id ) );

    assign sw_lw_data_stall     =   lsu_busy;

    assign lw_instr_stall       =   ~ req_ack_i;
    // stall wires
    assign stall_if   = lw_stall_id_iexe  || sw_lw_data_stall || branch_exe_id_stall || lw_instr_stall;
    assign stall_id   = lw_stall_id_iexe  || sw_lw_data_stall || branch_exe_id_stall || lw_instr_stall;
    assign stall_iexe =                      sw_lw_data_stall                                         ;
    assign stall_imem =                      sw_lw_data_stall                                         ;
    assign stall_iwb  =                      sw_lw_data_stall                                         ;
    // flush wires
    assign flush_iexe = lsu_err || lw_stall_id_iexe  || branch_exe_id_stall || lw_instr_stall;
    assign flush_id   = lsu_err                                                              ;
    assign flush_imem = lsu_err                                                              ;
    assign flush_iwb  = lsu_err                                                              ;
    
endmodule : nf_hz_stall_unit

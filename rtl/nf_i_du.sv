/*
*  File            :   nf_i_du.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2019.01.10
*  Language        :   SystemVerilog
*  Description     :   This is instruction decode unit
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_i_du
(
    input   logic   [31 : 0]    instr,      // Instruction input
    output  logic   [31 : 0]    ext_data,   // decoded extended data
    output  logic   [0  : 0]    srcB_sel,   // decoded source B selection for ALU
    output  logic   [31 : 0]    ALU_Code,   // decoded ALU code
    output  logic   [4  : 0]    shamt,      // decoded for shift command's
    output  logic   [4  : 0]    ra1,        // decoded read address 1 for register file
    input   logic   [31 : 0]    rd1,        // read data 1 from register file
    output  logic   [4  : 0]    ra2,        // decoded read address 2 for register file
    input   logic   [31 : 0]    rd2,        // read data 2 from register file
    output  logic   [4  : 0]    wa3,        // decoded write address 2 for register file
    output  logic   [0  : 0]    pc_src,     // decoded next program counter value enable
    output  logic   [0  : 0]    we_rf,      // decoded write register file
    output  logic   [0  : 0]    we_dm_en,   // decoded write data memory
    output  logic   [0  : 0]    rf_src      // decoded source register file signal
);

    // sign extend wires
    logic   [11 : 0]    imm_data_i; // for I-type command's
    logic   [19 : 0]    imm_data_u; // for U-type command's
    logic   [11 : 0]    imm_data_b; // for B-type command's
    logic   [11 : 0]    imm_data_s; // for S-type command's
    // control unit wires
    logic   [6  : 0]    opcode;
    logic   [2  : 0]    funct3;
    logic   [6  : 0]    funct7;
    logic   [0  : 0]    branch_type;
    logic   [0  : 0]    eq_neq;
    logic   [1  : 0]    imm_src;
    // immediate data in instruction
    assign imm_data_i = instr[20 +: 12];
    assign imm_data_u = instr[12 +: 20];
    assign imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };
    assign imm_data_s = { instr[25 +: 7] , instr[7 +: 5] };
    // shamt value in instruction
    assign shamt = instr[20  +: 5];
    // register file wires
    assign ra1 = instr[15 +: 5];
    assign ra2 = instr[20 +: 5];
    assign wa3 = instr[7  +: 5];
    // operation code, funct3 and funct7 field's in instruction
    assign opcode = instr[0   +: 7];
    assign funct3 = instr[12  +: 3];
    assign funct7 = instr[25  +: 7];
    
    // creating control unit for cpu
    nf_control_unit nf_control_unit_0
    (
        .opcode         ( opcode                ),  // operation code field in instruction code
        .funct3         ( funct3                ),  // funct 3 field in instruction code
        .funct7         ( funct7                ),  // funct 7 field in instruction code
        .srcBsel        ( srcB_sel              ),  // for enable immediate data
        .branch_type    ( branch_type           ),  // for selecting srcB ALU
        .eq_neq         ( eq_neq                ),  // for executing branch instructions
        .we_rf          ( we_rf                 ),  // equal and not equal control
        .we_dm          ( we_dm_en              ),  // write enable signal for register file
        .rf_src         ( rf_src                ),  // write enable signal for data memory and others
        .imm_src        ( imm_src               ),  // write data select for register file
        .ALU_Code       ( ALU_Code              )   // output code for ALU unit
    );

    // creating sign extending unit
    nf_sign_ex nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i            ),  // immediate data in i-type instruction
        .imm_data_u     ( imm_data_u            ),  // immediate data in u-type instruction
        .imm_data_b     ( imm_data_b            ),  // immediate data in b-type instruction
        .imm_data_s     ( imm_data_s            ),  // immediate data in s-type instruction
        .imm_src        ( imm_src               ),  // selection immediate data input
        .imm_ex         ( ext_data              )   // extended immediate data
    );

    // creating branch unit
    nf_branch_unit nf_branch_unit_0
    (
        .branch_type    ( branch_type           ),  // from control unit, '1 if branch instruction
        .d0             ( rd1                   ),  // from control unit for beq and bne commands (equal and not equal)
        .d1             ( rd2                   ),  // from register file (rd1)
        .eq_neq         ( eq_neq                ),  // from register file (rd2)
        .pc_src         ( pc_src                )   // next program counter
    );

endmodule : nf_i_du
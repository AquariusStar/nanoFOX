/*
*  File            :   nf_cpu.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is cpu unit
*  Copyright(c)    :   2018 Vlasov D.V.
*/

`include "nf_settings.svh"

module nf_cpu
(
    input   logic               clk,
    input   logic               resetn,
    output  logic   [31 : 0]    instr_addr,
    input   logic   [31 : 0]    instr,
    input   logic               cpu_en
`ifdef debug
    ,
    input   logic   [4  : 0]    reg_addr,
    output  logic   [31 : 0]    reg_data
`endif
);
    // program counter wires
    logic   [31 : 0]    pc_i;
    logic   [31 : 0]    pc_nb;
    logic   [31 : 0]    pc_b;
    logic               next_pc_sel;
    // register file wires
    logic   [4  : 0]    ra1;
    logic   [31 : 0]    rd1;
    logic   [4  : 0]    ra2;
    logic   [31 : 0]    rd2;
    logic   [4  : 0]    wa3;
    logic   [31 : 0]    wd3;
    logic               we3;
    // sign extend wires
    logic   [11 : 0]    imm_data_i;
    logic   [19 : 0]    imm_data_u;
    logic   [11 : 0]    imm_data_b;
    logic   [31 : 0]    ext_data;
    // ALU wires
    logic   [31 : 0]    srcA;
    logic   [31 : 0]    srcB;
    logic   [4  : 0]    shamt;
    logic   [31 : 0]    ALU_Code;
    logic   [31 : 0]    result;
    logic               zero;
    // control unit wires
    logic   [6  : 0]    opcode;
    logic   [2  : 0]    funct3;
    logic   [6  : 0]    funct7;
    logic               branch;
    logic               eq_neq;
    logic   [1  : 0]    imm_src;
    logic               srcBsel;
    logic               pc_b_en;

    // register's address finding from instruction
    assign ra1  = instr[15 +: 5];
    assign ra2  = instr[20 +: 5];
    assign wa3  = instr[7  +: 5];
    // shamt value in instruction
    assign shamt = instr[20  +: 5];
    // operation code, funct3 and funct7 field's in instruction
    assign opcode = instr[0   +: 7];
    assign funct3 = instr[12  +: 3];
    assign funct7 = instr[25  +: 7];
    // immediate data in instruction
    assign imm_data_i = instr[20 +: 12];
    assign imm_data_u = instr[12 +: 20];
    assign imm_data_b = { instr[31] , instr[7] , instr[25 +: 6] , instr[8 +: 4] };

    assign wd3  = result;
    assign srcA = rd1;
    assign srcB = srcBsel ? rd2 : ext_data;

    //creating sign extending unit
    nf_sign_ex nf_sign_ex_0
    (
        .imm_data_i     ( imm_data_i    ),
        .imm_data_u     ( imm_data_u    ),
        .imm_data_b     ( imm_data_b    ),
        .imm_src        ( imm_src       ),
        .imm_ex         ( ext_data      )
    );
    //next program counter value for not branch command
    assign pc_nb = instr_addr + 4;
    //next program counter value for branch command
    assign pc_b  = instr_addr + ( ext_data << 1 );
    //finding next program counter value
    assign pc_i  = pc_b_en ? pc_b : pc_nb;

    //creating program counter
    nf_register_we
    #(
        .width          ( 32            )
    )
    register_pc
    (
        .clk            ( clk           ),
        .resetn         ( resetn        ),
        .datai          ( pc_i          ),
        .datao          ( instr_addr    ),
        .we             ( cpu_en        )
    );
    //creating register file
    nf_reg_file reg_file_0
    (
        .clk            ( clk           ),
        .ra1            ( ra1           ),
        .rd1            ( rd1           ),
        .ra2            ( ra2           ),
        .rd2            ( rd2           ),
        .wa3            ( wa3           ),
        .wd3            ( wd3           ),
        .we3            ( we3 && cpu_en )
        `ifdef debug
        ,
        .ra0            ( reg_addr      ),
        .rd0            ( reg_data      )
        `endif
    );
    //creating ALU unit
    nf_alu alu_0
    (
        .srcA           ( srcA          ),
        .srcB           ( srcB          ),
        .shamt          ( shamt         ),
        .ALU_Code       ( ALU_Code      ),
        .result         ( result        ),
        .zero           ( zero          )
    );
    //creating control unit for cpu
    nf_control_unit nf_control_unit_0
    (
        .opcode         ( opcode        ),
        .funct3         ( funct3        ),
        .funct7         ( funct7        ),
        .srcBsel        ( srcBsel       ),
        .branch         ( branch        ),
        .eq_neq         ( eq_neq        ),
        .we             ( we3           ),
        .imm_src        ( imm_src       ),
        .ALU_Code       ( ALU_Code      )
    );
    //creating branch unit
    nf_branch_unit nf_branch_unit_0
    (
        .branch         ( branch        ),
        .zero           ( zero          ),
        .eq_neq         ( eq_neq        ),
        .pc_b_en        ( pc_b_en       )
    );

endmodule : nf_cpu

/*
*  File            :   nf_ram.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.28
*  Language        :   SystemVerilog
*  Description     :   This is common ram memory
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

module nf_ram
#(
    parameter                   depth = 64
)(
    input   logic               clk,
    input   logic   [31 : 0]    addr,   // address
    input   logic               we,     // write enable
    input   logic   [31 : 0]    wd,     // write data
    output  logic   [31 : 0]    rd      // read data
);

    logic [31 : 0] ram [depth-1 : 0];

    always_ff @(posedge clk)
    begin : read_from_ran
            rd <= ram[addr];  
    end

    always_ff @(posedge clk)
    begin : write_to_ram
        if( we )
            ram[addr] <= wd;  
    end

    initial
    begin
        $readmemh("../../program_file/program.hex",ram);
    end

endmodule : nf_ram

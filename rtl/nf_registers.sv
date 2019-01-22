/*
*  File            :   nf_register.sv
*  Autor           :   Vlasov D.V.
*  Data            :   2018.11.19
*  Language        :   SystemVerilog
*  Description     :   This is file with registers modules
*  Copyright(c)    :   2018 - 2019 Vlasov D.V.
*/

//simple register with reset and clock 
module nf_register
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            datao <= '0;
        else
            datao <= datai;
    end

endmodule : nf_register

//register with write enable input
module nf_register_we
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic                   we,     // write enable
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            datao <= '0;
        else if( we )
            datao <= datai;
    end

endmodule : nf_register_we

//register with write enable input and not zero reset value
module nf_register_we_r
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic                   we,     // write enable
    input   logic   [width-1 : 0]   datar,  // reset value
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            datao <= datar;
        else if( we )
            datao <= datai;
    end

endmodule : nf_register_we_r

//register with clr input
module nf_register_clr
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic                   clr,    // clear register
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            datao <= '0;
        else
            datao <= clr ? '0 : datai;
    end

endmodule : nf_register_clr

//register with clr and we input's
module nf_register_we_clr
#(
    parameter                       width = 1
)(
    input   logic                   clk,
    input   logic                   resetn,
    input   logic                   we,     // write enable
    input   logic                   clr,    // clear register
    input   logic   [width-1 : 0]   datai,  // input data
    output  logic   [width-1 : 0]   datao   // output data
);

    always_ff @(posedge clk, negedge resetn)
    begin
        if( !resetn )
            datao <= '0;
        else if( we )
            datao <= clr ? '0 : datai;
    end

endmodule : nf_register_we_clr

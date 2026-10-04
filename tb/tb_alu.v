`timescale 1ns / 1ps
module tb_alu;
    // ALU operation codes: {instr[30], funct3} 
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b1000;
    localparam ALU_SLL  = 4'b0001;
    localparam ALU_SLT  = 4'b0010;
    localparam ALU_SLTU = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SRL  = 4'b0101;
    localparam ALU_SRA  = 4'b1101;
    localparam ALU_OR   = 4'b0110;
    localparam ALU_AND  = 4'b0111;

    reg  [31:0] a, b;
    reg  [3:0]  alu_op;
    wire [31:0] result;
    wire        zero;

    alu dut (.a(a), .b(b), .alu_op(alu_op), .result(result), .zero(zero));

    initial begin
        $monitor("op=%b a=%h b=%h -> result=%h zero=%b",
                 alu_op, a, b, result, zero);

        a = 32'hFFFFFFF8;   // -8
        b = 32'd3;

        alu_op = ALU_ADD; #10;
        alu_op = ALU_SUB; #10;
        alu_op = ALU_SLL; #10;
        alu_op = ALU_SLT; #10;
        alu_op = ALU_SLTU; #10;
        alu_op = ALU_XOR; #10;
        alu_op = ALU_SRL; #10;
        alu_op = ALU_SRA; #10;
        alu_op = ALU_OR; #10;
        alu_op = ALU_AND; #10;

        a = 32'd5;
        b = 32'd5;
        alu_op = ALU_SUB; #10;

        $finish;
    end
endmodule
`timescale 1ns / 1ps
module alu 
    import alu_pkg::*; // Import ALU operation codes
(
    input logic [31:0] a,b, // ALU inputs
    input alu_op_t alu_op, // ALU operation code
    output logic zero, // ALU zero flag
    output logic [31:0] result // ALU result
);

    always_comb begin : alu_compute
        case (alu_op)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_SLL: result = a << b[4:0];
            ALU_SLT: result = {31'b0, ($signed(a) < $signed(b))};
            ALU_SLTU: result = {31'b0, (a < b)};
            ALU_XOR: result = a ^ b;
            ALU_SRL: result = a >> b[4:0];
            ALU_SRA: result = $signed(a) >>> b[4:0];
            ALU_OR:  result = a | b;
            ALU_AND: result = a & b;
            default: result = 32'b0;
        endcase
    end
    assign zero = (result == 32'b0);

endmodule
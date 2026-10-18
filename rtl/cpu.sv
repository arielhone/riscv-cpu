`timescale 1ns / 1ps

module cpu import alu_pkg::*, rv32i_pkg::*; #(
    parameter string MEM_FILE = "../programs/sum.hex"
) (
    input  logic clk,
    input  logic rst
);

    // ---------- Fetch ----------
    logic [31:0] pc_cur, pc_next, pc_plus4;
    logic [31:0] instr;

    pc u_pc (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_next),
        .pc      (pc_cur)
    );

    imem #(.MEM_FILE(MEM_FILE)) u_imem (
        .addr  (pc_cur),
        .instr (instr)
    );

    assign pc_plus4 = pc_cur + 32'd4;
    assign pc_next  = pc_plus4;   // no jumps yet (lesson 23)

    // ---------- Decode ----------
    // Instruction fields
    logic [6:0]  opcode;
    logic [2:0]  funct3;
    logic        instr30;
    logic [4:0]  rs1, rs2, rd;

    assign opcode  = instr[6:0];
    assign rd      = instr[11:7];
    assign funct3  = instr[14:12];
    assign rs1     = instr[19:15];
    assign rs2     = instr[24:20];
    assign instr30 = instr[30];

    // Register file data
    logic [31:0] rs1_data, rs2_data, rd_data;

    // Immediate
    logic [31:0] imm;

    immgen u_immgen (
        .instr (instr),
        .imm   (imm)
    );

    // Control signals
    alu_op_t     alu_op;
    logic        alu_src, reg_we, mem_we, branch, jump, jalr;
    logic [1:0]  wb_sel;

    control u_control (
        .opcode  (opcode),
        .funct3  (funct3),
        .instr30 (instr30),
        .alu_op  (alu_op),
        .alu_src (alu_src),
        .wb_sel  (wb_sel),
        .reg_we  (reg_we),
        .mem_we  (mem_we),
        .branch  (branch),
        .jump    (jump),
        .jalr    (jalr)
    );

    regfile u_regfile (
        .clk      (clk),
        .we       (reg_we),
        .rs1      (rs1),
        .rs2      (rs2),
        .rd       (rd),
        .rd_data  (rd_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );


    // ---------- Execute ----------
    // TODO: alu_src MUX, u_alu, wb_sel MUX (step 3)

endmodule
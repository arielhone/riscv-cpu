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
    logic [31:0] alu_a, alu_b;
    logic [31:0] alu_out;
    logic        alu_zero;

    assign alu_a = rs1_data;
    assign alu_b = alu_src ? imm : rs2_data;   // 0 = rs2, 1 = imm

    alu u_alu (
        .a      (alu_a),
        .b      (alu_b),
        .alu_op (alu_op),
        .zero   (alu_zero),
        .result (alu_out)
    );

    logic [31:0] dmem_rdata;

    dmem u_dmem (
        .clk   (clk),
        .we    (mem_we),
        .be    (4'b1111),
        .addr  (alu_out),
        .wdata (rs2_data),
        .rdata (dmem_rdata)
    );
    
    // ---------- Load: pick the byte ----------
    logic [7:0] ld_byte;

    always_comb begin
        case (alu_out[1:0])
            2'b00:   ld_byte = dmem_rdata[7:0];
            2'b01:   ld_byte = dmem_rdata[15:8];
            2'b10:   ld_byte = dmem_rdata[23:16];
            default: ld_byte = dmem_rdata[31:24]; // 2'b11
        endcase
    end

    // ---------- Load: pick the halfword ----------
    logic [15:0] ld_half;

    assign ld_half = alu_out[1] ? dmem_rdata[31:16] : dmem_rdata[15:0];


    // ---------- Load: extend to 32 bits ----------
    logic [31:0] ld_data;

    always_comb begin
        case (funct3)
            3'b000:  ld_data = {{24{ld_byte[7]}}, ld_byte};  // LB
            3'b010:  ld_data = dmem_rdata;                   // LW
            3'b100:  ld_data = {{24{1'b0}}, ld_byte};        // LBU
            3'b001:  ld_data = {{16{ld_half[15]}}, ld_half};  // LH
            3'b101:  ld_data = {{16{1'b0}}, ld_half};         // LHU
            default: ld_data = dmem_rdata;
        endcase
    end



    // ---------- Write-back ----------
    always_comb begin
        case (wb_sel)
            2'd0:    rd_data = alu_out;    // R, I
            2'd1:    rd_data = ld_data; // loads
            2'd2:    rd_data = pc_plus4;   // JAL, JALR
            default: rd_data = alu_out;    // 2'd3 unused
        endcase
    end

endmodule
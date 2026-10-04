module ram16x8 (
    input  wire       clk, we,
    input  wire [3:0] addr,
    input  wire [7:0] wdata,
    output wire [7:0] rdata
);
    reg [7:0] mem [0:15];

    initial begin
        $readmemh("../programs/mem.hex", mem);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;
    end

    assign rdata = mem[addr];
endmodule
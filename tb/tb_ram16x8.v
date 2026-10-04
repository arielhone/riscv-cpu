module tb_ram16x8;
    reg clk = 0;
    always #5 clk = ~clk;

    reg        we;
    reg  [3:0] addr;
    reg  [7:0] wdata;
    wire [7:0] rdata;

    integer i;

    ram16x8 dut (.clk(clk), .we(we), .addr(addr), .wdata(wdata), .rdata(rdata));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_ram16x8);
        $monitor("t=%0t we=%b addr=%h wdata=%h -> rdata=%h",
                 $time, we, addr, wdata, rdata);

        we = 0; addr = 4'h0; wdata = 8'h00;

        for (i = 0; i < 4; i = i + 1) begin
            @(negedge clk);
            addr = i;
        end

        @(negedge clk);
        we = 1; wdata = 8'hAB;
        @(negedge clk);
        we = 0;
        @(negedge clk);
        wdata = 8'hFF;
        @(negedge clk);
        addr = 5;
        @(negedge clk);
        $finish;
    end
endmodule
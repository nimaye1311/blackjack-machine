module latch (q, d, clk, en, clr);

    input [31:0] d;
    input clk, en, clr;
    output [31:0] q;   

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : dffe_gen
            dffe_ref dff(.q(q[i]), .d(d[i]), .clk(~clk), .en(en), .clr(clr)); // ~clk because we want to latch to update on the falling edge
        end
    endgenerate

endmodule
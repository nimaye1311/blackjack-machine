module latch_5bit (q, d, clk, en, clr);

    input [4:0] d;
    input clk, en, clr;
    output [4:0] q;   

    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : dffe_gen
            dffe_ref dff(.q(q[i]), .d(d[i]), .clk(~clk), .en(en), .clr(clr)); // ~clk because we want to latch to update on the falling edge
        end
    endgenerate

endmodule
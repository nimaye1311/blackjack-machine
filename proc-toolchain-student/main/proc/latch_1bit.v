module latch_1bit (q, d, clk, en, clr);

    input d;
    input clk, en, clr;
    output q;   

    dffe_ref dff(.q(q), .d(d), .clk(clk), .en(en), .clr(clr)); // ~clk because we want to latch to update on the falling edge

endmodule
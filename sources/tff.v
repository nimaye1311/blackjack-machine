module tff (t, clk, clr, q);

    input t, clk, clr;
    output q;

    wire d;
    assign d = t ^ q;
    
    dffe_ref ff (.q(q), .d(d), .clk(clk), .en(1'b1), .clr(clr));

endmodule
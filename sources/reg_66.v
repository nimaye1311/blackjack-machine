module reg_66(q, d, clock, en, clr);

    input[65:0] d;
    input clock, en, clr;

    output[65:0] q;

    genvar i;
    generate

		for (i = 0; i < 66; i = i + 1) begin : d_flip_flop

            dffe_ref dff (
                .q(q[i]),
                .d(d[i]),
                .clk(clock),
                .en(en),
                .clr(clr)
            );
        end
        
    endgenerate

endmodule
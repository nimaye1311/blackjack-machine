module sx (in, out);

    input [16:0] in;
    output [31:0] out;

    assign out[16:0] = in;  

    genvar i;
    generate
        for (i = 17; i < 32; i = i + 1) begin : sign_extend
            assign out[i] = in[16];
        end
    endgenerate

endmodule
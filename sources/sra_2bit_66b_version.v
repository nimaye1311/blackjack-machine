module sra_2bit_66b_version(A, Out);

    input[65:0] A;
    output[65:0] Out;

    assign Out[65] = A[65];
    assign Out[64] = A[65];

    genvar i;
    generate
        for (i = 2; i < 66; i = i+1) begin
            assign Out[i-2] = A[i];
        end
    endgenerate
    
endmodule
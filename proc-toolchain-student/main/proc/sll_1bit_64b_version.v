module sll_1bit_64b_version(A, Out);

    input[63:0] A;
    output[63:0] Out;

    assign Out[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 63; i = i+1) begin
            assign Out[i+1] = A[i];
        end
    endgenerate
    
endmodule
module sra_4bit(A, Out);

    input[31:0] A;
    output[31:0] Out;

    assign Out[31] = A[31];
    assign Out[30] = A[31];
    assign Out[29] = A[31];
    assign Out[28] = A[31];

    genvar i;
    generate
        for (i = 4; i < 32; i = i+1) begin
            assign Out[i-4] = A[i];
        end
    endgenerate
    
endmodule
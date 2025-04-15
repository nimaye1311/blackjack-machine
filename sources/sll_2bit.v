module sll_2bit(A, Out);

    input[31:0] A;
    output[31:0] Out;

    assign Out[0] = 1'b0;
    assign Out[1] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 30; i = i+1) begin
            assign Out[i+2] = A[i];
        end
    endgenerate
    
endmodule
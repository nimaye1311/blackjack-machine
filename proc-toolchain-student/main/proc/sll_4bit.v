module sll_4bit(A, Out);

    input[31:0] A;
    output[31:0] Out;

    assign Out[0] = 1'b0;
    assign Out[1] = 1'b0;
    assign Out[2] = 1'b0;
    assign Out[3] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 28; i = i+1) begin
            assign Out[i+4] = A[i];
        end
    endgenerate
    
endmodule
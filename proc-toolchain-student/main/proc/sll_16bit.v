module sll_16bit(A, Out);

    input[31:0] A;
    output[31:0] Out;

    assign Out[0] = 1'b0;
    assign Out[1] = 1'b0;
    assign Out[2] = 1'b0;
    assign Out[3] = 1'b0;
    assign Out[4] = 1'b0;
    assign Out[5] = 1'b0;
    assign Out[6] = 1'b0;
    assign Out[7] = 1'b0;
    assign Out[8] = 1'b0;
    assign Out[9] = 1'b0;
    assign Out[10] = 1'b0;
    assign Out[11] = 1'b0;
    assign Out[12] = 1'b0;
    assign Out[13] = 1'b0;
    assign Out[14] = 1'b0;
    assign Out[15] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 16; i = i+1) begin
            assign Out[i+16] = A[i];
        end
    endgenerate
    
endmodule
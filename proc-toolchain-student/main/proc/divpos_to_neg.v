module divpos_to_neg(A, Out);

    input[31:0] A;
    output[31:0] Out;
    wire[31:0] InterMed;

    genvar i;
    generate
        for (i = 0; i < 32; i = i+1) 
        begin : loop
            assign InterMed[i] = ~A[i];
        end
    endgenerate

    thirty_two_bit_adder add(.A(InterMed), .B(32'b1), .sub(1'b0), .sum(Out), .ovf());

endmodule
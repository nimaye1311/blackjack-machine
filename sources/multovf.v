module multovf(hi, A, B, ret);

    input [33:0] hi;
    input [31:0] A, B;
    output ret;

    wire same_sign, diff_sign, all_zero, all_one, ovf, A_zero, B_zero;

    assign diff_sign = A[31] ^ B[31]; // True if signs are different
    assign same_sign = ~diff_sign; // True if signs are same

    assign all_zero = ~(|hi); // OR reduction, true if all bits are 0
    assign all_one  = (&hi) & diff_sign;    // AND reduction, true if all bits are 1
    assign ovf = ~ ((all_zero & same_sign) | (all_one & diff_sign)); // False if all bits are the same

    assign A_zero = ~(|A);
    assign B_zero = ~(|B);

    assign ret = (A_zero | B_zero) ? 1'b0 : ovf;

endmodule
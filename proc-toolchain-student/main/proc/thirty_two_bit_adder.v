module thirty_two_bit_adder(A, B, sub, ovf, sum);

    input[31:0] A, B;
    input sub; // if sub = 1, we do A - B. Otherwise, we do A + B.
    output ovf;
    output[31:0] sum;

    wire P0, P1, P2, P3, G0, G1, G2, G3, c8, c16, c24, c32, c31;
    wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10;
    wire w11, w12, w13;

    wire [31:0] B_mod;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : xor_loop
            xor xorgate(B_mod[i], B[i], sub);
        end
    endgenerate

    and and1(w1, P0, sub);
    or or1(c8, G0, w1);

    and and2(w2, P1, P0, sub);
    and and3(w3, P1, G0);
    or or2(c16, G1, w2, w3);

    and and4(w4, P2, P1, P0, sub);
    and and5(w5, P2, P1, G0);
    and and6(w6, P2, G1);
    or or3(c24, G2, w4, w5, w6);

    and and7(w7, P3, P2, P1, P0, sub);
    and and8(w8, P3, P2, P1, G0);
    and and9(w9, P3, P2, G1);
    and and10(w10, P3, G2);
    or or4(c32, G3, w7, w8, w9, w10);

    eight_bit_adder adder1(.A(A[7:0]), .B(B_mod[7:0]), .Cin(sub), .Sout(sum[7:0]), .P0(P0), .G0(G0), .c7(w11));
    eight_bit_adder adder2(.A(A[15:8]), .B(B_mod[15:8]), .Cin(c8), .Sout(sum[15:8]), .P0(P1), .G0(G1), .c7(w12));
    eight_bit_adder adder3(.A(A[23:16]), .B(B_mod[23:16]), .Cin(c16), .Sout(sum[23:16]), .P0(P2), .G0(G2), .c7(w13));
    eight_bit_adder adder4(.A(A[31:24]), .B(B_mod[31:24]), .Cin(c24), .Sout(sum[31:24]), .P0(P3), .G0(G3), .c7(c31));

    xor overflow_detection(ovf, c31, c32);

endmodule
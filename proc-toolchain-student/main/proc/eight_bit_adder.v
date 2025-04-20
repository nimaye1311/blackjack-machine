module eight_bit_adder(A, B, Cin, Sout, P0, G0, c7);

    input[7:0] A, B;
    input Cin;
    output P0, G0, c7;
    output[7:0] Sout;

    wire g0, g1, g2, g3, g4, g5, g6, g7, p0, p1, p2, p3, p4, p5, p6, p7, c0, c1, c2, c3, c4, c5, c6;
    
    assign c0 = Cin;

    and and0(g0, A[0], B[0]);
    and and1(g1, A[1], B[1]);
    and and2(g2, A[2], B[2]);
    and and3(g3, A[3], B[3]);
    and and4(g4, A[4], B[4]);
    and and5(g5, A[5], B[5]);
    and and6(g6, A[6], B[6]);
    and and7(g7, A[7], B[7]);

    or or0(p0, A[0], B[0]);
    or or1(p1, A[1], B[1]);
    or or2(p2, A[2], B[2]);
    or or3(p3, A[3], B[3]);
    or or4(p4, A[4], B[4]);
    or or5(p5, A[5], B[5]);
    or or6(p6, A[6], B[6]);
    or or7(p7, A[7], B[7]);

    wire w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15;
    wire w16, w17, w18, w19, w20, w21, w22, w23, w24, w25, w26, w27, w28, w29;
    wire w30, w31, w32, w33, w34;

    and and8(w0, p0, c0);
    or or8(c1, g0, w0);

    and and9(w1, p1, p0, c0);
    and and10(w2, p1, g0);
    or or11(c2, g1, w2, w1);

    and and11(w3, p2, p1, p0, c0);
    and and12(w4, p2, p1, g0);
    and and13(w5, p2, g1);
    or or12(c3, g2, w3, w4, w5);

    and and14(w6, p3, p2, p1, p0, c0);
    and and15(w7, p3, p2, p1, g0);
    and and16(w8, p3, p2, g1);
    and and17(w9, p3, g2);
    or or13(c4, g3, w9, w8, w7, w6);

    and and18(w10, p4, p3, p2, p1, p0, c0);
    and and19(w11, p4, p3, p2, p1, g0);
    and and20(w12, p4, p3, p2, g1);
    and and21(w13, p4, p3, g2);
    and and22(w14, p4, g3);
    or or14(c5, g4, w10, w11, w12, w13, w14);

    and and23(w15, p5, p4, p3, p2, p1, p0, c0);
    and and24(w16, p5, p4, p3, p2, p1, g0);
    and and25(w17, p5, p4, p3, p2, g1);
    and and26(w18, p5, p4, p3, g2);
    and and27(w19, p5, p4, g3);
    and and28(w20, p5, g4);
    or or15(c6, g5, w15, w16, w17, w18, w19, w20);

    and and29(w21, p6, p5, p4, p3, p2, p1, p0, c0);
    and and30(w22, p6, p5, p4, p3, p2, p1, g0);
    and and31(w23, p6, p5, p4, p3, p2, g1);
    and and32(w24, p6, p5, p4, p3, g2);
    and and33(w25, p6, p5, p4, g3);
    and and34(w26, p6, p5, g4);
    and and35(w27, p6, g5);
    or or16(c7, g6, w21, w22, w23, w24, w25, w26, w27);

    and and36(P0, p7, p6, p5, p4, p3, p2, p1, p0);
    and and37(w28, p7, p6, p5, p4, p3, p2, p1, g0);
    and and38(w29, p7, p6, p5, p4, p3, p2, g1);
    and and39(w30, p7, p6, p5, p4, p3, g2);
    and and40(w31, p7, p6, p5, p4, g3);
    and and41(w32, p7, p6, p5, g4);
    and and42(w33, p7, p6, g5);
    and and43(w34, p7, g6);
    or or17(G0, g7, w28, w29, w30, w31, w32, w33, w34);

    xor sum0(Sout[0], A[0], B[0], c0);
    xor sum1(Sout[1], A[1], B[1], c1);
    xor sum2(Sout[2], A[2], B[2], c2);
    xor sum3(Sout[3], A[3], B[3], c3);
    xor sum4(Sout[4], A[4], B[4], c4);
    xor sum5(Sout[5], A[5], B[5], c5);
    xor sum6(Sout[6], A[6], B[6], c6);
    xor sum7(Sout[7], A[7], B[7], c7);
    
endmodule
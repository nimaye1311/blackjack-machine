module sra_barrel(A, ctrl_shiftamt, Out);

    input[31:0] A;
    input[4:0] ctrl_shiftamt;

    output[31:0] Out;

    wire[31:0] w1, w2, w3, w4, w5, w6, w7, w8, w9;

    sra_1bit shift1(.A(A), .Out(w1));
    mux_2 cshift1(w2, ctrl_shiftamt[0], A, w1);

    sra_2bit shift2(.A(w2), .Out(w3));
    mux_2 cshift2(w4, ctrl_shiftamt[1], w2, w3);

    sra_4bit shift4(.A(w4), .Out(w5));
    mux_2 cshift4(w6, ctrl_shiftamt[2], w4, w5);

    sra_8bit shift8(.A(w6), .Out(w7));
    mux_2 cshift8(w8, ctrl_shiftamt[3], w6, w7);

    sra_16bit shift16(.A(w8), .Out(w9));
    mux_2 cshift16(Out, ctrl_shiftamt[4], w8, w9);

endmodule
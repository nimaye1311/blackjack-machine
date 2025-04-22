module mux_4_12bit(out, select, in0, in1, in2, in3);
    input[11:0] in0, in1, in2, in3;
    input[1:0] select;
    output[11:0] out;
    wire[11:0] w1, w2;

    mux_2_12bit first_top(w1, select[0], in0, in1);
    mux_2_12bit first_bottom(w2, select[0], in2, in3);
    mux_2_12bit second(out, select[1], w1, w2);
endmodule
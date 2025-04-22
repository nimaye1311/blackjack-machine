module mux_2_12bit(out, select, in0, in1);

    input[11:0] in1, in0;
    input select;
    output[11:0] out;

    assign out = select ? in1:in0;

endmodule
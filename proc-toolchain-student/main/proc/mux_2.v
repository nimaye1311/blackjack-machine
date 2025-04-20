module mux_2(out, select, in0, in1);

    input[31:0] in1, in0;
    input select;
    output[31:0] out;

    assign out = select ? in1:in0;

endmodule
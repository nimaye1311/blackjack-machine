module mult(data_operandA, data_operandB,
        ctrl_MULT, clock,
        data_result, data_exception, 
        counter_zero);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, clock, counter_zero;
    output [31:0] data_result;
    output data_exception;

    wire [31:0] ctrl_MULT_mux_out; // 2nd bit 1 = do nothing 
                                     // 1st bit supplies OpCode for adder, 
                                     // 0th bit supplies whether or not we shift multiplicand left by 1 logically
    wire [65:0] adder_res, AQ_out, adder_res_shifted, AQ_in_shifted, AQ_out_shifted, AQ_in;
    wire bonus_bit, adder_ovf;
    wire [31:0] multiplicand_shifted, multiplicand_adder, adder_result;

    mux_8 set_control_bits(.out(ctrl_MULT_mux_out), .select(AQ_out[2:0]),
                        .in0({29'b0,1'b1,2'b0}), .in1({29'b0,3'b0}),
                        .in2({29'b0,3'b0}), .in3({29'b0,2'b0,1'b1}),
                        .in4({29'b0,1'b0,2'b11}), 
                        .in5({29'b0,1'b0,1'b1,1'b0}),
                        .in6({29'b0,1'b0,1'b1,1'b0}),
                        .in7({29'b0,1'b1,2'b0}));


    sll_1bit left_shift(.A(data_operandA), .Out(multiplicand_shifted)); 

    assign multiplicand_adder = ctrl_MULT_mux_out[0] ? multiplicand_shifted : data_operandA;

    thirty_two_bit_adder adder(.A(AQ_out[64:33]), .B(multiplicand_adder), .sub(ctrl_MULT_mux_out[1]), .sum(adder_result), .ovf(adder_ovf));

    assign bonus_bit = (adder_ovf & (~adder_result[31])) | adder_result[31];

    assign adder_res = {bonus_bit, adder_result, AQ_out[32:0]};
    
    sra_2bit_66b_version right_shift(.A(adder_res), .Out(adder_res_shifted));
    sra_2bit_66b_version right_shift_2(.A(AQ_out), .Out(AQ_out_shifted));

    assign AQ_in_shifted = ctrl_MULT_mux_out[2] ? AQ_out_shifted : adder_res_shifted;
    
    assign AQ_in = counter_zero ? {33'b0, data_operandB, 1'b0} : AQ_in_shifted;

    reg_66 AQ(.q(AQ_out), .d(AQ_in), .clock(clock), .en(1'b1), .clr(ctrl_MULT));
    
    assign data_result = AQ_out[32:1];
    multovf compute_overflow(.hi(AQ_out[65:32]), .A(data_operandA), .B(data_operandB), .ret(data_exception));

endmodule
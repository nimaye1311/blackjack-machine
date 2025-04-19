module div(data_operandA, data_operandB,
        ctrl_DIV, clock,
        data_result, data_exception, 
        counter_zero);

    input [31:0] data_operandA, data_operandB;
    input ctrl_DIV, clock, counter_zero;
    output [31:0] data_result;
    output data_exception;

    wire [31:0] Aneg, Bneg, DataResultNeg;
    wire [31:0] A, B;

    divpos_to_neg negA(.A(data_operandA), .Out(Aneg));
    divpos_to_neg negB(.A(data_operandB), .Out(Bneg));
    divpos_to_neg negRes(.A(AQ_out[31:0]), .Out(DataResultNeg));

    assign A = data_operandA[31] ? Aneg : data_operandA;    
    assign B = data_operandB[31] ? Bneg : data_operandB;

    wire [63:0] AQ_out, AQ_in, AQ_out_shifted;
    wire [31:0] adder_res;

    sll_1bit_64b_version shift(.A(AQ_out), .Out(AQ_out_shifted));

    thirty_two_bit_adder adder(.A(AQ_out_shifted[63:32]), .B(B), .sub(~AQ_out_shifted[63]), .sum(adder_res), .ovf());

    assign AQ_in = counter_zero ? 
               {32'b0, A} : 
               {adder_res, AQ_out_shifted[31:1], ~adder_res[31]};

    reg_64 AQ(.q(AQ_out), .d(AQ_in), .clock(clock), .en(1'b1), .clr(ctrl_DIV));

    assign data_result = (data_operandA[31] ^ data_operandB[31]) ? DataResultNeg : AQ_out[63:32];
    assign data_exception = ~(|data_operandB);

endmodule
module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;
    
    wire overflow_add, overflow_sub;
    wire [31:0] add_result, sub_result, and_result, or_result, shift_left_logical_result, shift_right_arithmetic_result, all_zeros;

    assign all_zeros = 32'b0;

    thirty_two_bit_adder adder(.A(data_operandA), .B(data_operandB), .sub(1'b0), .ovf(overflow_add), .sum(add_result));
    thirty_two_bit_adder subtracter(.A(data_operandA), .B(data_operandB), .sub(1'b1), .ovf(overflow_sub), .sum(sub_result));

    assign overflow = ctrl_ALUopcode[0] ? overflow_sub:overflow_add;

    is_zero checkingEquality(sub_result, isNotEqual);
    assign isLessThan = ~sub_result[31] & isNotEqual;    // isLessThan = 1 if A > B, B < A!

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : and_loop
            and andgate(and_result[i], data_operandA[i], data_operandB[i]);
        end
    endgenerate

    genvar j;
    generate
        for (j = 0; j < 32; j = j + 1) begin : or_loop
            or orgate(or_result[j], data_operandA[j], data_operandB[j]);
        end
    endgenerate

    sll_barrel shift_left(data_operandA, ctrl_shiftamt, shift_left_logical_result);
    sra_barrel shift_right(data_operandA, ctrl_shiftamt, shift_right_arithmetic_result);

    mux_32 mux (
    .out(data_result), 
    .select(ctrl_ALUopcode), 
    .in0(add_result), 
    .in1(sub_result), 
    .in2(and_result), 
    .in3(or_result), 
    .in4(shift_left_logical_result), 
    .in5(shift_right_arithmetic_result), 
    .in6(all_zeros), .in7(all_zeros), .in8(all_zeros), .in9(all_zeros), 
    .in10(all_zeros), .in11(all_zeros), .in12(all_zeros), .in13(all_zeros), 
    .in14(all_zeros), .in15(all_zeros), .in16(all_zeros), .in17(all_zeros), 
    .in18(all_zeros), .in19(all_zeros), .in20(all_zeros), .in21(all_zeros), 
    .in22(all_zeros), .in23(all_zeros), .in24(all_zeros), .in25(all_zeros), 
    .in26(all_zeros), .in27(all_zeros), .in28(all_zeros), .in29(all_zeros), 
    .in30(all_zeros), .in31(all_zeros));

endmodule
module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY, OpMult);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY, OpMult;

    // add your code here

    wire [5:0] count_out;
    wire [31:0] mult_res, div_res;
    wire mult_exception, div_exception;
    counter counter_up_64(.reset(ctrl_MULT | ctrl_DIV), .clk(clock), .count(count_out));
    wire done_count, counter_zero;
    wire mult_res_ready, div_res_ready;
    assign counter_zero = (~count_out[0]) & (~count_out[1]) & (~count_out[2]) & (~count_out[3]) & (~count_out[4]) & (~count_out[5]);

    wire current_op_mult;

    dffe_ref dff(.q(current_op_mult), .d(ctrl_MULT), .clk(clock), .en(ctrl_MULT | ctrl_DIV), .clr(1'b0));

    wire [31:0] data_operandA_latched, data_operandB_latched;

    assign mult_res_ready = count_out[0] & (~count_out[1]) & (~count_out[2]) & (~count_out[3]) & count_out[4] & (~count_out[5]);
    assign div_res_ready = (count_out[0]) & (~count_out[1]) & (~count_out[2]) & (~count_out[3]) & (~count_out[4]) & count_out[5];

    latch A(.q(data_operandA_latched), .d(data_operandA), .clk(clock), .en(ctrl_MULT | ctrl_DIV), .clr(1'b0));
    latch B(.q(data_operandB_latched), .d(data_operandB), .clk(clock), .en(ctrl_MULT | ctrl_DIV), .clr(1'b0));

    mult multiply(.data_operandA(data_operandA_latched), .data_operandB(data_operandB_latched), .ctrl_MULT(ctrl_MULT), .clock(clock), 
            .data_result(mult_res), .data_exception(mult_exception),
            .counter_zero(counter_zero));

     div divide(.data_operandA(data_operandA_latched), .data_operandB(data_operandB_latched), .ctrl_DIV(ctrl_DIV), .clock(clock), 
            .data_result(div_res), .data_exception(div_exception),
            .counter_zero(counter_zero));

    assign data_resultRDY = (mult_res_ready & current_op_mult) | (div_res_ready & ~current_op_mult);
    assign data_result = current_op_mult ? mult_res : div_res;
    assign data_exception = current_op_mult ? mult_exception : div_exception;
    assign OpMult = current_op_mult;

endmodule
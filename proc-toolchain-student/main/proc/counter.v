module counter (
    input clk,      
    input reset,     
    output wire [5:0] count  
);

    wire [5:0] t_ff;  
    wire [5:0] q;     

    assign t_ff[0] = 1'b1;  
    assign t_ff[1] = q[0];  
    assign t_ff[2] = q[1] & q[0];  
    assign t_ff[3] = q[2] & q[1] & q[0];  
    assign t_ff[4] = q[3] & q[2] & q[1] & q[0];
    assign t_ff[5] = q[4] & q[3] & q[2] & q[1] & q[0];

    tff tff0 (.q(q[0]), .t(t_ff[0]), .clk(clk), .clr(reset));
    tff tff1 (.q(q[1]), .t(t_ff[1]), .clk(clk), .clr(reset));
    tff tff2 (.q(q[2]), .t(t_ff[2]), .clk(clk), .clr(reset));
    tff tff3 (.q(q[3]), .t(t_ff[3]), .clk(clk), .clr(reset));
    tff tff4 (.q(q[4]), .t(t_ff[4]), .clk(clk), .clr(reset));
    tff tff5 (.q(q[5]), .t(t_ff[5]), .clk(clk), .clr(reset));

    assign count = q;

endmodule

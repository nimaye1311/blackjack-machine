module rng (
    input  [31:0] current,
    output [31:0] next
);

    /*

        Takes a 32-bit Input
        Returns a 32-bit Output
        Use as FSM, set some initial state in $1 of the MIPS code
        Take mod 52 of output and then add + 1 to use as index for the number

    */

    wire [31:0] next1, next2;

    assign next1 = current ^ (current << 13);
    assign next2 = next1 ^ (next1 >> 17);
    assign next  = next2 ^ (next2 << 5);

endmodule
module fulladder_structural(
    input a,b,cin,
    output sum,carry
    );
    wire sum_0, carry_0, carry_1;
    
    half_adder ha0 (.a(a), .b(b), .sum(sum_0);, .carry(carry_0));
    half_adder ha1 (.a(sum_0), .b(cin), .sum(sum);, .carry(carry_1));

    or(carry,carry_0,carry_1);
endmodule

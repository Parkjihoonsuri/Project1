`timescale 1ns / 1ps
module and_gate(
    input a,
    input b,
    output f
    );
    and(f,a,b);
   
endmodule

module half_adder(
    input a,
    input b,
    output sum,
    output carry
    );
    
    xor(sum,a,b);
    and(carry,a,b);
   
endmodule

module half_adder_dataflow(
    input a,
    input b,
    output sum,
    output carry
    );
    
    assign sum= a^b;
    assign carry= a&b;
   
endmodule


module half_adder_behaviaral(
    input a,
    input b,
    output reg sum,
    output reg carry
    );
    
    always@(a,b)begin
    case({a,b})
       2'b00; begin sum=0; carry=0; end
       2'b01; begin sum=1; carry=0; end
       2'b10; begin sum=1; carry=0; end
       2'b11; begin sum=0; carry=1; end
    end
    endcase
   
endmodule
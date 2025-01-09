`timescale 1ns / 1ps
module adder( input [7:0] In,
      output [7:0] Out
    );

assign Out = In + 1;

endmodule
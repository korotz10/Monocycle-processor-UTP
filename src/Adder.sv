module Adder(
    input logic signed [31:0] pc_in,
    output logic signed [31:0] pc_out
);
    //add 4 to address
    assign pc_out = pc_in + 32'd4;

endmodule
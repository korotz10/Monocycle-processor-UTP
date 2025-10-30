module NextPCMux(
    input logic signed [31:0] pc_plus4,
    input logic signed [31:0] branch_target,
    input logic sel,

    output logic signed [31:0] next_pc
);
    always @(*) begin
        if (sel)
            next_pc = branch_target;
        else
            next_pc = pc_plus4;
    end

endmodule
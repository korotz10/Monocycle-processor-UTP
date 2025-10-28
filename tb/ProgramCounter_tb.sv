module ProgramCounter(

    input logic clk,
    input logic PCWr, // toggle
    input logic signed [31:0] PCIn,

    output logic signed [31:0] PCOut
);

    logic signed [31:0] pc_reg;

    assign PCOut = pc_reg;

    always @(posedge clk) begin
        if (PCWr) begin
            pc_reg <= PCIn;
        end 
    end

endmodule
module ImmGenerator(
    input logic signed [2:0] ImmSrc,
    input logic signed [31:0] instruction,
    output logic signed [31:0] Imm_ext
);

always @(*) begin
    case(ImmSrc)
        // I-type 
        3'b000:
            Imm_ext = {{20{instruction[31]}}, instruction[31:20]};

        // S-type
        3'b001:
            Imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

        // B-type
        3'b101: 
            Imm_ext = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};

        // U-type
        3'b010: 
            Imm_ext = {instruction[31:12], 12'b0};

        // J-type
        3'b110:
            Imm_ext = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

        default:
            Imm_ext = 32'd0; // Default case
    endcase
    
end

endmodule
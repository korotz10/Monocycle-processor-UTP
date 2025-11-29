module ImmGenerator(
    input logic [2:0] ImmSrc,
    input logic signed [31:0] instruction,
    input logic [2:0] funct3,
    output logic signed [31:0] Imm_ext
);

always @(*) begin
    case(ImmSrc)
        // I-type 
        3'b000: begin
            // Verificar si es una instrucción de shift inmediato
            // SLLI: funct3=001, SRLI/SRAI: funct3=101
            if (instruction[14:12] == 3'b001 || instruction[14:12] == 3'b101) begin
                // Para shifts: solo usar shamt[4:0] sin extensión de signo
                Imm_ext = {27'b0, instruction[24:20]};
            end else begin
                // Para otras I-type: extensión de signo normal
                Imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            end
        end

        // S-type
        3'b001:
            Imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

        // B-type
        3'b101: 
            Imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

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
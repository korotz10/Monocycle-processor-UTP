module ControlUnit (
    input  logic [6:0] OpCode,
    input  logic [2:0] Funct3,
    input  logic [6:0] Funct7,

    // Señales de control del datapath
    output logic       RUWr,
    output logic [1:0] RUDataWrSrc,

    output logic       ALUASrc,
    output logic       ALUBSrc,
    output logic [3:0] ALUOp,

    output logic       DMWr,
    output logic [2:0] DMCtrl,

    output logic [2:0] ImmSrc,
    output logic [4:0] BrOp
);

    always @(*) begin

        // Reset de todas las señales
        RUWr        = 0;
        RUDataWrSrc = 2'b00;
        ALUASrc     = 0;
        ALUBSrc     = 0;
        ALUOp       = 4'b0000;
        DMWr        = 0;
        DMCtrl      = 3'b000;
        ImmSrc      = 3'b000;
        BrOp        = 5'b00000;

        case (OpCode)

        // ============================================
        //  TYPE R
        // ============================================
        7'b0110011: begin
            RUWr = 1;
            ALUASrc = 0;
            ALUBSrc = 0;
            RUDataWrSrc = 2'b00; // from ALU
            ImmSrc = 3'b000; // not used

            // ALU operation determined by funct3/funct7
            case ({Funct7, Funct3})
                10'b0000000_000: ALUOp = 4'b0000; // ADD
                10'b0100000_000: ALUOp = 4'b1000; // SUB
                10'b0000000_001: ALUOp = 4'b0001; // SLL
                10'b0000000_010: ALUOp = 4'b0010; // SLT
                10'b0000000_011: ALUOp = 4'b0011; // SLTU
                10'b0000000_100: ALUOp = 4'b0100; // XOR
                10'b0000000_101: ALUOp = 4'b0101; // SRL
                10'b0100000_101: ALUOp = 4'b1101; // SRA
                10'b0000000_110: ALUOp = 4'b0110; // OR
                10'b0000000_111: ALUOp = 4'b0111; // AND
                
                default:          ALUOp = 4'b0000;
            endcase
        end

        // ============================================
        //  TYPE I
        // ============================================
        7'b0010011: begin
            RUWr = 1;
            ALUASrc = 0;
            ALUBSrc = 1; // immediate
            RUDataWrSrc = 2'b00; 
            ImmSrc = 3'b000; // I-type

            case (Funct3)
                3'b000: ALUOp = 4'b0000; // ADDI
                3'b001: ALUOp = 4'b0001; // SLLI
                3'b010: ALUOp = 4'b0010; // SLTI
                3'b011: ALUOp = 4'b0011; // SLTIU
                3'b100: ALUOp = 4'b0100; // XORI
                3'b101: begin
                    // SRLI vs SRAI: bit 30 de la instrucción (Funct7[5])
                    if (Funct7[5] == 1'b0)
                        ALUOp = 4'b0101; // SRLI
                    else
                        ALUOp = 4'b1101; // SRAI
                end
                3'b110: ALUOp = 4'b0110; // ORI
                3'b111: ALUOp = 4'b0111; // ANDI
                
            endcase
        end

        // ============================================
        // LOAD 
        // ============================================
        7'b0000011: begin
            RUWr        = 1;
            ALUASrc     = 0;
            ALUBSrc     = 1;
            RUDataWrSrc = 2'b01; // Memory
            ImmSrc      = 3'b000; // I-type
            DMWr        = 0;

            DMCtrl = Funct3; // memory access type

            ALUOp = 4'b0000; // address = rs1 + imm
        end

        // ============================================
        // STORE 
        // ============================================
        7'b0100011: begin
            RUWr    = 0;
            ALUASrc = 0;
            ALUBSrc = 1;
            ImmSrc  = 3'b001; // S-type

            DMWr = 1;
            DMCtrl = Funct3;

            ALUOp = 4'b0000;
        end

        // ============================================
        // BRANCH
        // ============================================
        7'b1100011: begin
            RUWr = 0;
            ALUASrc = 1;
            ALUBSrc = 1;
            ALUOp = 4'b0000;

            ImmSrc = 3'b101; // B-type

            case (Funct3)
                3'b000: BrOp = 5'b01000;   // BEQ
                3'b001: BrOp = 5'b01001;   // BNE
                3'b100: BrOp = 5'b01100;   // BLT
                3'b101: BrOp = 5'b01101;   // BGE
                3'b110: BrOp = 5'b01110;   // BLTU
                3'b111: BrOp = 5'b01111;   // BGEU
            endcase
        end

        // ============================================
        // JAL
        // ============================================
        7'b1101111: begin
            RUWr        = 1;
            RUDataWrSrc = 2'b10; // PC+4
            ImmSrc      = 3'b110; // J-type
            BrOp        = 5'b10000; // unconditional

            ALUASrc = 1; // PC
            ALUBSrc = 1; // immediate
            ALUOp   = 4'b0000;
        end

        // ============================================
        // JALR
        // ============================================
        7'b1100111: begin
            RUWr        = 1;
            RUDataWrSrc = 2'b10; 
            ImmSrc      = 3'b000;
            BrOp        = 5'b10000;

            ALUASrc = 0; // rs1
            ALUBSrc = 1; // immediate
            ALUOp   = 4'b0000;
        end

        // ============================================
        // LUI
        // ============================================
        7'b0110111: begin
            RUWr = 1;
            RUDataWrSrc = 2'b11; // immediate extended
            ImmSrc = 3'b010; // U-type
        end

        // AUIPC
        7'b0010111: begin
            RUWr = 1;
            RUDataWrSrc = 2'b00;
            ImmSrc = 3'b010;
            ALUASrc = 1; // PC
            ALUBSrc = 1; // immediate
            ALUOp = 4'b0000;
        end

        endcase
    end

endmodule
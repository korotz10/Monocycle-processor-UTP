`timescale 1ns/1ps

module ControlUnit_tb;

    // Señales de entrada
    logic [6:0] OpCode;
    logic [2:0] Funct3;
    logic [6:0] Funct7;
    
    // Señales de salida
    logic       RUWr;
    logic [1:0] RUDataWrSrc;
    logic       ALUASrc;
    logic       ALUBSrc;
    logic [3:0] ALUOp;
    logic       DMWr;
    logic [2:0] DMCtrl;
    logic [2:0] ImmSrc;
    logic [4:0] BrOp;
    
    // Instancia del módulo
    ControlUnit uut (
        .OpCode(OpCode),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .RUWr(RUWr),
        .RUDataWrSrc(RUDataWrSrc),
        .ALUASrc(ALUASrc),
        .ALUBSrc(ALUBSrc),
        .ALUOp(ALUOp),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .ImmSrc(ImmSrc),
        .BrOp(BrOp)
    );
    
    integer errors = 0;
    integer tests = 0;

    initial begin
        $dumpfile("sim/ControlUnit_tb.vcd");
        $dumpvars(0, ControlUnit_tb);
    end
    
    // Task para verificar señales
    task check_signals(
        input string test_name,
        input logic exp_RUWr,
        input logic [1:0] exp_RUDataWrSrc,
        input logic exp_ALUASrc,
        input logic exp_ALUBSrc,
        input logic [3:0] exp_ALUOp,
        input logic exp_DMWr,
        input logic [2:0] exp_DMCtrl,
        input logic [2:0] exp_ImmSrc,
        input logic [4:0] exp_BrOp
    );
        tests++;
        #1;
        
        if (RUWr !== exp_RUWr || RUDataWrSrc !== exp_RUDataWrSrc || 
            ALUASrc !== exp_ALUASrc || ALUBSrc !== exp_ALUBSrc ||
            ALUOp !== exp_ALUOp || DMWr !== exp_DMWr || 
            DMCtrl !== exp_DMCtrl || ImmSrc !== exp_ImmSrc || BrOp !== exp_BrOp) begin
            
            $display("ERROR: %s", test_name);
            $display("   OpCode: 0x%h, Funct3: 0x%h, Funct7: 0x%h", OpCode, Funct3, Funct7);
            
            if (RUWr !== exp_RUWr)
                $display("   RUWr: Expected %b, Got %b", exp_RUWr, RUWr);
            if (RUDataWrSrc !== exp_RUDataWrSrc)
                $display("   RUDataWrSrc: Expected %b, Got %b", exp_RUDataWrSrc, RUDataWrSrc);
            if (ALUASrc !== exp_ALUASrc)
                $display("   ALUASrc: Expected %b, Got %b", exp_ALUASrc, ALUASrc);
            if (ALUBSrc !== exp_ALUBSrc)
                $display("   ALUBSrc: Expected %b, Got %b", exp_ALUBSrc, ALUBSrc);
            if (ALUOp !== exp_ALUOp)
                $display("   ALUOp: Expected 0x%h, Got 0x%h", exp_ALUOp, ALUOp);
            if (DMWr !== exp_DMWr)
                $display("   DMWr: Expected %b, Got %b", exp_DMWr, DMWr);
            if (DMCtrl !== exp_DMCtrl)
                $display("   DMCtrl: Expected %b, Got %b", exp_DMCtrl, DMCtrl);
            if (ImmSrc !== exp_ImmSrc)
                $display("   ImmSrc: Expected %b, Got %b", exp_ImmSrc, ImmSrc);
            if (BrOp !== exp_BrOp)
                $display("   BrOp: Expected %b, Got %b", exp_BrOp, BrOp);
            
            errors++;
        end else begin
            $display("PASS: %s", test_name);
        end
    endtask
    
    initial begin
        $display("\n========================================");
        $display("  ControlUnit Testbench");
        $display("========================================\n");
        
        // ==================== R-TYPE INSTRUCTIONS ====================
        $display("--- R-TYPE INSTRUCTIONS ---\n");
        
        // Test 1: ADD
        OpCode = 7'b0110011; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("ADD", 1, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 2: SUB
        OpCode = 7'b0110011; Funct3 = 3'b000; Funct7 = 7'b0100000;
        #10 check_signals("SUB", 1, 2'b00, 0, 0, 4'b1000, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 3: SLL
        OpCode = 7'b0110011; Funct3 = 3'b001; Funct7 = 7'b0000000;
        #10 check_signals("SLL", 1, 2'b00, 0, 0, 4'b0001, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 4: SLT
        OpCode = 7'b0110011; Funct3 = 3'b010; Funct7 = 7'b0000000;
        #10 check_signals("SLT", 1, 2'b00, 0, 0, 4'b0010, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 5: SLTU
        OpCode = 7'b0110011; Funct3 = 3'b011; Funct7 = 7'b0000000;
        #10 check_signals("SLTU", 1, 2'b00, 0, 0, 4'b0011, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 6: XOR
        OpCode = 7'b0110011; Funct3 = 3'b100; Funct7 = 7'b0000000;
        #10 check_signals("XOR", 1, 2'b00, 0, 0, 4'b0100, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 7: SRL
        OpCode = 7'b0110011; Funct3 = 3'b101; Funct7 = 7'b0000000;
        #10 check_signals("SRL", 1, 2'b00, 0, 0, 4'b0101, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 8: SRA
        OpCode = 7'b0110011; Funct3 = 3'b101; Funct7 = 7'b0100000;
        #10 check_signals("SRA", 1, 2'b00, 0, 0, 4'b1101, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 9: OR
        OpCode = 7'b0110011; Funct3 = 3'b110; Funct7 = 7'b0000000;
        #10 check_signals("OR", 1, 2'b00, 0, 0, 4'b0110, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 10: AND
        OpCode = 7'b0110011; Funct3 = 3'b111; Funct7 = 7'b0000000;
        #10 check_signals("AND", 1, 2'b00, 0, 0, 4'b0111, 0, 3'b000, 3'b000, 5'b00000);
        
        // ==================== I-TYPE INSTRUCTIONS ====================
        $display("\n--- I-TYPE INSTRUCTIONS ---\n");
        
        // Test 11: ADDI
        OpCode = 7'b0010011; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("ADDI", 1, 2'b00, 0, 1, 4'b0000, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 12: SLLI
        OpCode = 7'b0010011; Funct3 = 3'b001; Funct7 = 7'b0000000;
        #10 check_signals("SLLI", 1, 2'b00, 0, 1, 4'b0001, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 13: SLTI
        OpCode = 7'b0010011; Funct3 = 3'b010; Funct7 = 7'b0000000;
        #10 check_signals("SLTI", 1, 2'b00, 0, 1, 4'b0010, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 14: SLTIU
        OpCode = 7'b0010011; Funct3 = 3'b011; Funct7 = 7'b0000000;
        #10 check_signals("SLTIU", 1, 2'b00, 0, 1, 4'b0011, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 15: XORI
        OpCode = 7'b0010011; Funct3 = 3'b100; Funct7 = 7'b0000000;
        #10 check_signals("XORI", 1, 2'b00, 0, 1, 4'b0100, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 16: SRLI
        OpCode = 7'b0010011; Funct3 = 3'b101; Funct7 = 7'b0000000;
        #10 check_signals("SRLI", 1, 2'b00, 0, 1, 4'b0101, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 17: SRAI (nota: tu implementacion actual no distingue SRAI de SRLI)
        OpCode = 7'b0010011; Funct3 = 3'b101; Funct7 = 7'b0100000;
        #10 check_signals("SRAI", 1, 2'b00, 0, 1, 4'b0101, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 18: ORI
        OpCode = 7'b0010011; Funct3 = 3'b110; Funct7 = 7'b0000000;
        #10 check_signals("ORI", 1, 2'b00, 0, 1, 4'b0110, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 19: ANDI
        OpCode = 7'b0010011; Funct3 = 3'b111; Funct7 = 7'b0000000;
        #10 check_signals("ANDI", 1, 2'b00, 0, 1, 4'b0111, 0, 3'b000, 3'b000, 5'b00000);
        
        // ==================== LOAD INSTRUCTIONS ====================
        $display("\n--- LOAD INSTRUCTIONS ---\n");
        
        // Test 20: LB
        OpCode = 7'b0000011; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("LB", 1, 2'b01, 0, 1, 4'b0000, 0, 3'b000, 3'b000, 5'b00000);
        
        // Test 21: LH
        OpCode = 7'b0000011; Funct3 = 3'b001; Funct7 = 7'b0000000;
        #10 check_signals("LH", 1, 2'b01, 0, 1, 4'b0000, 0, 3'b001, 3'b000, 5'b00000);
        
        // Test 22: LW
        OpCode = 7'b0000011; Funct3 = 3'b010; Funct7 = 7'b0000000;
        #10 check_signals("LW", 1, 2'b01, 0, 1, 4'b0000, 0, 3'b010, 3'b000, 5'b00000);
        
        // Test 23: LBU
        OpCode = 7'b0000011; Funct3 = 3'b100; Funct7 = 7'b0000000;
        #10 check_signals("LBU", 1, 2'b01, 0, 1, 4'b0000, 0, 3'b100, 3'b000, 5'b00000);
        
        // Test 24: LHU
        OpCode = 7'b0000011; Funct3 = 3'b101; Funct7 = 7'b0000000;
        #10 check_signals("LHU", 1, 2'b01, 0, 1, 4'b0000, 0, 3'b101, 3'b000, 5'b00000);
        
        // ==================== STORE INSTRUCTIONS ====================
        $display("\n--- STORE INSTRUCTIONS ---\n");
        
        // Test 25: SB
        OpCode = 7'b0100011; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("SB", 0, 2'b00, 0, 1, 4'b0000, 1, 3'b000, 3'b001, 5'b00000);
        
        // Test 26: SH
        OpCode = 7'b0100011; Funct3 = 3'b001; Funct7 = 7'b0000000;
        #10 check_signals("SH", 0, 2'b00, 0, 1, 4'b0000, 1, 3'b001, 3'b001, 5'b00000);
        
        // Test 27: SW
        OpCode = 7'b0100011; Funct3 = 3'b010; Funct7 = 7'b0000000;
        #10 check_signals("SW", 0, 2'b00, 0, 1, 4'b0000, 1, 3'b010, 3'b001, 5'b00000);
        
        // ==================== BRANCH INSTRUCTIONS ====================
        $display("\n--- BRANCH INSTRUCTIONS ---\n");
        
        // Test 28: BEQ
        OpCode = 7'b1100011; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("BEQ", 0, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b101, 5'b01000);
        
        // Test 29: BNE
        OpCode = 7'b1100011; Funct3 = 3'b001; Funct7 = 7'b0000000;
        #10 check_signals("BNE", 0, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b101, 5'b01001);
        
        // Test 30: BLT
        OpCode = 7'b1100011; Funct3 = 3'b100; Funct7 = 7'b0000000;
        #10 check_signals("BLT", 0, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b101, 5'b01100);
        
        // Test 31: BGE
        OpCode = 7'b1100011; Funct3 = 3'b101; Funct7 = 7'b0000000;
        #10 check_signals("BGE", 0, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b101, 5'b01101);
        
        // Test 32: BLTU
        OpCode = 7'b1100011; Funct3 = 3'b110; Funct7 = 7'b0000000;
        #10 check_signals("BLTU", 0, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b101, 5'b01110);
        
        // Test 33: BGEU
        OpCode = 7'b1100011; Funct3 = 3'b111; Funct7 = 7'b0000000;
        #10 check_signals("BGEU", 0, 2'b00, 0, 0, 4'b0000, 0, 3'b000, 3'b101, 5'b01111);
        
        // ==================== JUMP INSTRUCTIONS ====================
        $display("\n--- JUMP INSTRUCTIONS ---\n");
        
        // Test 34: JAL
        OpCode = 7'b1101111; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("JAL", 1, 2'b10, 0, 0, 4'b0000, 0, 3'b000, 3'b110, 5'b10000);
        
        // Test 35: JALR
        OpCode = 7'b1100111; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("JALR", 1, 2'b10, 0, 0, 4'b0000, 0, 3'b000, 3'b000, 5'b10000);
        
        // ==================== UPPER IMMEDIATE INSTRUCTIONS ====================
        $display("\n--- UPPER IMMEDIATE INSTRUCTIONS ---\n");
        
        // Test 36: LUI
        OpCode = 7'b0110111; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("LUI", 1, 2'b11, 0, 0, 4'b0000, 0, 3'b000, 3'b010, 5'b00000);
        
        // Test 37: AUIPC
        OpCode = 7'b0010111; Funct3 = 3'b000; Funct7 = 7'b0000000;
        #10 check_signals("AUIPC", 1, 2'b00, 1, 1, 4'b0000, 0, 3'b000, 3'b010, 5'b00000);
        
        // ==================== RESUMEN ====================
        $display("\n========================================");
        $display("  TEST SUMMARY");
        $display("========================================");
        $display("Total tests: %0d", tests);
        $display("Passed:      %0d", tests - errors);
        $display("Failed:      %0d", errors);
        
        if (errors == 0) begin
            $display("\nALL TESTS PASSED");
        end else begin
            $display("\nSOME TESTS FAILED");
        end
        $display("========================================\n");
        
        $finish;
    end

endmodule
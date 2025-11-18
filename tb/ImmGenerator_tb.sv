`timescale 1ns/1ps

module ImmGenerator_tb;

    // Señales del testbench
    logic signed [2:0] ImmSrc;
    logic signed [31:0] instruction;
    logic signed [31:0] Imm_ext;
    
    // Instancia del módulo bajo prueba
    ImmGenerator uut (
        .ImmSrc(ImmSrc),
        .instruction(instruction),
        .Imm_ext(Imm_ext)
    );
    
    // Variables para verificación
    logic signed [31:0] expected;
    integer errors = 0;
    integer tests = 0;
    
    // Task para verificar resultado
    task check_result(input string test_name, input logic signed [31:0] exp);
        tests++;
        #1; // Pequeño delay para estabilización
        if (Imm_ext !== exp) begin
            $display("   ERROR: %s", test_name);
            $display("   ImmSrc:      0x%h (%03b)", ImmSrc, ImmSrc);
            $display("   Instruction: 0x%h", instruction);
            $display("   Expected:    0x%h (%0d)", exp, exp);
            $display("   Got:         0x%h (%0d)", Imm_ext, Imm_ext);
            errors++;
        end else begin
            $display("   PASS: %s", test_name);
            $display("   ImmSrc: %03b, Imm_ext = 0x%h (%0d)", ImmSrc, Imm_ext, Imm_ext);
        end
        $display("");
    endtask
    
    initial begin
        $display("\n========================================");
        $display("  ImmGenerator Testbench");
        $display("========================================\n");
        
        // ==================== I-TYPE TESTS ====================
        // Test 1: I-type positivo (ADDI x1, x2, 100)
        // imm[11:0] = 100 = 0x064 = 0b000001100100
        ImmSrc = 3'b000;
        instruction = 32'b000001100100_00010_000_00001_0010011;
        expected = 32'd100;
        #10 check_result("Test 1: I-type positive (imm=100)", expected);
        
        // Test 2: I-type negativo (LW x7, -12(x8))
        // imm[11:0] = -12 = 0xFF4 = 0b111111110100
        ImmSrc = 3'b000;
        instruction = 32'b111111110100_01000_010_00111_0000011;
        expected = -32'd12;
        #10 check_result("Test 2: I-type negative (imm=-12)", expected);
        
        // ==================== S-TYPE TESTS ====================
        // Test 3: S-type positivo (SW x11, 20(x12))
        // imm[11:5] = 0b0000000, imm[4:0] = 0b10100 -> total = 20 = 0x14
        ImmSrc = 3'b001;
        instruction = 32'b0000000_01011_01100_010_10100_0100011;
        expected = 32'd20;
        #10 check_result("Test 3: S-type positive (imm=20)", expected);
        
        // Test 4: S-type negativo (SW x13, -8(x14))
        // imm[11:5] = 0b1111111, imm[4:0] = 0b11000 -> total = -8
        ImmSrc = 3'b001;
        instruction = 32'b1111111_01101_01110_010_11000_0100011;
        expected = -32'd8;
        #10 check_result("Test 4: S-type negative (imm=-8)", expected);
        
        // ==================== B-TYPE TESTS ====================
        // Test 5: B-type positivo (BEQ offset = 8)
        // 8 = 0b0_0_000000_0100_0 -> imm[12]=0, imm[11]=0, imm[10:5]=000000, imm[4:1]=0100
        ImmSrc = 3'b101;
        instruction = 32'b0_000000_10010_10001_000_0100_0_1100011;
        expected = 32'd8;
        #10 check_result("Test 5: B-type positive (imm=8)", expected);
        
        // Test 6: B-type negativo (BNE offset = -16)
        // -16 = 0b1_1111_1111_0000 (13 bits) -> imm[12]=1, imm[11]=1, imm[10:5]=111111, imm[4:1]=1000
        ImmSrc = 3'b101;
        instruction = 32'b1_111111_10100_10011_001_1000_1_1100011;
        expected = -32'd16;
        #10 check_result("Test 6: B-type negative (imm=-16)", expected);
        
        // ==================== J-TYPE TESTS ====================
        // Test 7: J-type positivo (JAL offset = 20)
        // 20 = 0b0_00000000_0_0000001010_0 -> imm[20]=0, imm[19:12]=00000000, imm[11]=0, imm[10:1]=0000001010
        ImmSrc = 3'b110;
        instruction = 32'b0_0000001010_0_00000000_00001_1101111;
        expected = 32'd20;
        #10 check_result("Test 7: J-type positive (imm=20)", expected);
        
        // Test 8: J-type negativo (JAL offset = -8)
        // -8 = 0b1_11111111_1_1111111100_0 -> imm[20]=1, imm[19:12]=11111111, imm[11]=1, imm[10:1]=1111111100
        ImmSrc = 3'b110;
        instruction = 32'b1_1111111100_1_11111111_00001_1101111;
        expected = -32'd8;
        #10 check_result("Test 8: J-type negative (imm=-8)", expected);
        
        // ==================== RESUMEN ====================
        $display("========================================");
        $display("  TEST SUMMARY");
        $display("========================================");
        $display("Total tests: %0d", tests);
        $display("Passed:      %0d", tests - errors);
        $display("Failed:      %0d", errors);
        
        if (errors == 0) begin
            $display("\n ALL TESTS PASSED!");
        end else begin
            $display("\n  SOME TESTS FAILED ");
        end
        $display("========================================\n");
        
        $finish;
    end

endmodule
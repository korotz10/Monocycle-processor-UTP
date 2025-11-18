`timescale 1ns/1ps

module BranchUnit_tb;

    // Señales del testbench
    logic [4:0] BrOp;
    logic signed [31:0] A;
    logic signed [31:0] B;
    logic NextPCSrc;
    
    // Instancia del módulo bajo prueba
    BranchUnit uut (
        .BrOp(BrOp),
        .A(A),
        .B(B),
        .NextPCSrc(NextPCSrc)
    );
    
    // Variables para verificación
    logic expected;
    integer errors = 0;
    integer tests = 0;

    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/BranchUnit_tb.vcd");
        $dumpvars(0, BranchUnit_tb);
    end
    
    // Task para verificar resultado
    task check_result(input string test_name, input logic exp);
        tests++;
        #1;
        if (NextPCSrc !== exp) begin
            $display("ERROR: %s", test_name);
            $display("   BrOp:     0x%h (%05b)", BrOp, BrOp);
            $display("   A:        0x%h (%0d)", A, A);
            $display("   B:        0x%h (%0d)", B, B);
            $display("   Expected: %0b", exp);
            $display("   Got:      %0b", NextPCSrc);
            errors++;
        end else begin
            $display("PASS: %s", test_name);
            $display("   BrOp: %05b, A = %0d, B = %0d, NextPCSrc = %0b", BrOp, A, B, NextPCSrc);
        end
        $display("");
    endtask
    
    initial begin
        $display("\n========================================");
        $display("  BranchUnit Testbench");
        $display("========================================\n");
        
        // Test 1: NO BRANCH (BrOp = 0_0XXX)
        BrOp = 5'b00000;
        A = 32'd10;
        B = 32'd10;
        expected = 1'b0;
        #10 check_result("Test 1: NO BRANCH", expected);
        
        // Test 2: BEQ - Branch if Equal (A == B)
        BrOp = 5'b01000;
        A = 32'd15;
        B = 32'd15;
        expected = 1'b1;
        #10 check_result("Test 2: BEQ - Equal values (should branch)", expected);
        
        // Test 3: BNE - Branch if Not Equal (A != B)
        BrOp = 5'b01001;
        A = 32'd20;
        B = 32'd25;
        expected = 1'b1;
        #10 check_result("Test 3: BNE - Different values (should branch)", expected);
        
        // Test 4: BLT - Branch if Less Than signed (A < B)
        BrOp = 5'b01100;
        A = -32'd10;
        B = 32'd5;
        expected = 1'b1;
        #10 check_result("Test 4: BLT - Negative < Positive (should branch)", expected);
        
        // Test 5: BGE - Branch if Greater or Equal signed (A >= B)
        BrOp = 5'b01101;
        A = 32'd30;
        B = 32'd30;
        expected = 1'b1;
        #10 check_result("Test 5: BGE - Equal values (should branch)", expected);
        
        // Test 6: BLTU - Branch if Less Than unsigned (A < B)
        BrOp = 5'b01110;
        A = 32'hFFFFFFFF; // -1 signed, pero 4294967295 unsigned
        B = 32'd100;
        expected = 1'b0; // unsigned: 4294967295 > 100, no branch
        #10 check_result("Test 6: BLTU - Unsigned comparison (should NOT branch)", expected);
        
        // Test 7: BGEU - Branch if Greater or Equal unsigned (A >= B)
        BrOp = 5'b01111;
        A = 32'd50;
        B = 32'd25;
        expected = 1'b1;
        #10 check_result("Test 7: BGEU - A >= B unsigned (should branch)", expected);
        
        // Test 8: JAL/JALR - Unconditional jump
        BrOp = 5'b10000;
        A = 32'd0;
        B = 32'd0;
        expected = 1'b1;
        #10 check_result("Test 8: JAL/JALR - Unconditional jump (should branch)", expected);
        
        // ==================== RESUMEN ====================
        $display("========================================");
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
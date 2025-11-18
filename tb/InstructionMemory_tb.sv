`timescale 1ns/1ps

module InstructionMemory_tb;

    // Señales del testbench
    logic [31:0] address;
    logic [31:0] instruction;
    
    // Instancia del módulo bajo prueba
    InstructionMemory uut (
        .address(address),
        .instruction(instruction)
    );
    
    // Variables para verificación
    logic [31:0] expected;
    integer errors = 0;
    integer tests = 0;

    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/InstructionMemory_tb.vcd");
        $dumpvars(0, InstructionMemory_tb);
    end
    
    // Task para verificar resultado
    task check_result(input string test_name, input logic [31:0] exp);
        tests++;
        #1; // Pequeño delay para estabilización
        if (instruction !== exp) begin
            $display("   ERROR: %s", test_name);
            $display("   Address:     0x%h (PC = %0d)", address, address);
            $display("   Expected:    0x%h", exp);
            $display("   Got:         0x%h", instruction);
            errors++;
        end else begin
            $display("   PASS: %s", test_name);
            $display("   Address: 0x%h, Instruction = 0x%h", address, instruction);
        end
        $display("");
    endtask
    
    initial begin
        $display("\n========================================");
        $display("  InstructionMemory Testbench");
        $display("========================================\n");
        
        // Esperar a que se cargue la memoria
        #10;
        
        // ==================== PRUEBAS DE LECTURA ====================
        
        // Test 1: Leer primera instrucción (address = 0x00000000)
        address = 32'h00000000;
        expected = 32'h00500093; // ADDI x1, x0, 5
        #10 check_result("Test 1: Read address 0x00000000 (PC=0)", expected);
        
        // Test 2: Leer segunda instrucción (address = 0x00000004)
        address = 32'h00000004;
        expected = 32'h00a00113; // ADDI x2, x0, 10
        #10 check_result("Test 2: Read address 0x00000004 (PC=4)", expected);
        
        // Test 3: Leer tercera instrucción (address = 0x00000008)
        address = 32'h00000008;
        expected = 32'h002081b3; // ADD x3, x1, x2
        #10 check_result("Test 3: Read address 0x00000008 (PC=8)", expected);
        
        // Test 4: Leer cuarta instrucción (address = 0x0000000C)
        address = 32'h0000000C;
        expected = 32'h40208233; // SUB x4, x1, x2
        #10 check_result("Test 4: Read address 0x0000000C (PC=12)", expected);
        
        // Test 5: Leer quinta instrucción (address = 0x00000010)
        address = 32'h00000010;
        expected = 32'h002092b3; // SLL x5, x1, x2
        #10 check_result("Test 5: Read address 0x00000010 (PC=16)", expected);
        
        // Test 6: Leer en dirección más alta (address = 0x00000020)
        address = 32'h00000020;
        expected = 32'h0020a333; // SLT x6, x1, x2
        #10 check_result("Test 6: Read address 0x00000020 (PC=32)", expected);
        
        // Test 7: Verificar alineación - bits bajos ignorados
        // address = 0x00000007 debería leer la misma instrucción que 0x00000004
        address = 32'h00000007;
        expected = 32'h00a00113; // Misma que PC=4
        #10 check_result("Test 7: Alignment test - address 0x07 reads PC=4", expected);
        
        // Test 8: Otra prueba de alineación
        // address = 0x0000000B debería leer la misma instrucción que 0x00000008
        address = 32'h0000000B;
        expected = 32'h002081b3; // Misma que PC=8
        #10 check_result("Test 8: Alignment test - address 0x0B reads PC=8", expected);
        
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
            $display("\nSOME TESTS FAILED");
        end
        $display("========================================\n");
        
        $finish;
    end

endmodule
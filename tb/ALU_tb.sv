module ALU_tb;
    // Señales del testbench
    logic signed [31:0] A;
    logic signed [31:0] B;
    logic [3:0] ALUOp;
    logic signed [31:0] ALURes;
    
    // Instanciar el DUT (Device Under Test)
    ALU dut (
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .ALURes(ALURes)
    );
    
    // Variables para verificación
    logic signed [31:0] expected;
    integer errors = 0;
    integer tests = 0;
    
    // Tarea para verificar resultados
    task check_result(input logic signed [31:0] exp, input string operation);
        tests++;
        if (ALURes !== exp) begin
            $display("ERROR en %s: A=%0d, B=%0d, Esperado=%0d, Obtenido=%0d", 
                     operation, A, B, exp, ALURes);
            errors++;
        end else begin
            $display("OK: %s - A=%0d, B=%0d, Resultado=%0d", operation, A, B, ALURes);
        end
    endtask

    // Inicialización de la simulación - Wavetrace
    initial begin
        $dumpfile("sim/ALU_tb.vcd");    
        $dumpvars(0, ALU_tb);   
    end
    
    initial begin

        $display("=== Iniciando simulación del ALU ===\n");
        
        // Test 1: ADD (0000)
        $display("========== Test ADD (0000) ==========");
        ALUOp = 4'b0000;
        A = 32'h0000000F; B = 32'h0000000A; #10;  // 15 + 10
        check_result(32'h00000019, "ADD: 15 + 10");
        
        A = 32'hFFFFFFF1; B = 32'h0000000A; #10;  // -15 + 10
        check_result(32'hFFFFFFFB, "ADD: -15 + 10");
        
        // Test 2: SUB (1000)
        $display("========== Test SUB (1000) ==========");
        ALUOp = 4'b1000;
        A = 32'h00000014; B = 32'h00000005; #10;  // 20 - 5
        check_result(32'h0000000F, "SUB: 20 - 5");
        
        A = 32'h00000005; B = 32'h00000014; #10;  // 5 - 20
        check_result(32'hFFFFFFF1, "SUB: 5 - 20");
        
        // Test 3: SLL - Shift Left Logical (0001)
        $display("========== Test SLL (0001) - Desplazamiento a la izquierda ==========");
        ALUOp = 4'b0001;
        A = 32'h00000004; B = 32'h00000002; #10;  // 0100 << 2 = 10000
        check_result(32'h00000010, "SLL: 4 << 2");
        
        A = 32'h00000001; B = 32'h00000003; #10;  // 0001 << 3 = 1000
        check_result(32'h00000008, "SLL: 1 << 3");
        
        // Test 4: SLT - Set Less Than (0010)
        $display("========== Test SLT (0010) - Comparación con signo ==========");
        ALUOp = 4'b0010;
        A = 32'h00000005; B = 32'h0000000A; #10;  // 5 < 10 = 1
        check_result(32'h00000001, "SLT: 5 < 10");
        
        A = 32'h0000000A; B = 32'h00000005; #10;  // 10 < 5 = 0
        check_result(32'h00000000, "SLT: 10 < 5");
        
        A = 32'hFFFFFFFB; B = 32'h00000005; #10;  // -5 < 5 = 1
        check_result(32'h00000001, "SLT: -5 < 5");
        
        // Test 5: SLTU - Set Less Than Unsigned (0011)
        $display("========== Test SLTU (0011) - Comparación sin signo ==========");
        ALUOp = 4'b0011;
        A = 32'h00000005; B = 32'h0000000A; #10;  // 5 < 10 = 1
        check_result(32'h00000001, "SLTU: 5 < 10");
        
        A = 32'hFFFFFFFF; B = 32'h0000000A; #10;  // -1 (como unsigned es muy grande) < 10 = 0
        check_result(32'h00000000, "SLTU: 0xFFFFFFFF < 10 (unsigned)");
        
        // Test 6: XOR (0100)
        $display("========== Test XOR (0100) - OR exclusivo ==========");
        ALUOp = 4'b0100;
        A = 32'hAAAAAAAA; B = 32'h55555555; #10;  // Patrón alternado
        check_result(32'hFFFFFFFF, "XOR: 0xAAAAAAAA ^ 0x55555555");
        
        A = 32'hF0F0F0F0; B = 32'h0F0F0F0F; #10;
        check_result(32'hFFFFFFFF, "XOR: 0xF0F0F0F0 ^ 0x0F0F0F0F");
        
        // Test 7: SRL - Shift Right Logical (0101)
        $display("========== Test SRL (0101) - Desplazamiento lógico a la derecha ==========");
        ALUOp = 4'b0101;
        A = 32'h00000010; B = 32'h00000002; #10;  // 16 >> 2 = 4
        check_result(32'h00000004, "SRL: 16 >> 2");
        
        A = 32'hFFFFFFFF; B = 32'h00000004; #10;  // Rellena con 0s
        check_result(32'h0FFFFFFF, "SRL: 0xFFFFFFFF >> 4 (lógico)");
        
        // Test 8: SRA - Shift Right Arithmetic (1101)
        $display("========== Test SRA (1101) - Desplazamiento aritmético a la derecha ==========");
        ALUOp = 4'b1101;
        A = 32'h00000010; B = 32'h00000002; #10;  // 16 >> 2 = 4
        check_result(32'h00000004, "SRA: 16 >> 2 (positivo)");
        
        A = 32'hFFFFFFF0; B = 32'h00000002; #10;  // -16 >> 2 = -4 (mantiene signo)
        check_result(32'hFFFFFFFC, "SRA: -16 >> 2 (negativo, mantiene signo)");
        
        // Test 9: OR (0110)
        $display("========== Test OR (0110) - OR bit a bit ==========");
        ALUOp = 4'b0110;
        A = 32'hAAAAAAAA; B = 32'h55555555; #10;
        check_result(32'hFFFFFFFF, "OR: 0xAAAAAAAA | 0x55555555");
        
        A = 32'hF0000000; B = 32'h0000000F; #10;
        check_result(32'hF000000F, "OR: 0xF0000000 | 0x0000000F");
        
        // Test 10: AND (0111)
        $display("========== Test AND (0111) - AND bit a bit ==========");
        ALUOp = 4'b0111;
        A = 32'hFFFFFFFF; B = 32'h55555555; #10;
        check_result(32'h55555555, "AND: 0xFFFFFFFF & 0x55555555");
        
        A = 32'hF0F0F0F0; B = 32'hFFFF0000; #10;
        check_result(32'hF0F00000, "AND: 0xF0F0F0F0 & 0xFFFF0000");
        
        // Test 11: Pass B (1001)
        $display("========== Test Pass B (1001) - Pasar valor de B ==========");
        ALUOp = 4'b1001;
        A = 32'h00000064; B = 32'h00000032; #10;  // 100, 50
        check_result(32'h00000032, "Pass B: Resultado = B (50)");
        
        A = 32'h00000000; B = 32'hFFFFFFE7; #10;  // 0, -25
        check_result(32'hFFFFFFE7, "Pass B: Resultado = B (-25)");
        
        // Resumen
        $display("\n=== Resumen de la simulación ===");
        $display("Tests ejecutados: %0d", tests);
        $display("Tests exitosos: %0d", tests - errors);
        $display("Errores: %0d", errors);
        
        if (errors == 0)
            $display("\n¡Todos los tests pasaron exitosamente!");
        else
            $display("\n¡Atención! Se encontraron %0d errores.", errors);
        
        $finish;
    end
    
endmodule
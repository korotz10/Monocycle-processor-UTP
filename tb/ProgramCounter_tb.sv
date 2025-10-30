module ProgramCounter_tb;
    // Señales del testbench
    logic clk;
    logic PCWr;
    logic signed [31:0] PCIn;
    logic signed [31:0] PCOut;
    
    // Instanciar el DUT
    ProgramCounter dut (
        .clk(clk),
        .PCWr(PCWr),
        .PCIn(PCIn),
        .PCOut(PCOut)
    );
    
    // Generador de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo de 10 unidades de tiempo
    end
    
    // Variables para verificación
    integer errors = 0;
    integer tests = 0;
    
    // Inicialización para wavetrace
    initial begin
        $dumpfile("sim/ProgramCounter_tb.vcd");
        $dumpvars(0, ProgramCounter_tb);
    end
    
    // Tarea para escribir en el PC
    task write_pc(input [31:0] value);
        @(posedge clk);
        PCIn = value;
        PCWr = 1;
        @(posedge clk);
        #1; // Pequeño delay para que se actualice
    endtask
    
    // Tarea para verificar el valor del PC
    task check_pc(input [31:0] expected, input string test_name);
        tests++;
        $display("Test: %s", test_name);
        $display("  Esperado = 0x%h (%b)", expected, expected);
        $display("  Obtenido = 0x%h (%b)", PCOut, PCOut);
        if (PCOut !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        // Inicialización
        PCWr = 0;
        PCIn = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion ProgramCounter ===");
        $display("========================================\n");
        
        // Esperar unos ciclos
        repeat(2) @(posedge clk);
        
        // Test 1: Verificar inicialización
        $display("========== Test 1: Verificar inicializacion ==========");
        check_pc(32'h00000000, "PC inicial debe ser 0");
        
        // Test 2: Escribir primera dirección
        $display("========== Test 2: Escribir primera direccion ==========");
        write_pc(32'h00000004);
        PCWr = 0;
        check_pc(32'h00000004, "PC = 0x00000004");
        
        // Test 3: Incremento típico de PC (siguiente instrucción)
        $display("========== Test 3: Incremento tipico PC +4 ==========");
        write_pc(32'h00000008);
        PCWr = 0;
        check_pc(32'h00000008, "PC = 0x00000008");
        
        write_pc(32'h0000000C);
        PCWr = 0;
        check_pc(32'h0000000C, "PC = 0x0000000C");
        
        // Test 4: PC no debe cambiar sin PCWr
        $display("========== Test 4: PC no cambia sin PCWr ==========");
        @(posedge clk);
        PCIn = 32'hDEADBEEF;
        PCWr = 0; // No activado
        @(posedge clk);
        #1;
        check_pc(32'h0000000C, "PC debe mantener valor anterior");
        
        // Test 5: Salto a dirección arbitraria
        $display("========== Test 5: Salto a direccion arbitraria ==========");
        write_pc(32'h00001000);
        PCWr = 0;
        check_pc(32'h00001000, "PC = 0x00001000");
        
        // Test 6: Salto hacia atrás (negativo)
        $display("========== Test 6: Salto hacia atras ==========");
        write_pc(32'h00000100);
        PCWr = 0;
        check_pc(32'h00000100, "PC = 0x00000100");
        
        // Test 7: Mantener PC durante varios ciclos
        $display("========== Test 7: Mantener PC sin cambios ==========");
        PCWr = 0;
        repeat(5) @(posedge clk);
        #1;
        check_pc(32'h00000100, "PC debe mantenerse en 0x00000100");
        
        // Test 8: Secuencia de saltos rápidos
        $display("========== Test 8: Secuencia de saltos rapidos ==========");
        write_pc(32'h00002000);
        PCWr = 0;
        check_pc(32'h00002000, "PC = 0x00002000");
        
        write_pc(32'h00003000);
        PCWr = 0;
        check_pc(32'h00003000, "PC = 0x00003000");
        
        write_pc(32'h00004000);
        PCWr = 0;
        check_pc(32'h00004000, "PC = 0x00004000");
        
        // Test 9: Escribir con PCWr mantenido activo
        $display("========== Test 9: PCWr mantenido activo ==========");
        @(posedge clk);
        PCIn = 32'h00005000;
        PCWr = 1;
        @(posedge clk);
        PCIn = 32'h00006000;
        // PCWr sigue activo
        @(posedge clk);
        #1;
        PCWr = 0;
        check_pc(32'h00006000, "PC debe actualizar a ultimo valor");
        
        // Test 10: Reset a dirección 0
        $display("========== Test 10: Reset a direccion 0 ==========");
        write_pc(32'h00000000);
        PCWr = 0;
        check_pc(32'h00000000, "PC = 0x00000000");
        
        // Test 11: Valores grandes
        $display("========== Test 11: Valores grandes ==========");
        write_pc(32'hFFFFFFFC);
        PCWr = 0;
        check_pc(32'hFFFFFFFC, "PC = 0xFFFFFFFC");
        
        // Test 12: Simulación de bucle (PC cambia múltiples veces)
        $display("========== Test 12: Simulacion de bucle ==========");
        write_pc(32'h00000200);
        PCWr = 0;
        check_pc(32'h00000200, "PC = 0x00000200");
        
        write_pc(32'h00000204);
        PCWr = 0;
        check_pc(32'h00000204, "PC = 0x00000204");
        
        write_pc(32'h00000208);
        PCWr = 0;
        check_pc(32'h00000208, "PC = 0x00000208");
        
        write_pc(32'h00000200); // Volver al inicio del bucle
        PCWr = 0;
        check_pc(32'h00000200, "PC = 0x00000200 (vuelta al inicio)");
        
        // Resumen final
        $display("========================================");
        $display("=== Resumen de la simulacion ===");
        $display("Tests ejecutados: %0d", tests);
        $display("Tests exitosos: %0d", tests - errors);
        $display("Errores: %0d", errors);
        $display("========================================");
        
        if (errors == 0)
            $display("Todos los tests pasaron exitosamente");
        else
            $display("Se encontraron %0d errores", errors);
        
        // Finalizar simulación
        repeat(3) @(posedge clk);
        $finish;
    end
    
endmodule
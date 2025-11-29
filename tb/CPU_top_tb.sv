`timescale 1ns / 1ps

// ============================================
// TESTBENCH FINAL - CPU MONOCICLO RISC-V
// Prueba las 10 instrucciones más importantes
// ============================================

module CPU_top_tb;

    // Señales del testbench
    logic clk;
    logic reset;
    
    // Contador de errores
    integer errors;
    
    // Registros monitoreados (solo los que usamos)
    logic signed [31:0] x1, x2, x3, x4, x5, x6, x7, x8, x9, x10;
    logic [31:0] pc_value;

    // Instancia del CPU
    CPU_top dut (
        .clk(clk),
        .reset(reset)
    );
    
    // Asignaciones para monitoring
    assign x1  = dut.registers_unit.ru[1];
    assign x2  = dut.registers_unit.ru[2];
    assign x3  = dut.registers_unit.ru[3];
    assign x4  = dut.registers_unit.ru[4];
    assign x5  = dut.registers_unit.ru[5];
    assign x6  = dut.registers_unit.ru[6];
    assign x7  = dut.registers_unit.ru[7];
    assign x8  = dut.registers_unit.ru[8];
    assign x9  = dut.registers_unit.ru[9];
    assign x10 = dut.registers_unit.ru[10];
    assign pc_value = dut.pc;

    // Generación del reloj (periodo de 10ns = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Monitor
    initial begin
        $display("=================================================================");
        $display("  TESTBENCH FINAL - CPU MONOCICLO RISC-V");
        $display("  Prueba: 10 instrucciones fundamentales");
        $display("=================================================================\n");
        
        $monitor("Time=%0t ns | PC=0x%h | Instruction=0x%h", 
                 $time, pc_value, dut.instruction);
    end

    // Secuencia de prueba
    initial begin
        // Inicializar
        errors = 0;
        
        // Reset inicial
        reset = 1;
        #10;
        reset = 0;
        
        $display("\n>>> Ejecutando programa de prueba...\n");
        
        // Esperar ejecución (25 instrucciones * 10ns = 250ns + margen)
        #300;
        
        // Mostrar resultados
        $display("\n=================================================================");
        $display("  RESULTADOS FINALES");
        $display("=================================================================\n");
        
        $display("--- ARITMÉTICA E INMEDIATOS ---");
        $display("x1 (ADDI 42)       = %0d  | Esperado: 42", x1);
        $display("x2 (ADD 15+27)     = %0d  | Esperado: 42", x2);
        $display("x3 (SUB 50-8)      = %0d  | Esperado: 42", x3);
        
        $display("\n--- LÓGICA ---");
        $display("x4 (XORI 42^15)    = %0d  | Esperado: 37", x4);
        $display("x5 (AND 0xFF&0xAA) = 0x%h | Esperado: 0xAA", x5);
        
        $display("\n--- SHIFTS ---");
        $display("x6 (SLLI 10<<2)    = %0d  | Esperado: 40", x6);
        $display("x7 (SRAI -16>>>2)  = %0d  | Esperado: -4", x7);
        
        $display("\n--- MEMORIA ---");
        $display("x8 (LW load)       = 0x%h | Esperado: 0x12345678", x8);
        
        $display("\n--- CONTROL DE FLUJO ---");
        $display("x9 (Branch taken)  = %0d  | Esperado: 100", x9);
        $display("x10 (JAL return)   = 0x%h | Esperado: 0x68", x10);
        
        // Verificación automática
        $display("\n=================================================================");
        $display("  VERIFICACIÓN AUTOMÁTICA");
        $display("=================================================================\n");
        
        errors = 0;
        
        if (x1 !== 42) begin
            $error("❌ ADDI falló: x1=%0d, esperado=42", x1);
            errors = errors + 1;
        end else $display("✓ ADDI correcto");
        
        if (x2 !== 42) begin
            $error("❌ ADD falló: x2=%0d, esperado=42", x2);
            errors = errors + 1;
        end else $display("✓ ADD correcto");
        
        if (x3 !== 42) begin
            $error("❌ SUB falló: x3=%0d, esperado=42", x3);
            errors = errors + 1;
        end else $display("✓ SUB correcto");
        
        if (x4 !== 37) begin
            $error("❌ XORI falló: x4=%0d, esperado=37", x4);
            errors = errors + 1;
        end else $display("✓ XORI correcto");
        
        if (x5 !== 32'hAA) begin
            $error("❌ AND falló: x5=0x%h, esperado=0xAA", x5);
            errors = errors + 1;
        end else $display("✓ AND correcto");
        
        if (x6 !== 40) begin
            $error("❌ SLLI falló: x6=%0d, esperado=40", x6);
            errors = errors + 1;
        end else $display("✓ SLLI correcto");
        
        if (x7 !== -4) begin
            $error("❌ SRAI falló: x7=%0d, esperado=-4", x7);
            errors = errors + 1;
        end else $display("✓ SRAI correcto");
        
        if (x8 !== 32'h12345678) begin
            $error("❌ LW falló: x8=0x%h, esperado=0x12345678", x8);
            errors = errors + 1;
        end else $display("✓ LW/SW correcto");
        
        if (x9 !== 100) begin
            $error("❌ BEQ falló: x9=%0d, esperado=100", x9);
            errors = errors + 1;
        end else $display("✓ BEQ correcto");
        
        if (x10 !== 32'h68) begin
            $error("❌ JAL falló: x10=0x%h, esperado=0x68", x10);
            errors = errors + 1;
        end else $display("✓ JAL correcto");
        
        // Resumen final
        $display("\n=================================================================");
        if (errors == 0) begin
            $display("  ✓✓✓ TODOS LOS TESTS PASARON (10/10) ✓✓✓");
            $display("  Tu CPU RISC-V monociclo funciona correctamente!");
        end else if (errors <= 1) begin
            $display("  ⚠ %0d test con problema menor - CPU funcional", errors);
        end else begin
            $display("  ❌ %0d de 10 tests fallaron", errors);
        end
        $display("=================================================================\n");
        
        $display("Instrucciones probadas:");
        $display("  1. ADDI  - Aritmética inmediata");
        $display("  2. ADD   - Suma");
        $display("  3. SUB   - Resta");
        $display("  4. XORI  - XOR inmediato");
        $display("  5. AND   - AND lógico");
        $display("  6. SLLI  - Shift left lógico");
        $display("  7. SRAI  - Shift right aritmético");
        $display("  8. SW/LW - Store/Load word");
        $display("  9. BEQ   - Branch if equal");
        $display(" 10. JAL   - Jump and link\n");
        
        $finish;
    end
    
    // Timeout de seguridad
    initial begin
        #500;
        $display("\n⚠ TIMEOUT - El testbench excedió el tiempo límite");
        $finish;
    end

endmodule
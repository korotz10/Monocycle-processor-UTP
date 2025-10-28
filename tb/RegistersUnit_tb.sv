module RegistersUnit_tb;
    // Señales del testbench
    logic clk;
    logic signed [4:0] rs1;
    logic signed [4:0] rs2;
    logic signed [4:0] rd;
    logic signed [31:0] DataWR;
    logic RUWr;
    logic signed [31:0] ru_rs1;
    logic signed [31:0] ru_rs2;
    
    // Instanciar el DUT
    RegistersUnit dut (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .DataWR(DataWR),
        .RUWr(RUWr),
        .ru_rs1(ru_rs1),
        .ru_rs2(ru_rs2)
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
        $dumpfile("RegistersUnit_tb.vcd");
        $dumpvars(0, RegistersUnit_tb);
    end
    
    // Tarea para escribir en un registro
    task write_register(input [4:0] reg_addr, input [31:0] data);
        @(posedge clk);
        rd = reg_addr;
        DataWR = data;
        RUWr = 1;
        @(posedge clk);
        RUWr = 0;
        $display("Escritura: R%0d = 0x%h (%b)", reg_addr, data, data);
    endtask
    
    // Tarea para leer y verificar un registro
    task read_register(input [4:0] reg_addr, input [31:0] expected);
        @(posedge clk);
        rs1 = reg_addr;
        #1; // Pequeño delay para que se propague la lectura
        tests++;
        $display("Lectura R%0d:", reg_addr);
        $display("  Esperado = 0x%h (%b)", expected, expected);
        $display("  Obtenido = 0x%h (%b)", ru_rs1, ru_rs1);
        if (ru_rs1 !== expected) begin
            $display("  ERROR: No coincide");
            errors++;
        end else begin
            $display("  OK");
        end
        $display("");
    endtask
    
    // Tarea para leer dos registros simultáneamente
    task read_two_registers(input [4:0] reg1, input [4:0] reg2, 
                           input [31:0] exp1, input [31:0] exp2);
        @(posedge clk);
        rs1 = reg1;
        rs2 = reg2;
        #1;
        tests += 2;
        $display("Lectura simultanea R%0d y R%0d:", reg1, reg2);
        $display("  R%0d: Esperado = 0x%h, Obtenido = 0x%h", reg1, exp1, ru_rs1);
        if (ru_rs1 !== exp1) begin
            $display("       ERROR en R%0d", reg1);
            errors++;
        end else begin
            $display("       OK R%0d", reg1);
        end
        
        $display("  R%0d: Esperado = 0x%h, Obtenido = 0x%h", reg2, exp2, ru_rs2);
        if (ru_rs2 !== exp2) begin
            $display("       ERROR en R%0d", reg2);
            errors++;
        end else begin
            $display("       OK R%0d", reg2);
        end
        $display("");
    endtask
    
    // Secuencia de pruebas
    initial begin
        // Inicialización
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        DataWR = 0;
        RUWr = 0;
        
        $display("========================================");
        $display("=== Iniciando simulacion RegistersUnit ===");
        $display("========================================\n");
        
        // Esperar unos ciclos
        repeat(3) @(posedge clk);
        
        // Test 1: Verificar inicialización de R2
        $display("========== Test 1: Verificar inicializacion ==========");
        read_register(2, 32'h00000200); // R2 debe inicializarse con 1000000000 binario = 0x200
        
        // Test 2: Verificar que R0 siempre es 0
        $display("========== Test 2: Verificar R0 siempre es 0 ==========");
        read_register(0, 32'h00000000);
        
        // Test 3: Intentar escribir en R0 (debe fallar, R0 siempre es 0)
        $display("========== Test 3: Intentar escribir en R0 ==========");
        write_register(0, 32'hDEADBEEF);
        read_register(0, 32'h00000000); // Debe seguir siendo 0
        
        // Test 4: Escribir valores en varios registros
        $display("========== Test 4: Escribir en registros ==========");
        write_register(1, 32'h0000000A);  // R1 = 10
        write_register(3, 32'h00000014);  // R3 = 20
        write_register(5, 32'hFFFFFFFF);  // R5 = -1
        write_register(10, 32'h12345678); // R10 = 0x12345678
        
        // Test 5: Leer los valores escritos
        $display("========== Test 5: Leer valores escritos ==========");
        read_register(1, 32'h0000000A);
        read_register(3, 32'h00000014);
        read_register(5, 32'hFFFFFFFF);
        read_register(10, 32'h12345678);
        
        // Test 6: Sobrescribir un registro
        $display("========== Test 6: Sobrescribir registro ==========");
        $display("Escribiendo nuevo valor en R1");
        write_register(1, 32'h000000FF);
        read_register(1, 32'h000000FF);
        
        // Test 7: Lecturas simultáneas
        $display("========== Test 7: Lecturas simultaneas ==========");
        read_two_registers(1, 3, 32'h000000FF, 32'h00000014);
        read_two_registers(5, 10, 32'hFFFFFFFF, 32'h12345678);
        
        // Test 8: Escribir sin RUWr activado
        $display("========== Test 8: Escribir sin RUWr (no debe escribir) ==========");
        @(posedge clk);
        rd = 7;
        DataWR = 32'hBAADF00D;
        RUWr = 0; // No activado
        @(posedge clk);
        $display("Intento de escritura en R7 sin RUWr");
        read_register(7, 32'h00000000); // Debe seguir en 0
        
        // Test 9: Escribir y leer en el mismo ciclo
        $display("========== Test 9: Escribir en R15 ==========");
        write_register(15, 32'hCAFEBABE);
        read_register(15, 32'hCAFEBABE);
        
        // Test 10: Probar registros en los límites
        $display("========== Test 10: Registros en los limites ==========");
        write_register(31, 32'hFFFF0000);
        read_register(31, 32'hFFFF0000);
        
        // Test 11: Valores negativos
        $display("========== Test 11: Valores negativos ==========");
        write_register(20, 32'hFFFFFFF0); // -16 en complemento a 2
        read_register(20, 32'hFFFFFFF0);
        
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
        repeat(5) @(posedge clk);
        $finish;
    end
    
endmodule
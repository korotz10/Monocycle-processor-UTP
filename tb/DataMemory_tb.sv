`timescale 1ns / 1ps

module DataMemory_tb;

    // Parámetros
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Señales del DUT
    logic        clk;
    logic [31:0] Address;
    logic [31:0] DataWr;
    logic        DMWr;
    logic [2:0]  DMCtrl;
    logic [31:0] DataRd;
    
    // Contadores de pruebas
    integer tests = 0;
    integer errors = 0;
    
    // Instancia del módulo bajo prueba
    DataMemory #(
        .ADDR_WIDTH(10)
    ) dut (
        .clk(clk),
        .Address(Address),
        .DataWr(DataWr),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .DataRd(DataRd)
    );
    
    // Generación del reloj
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Task para verificar resultados
    task check_result(
        input string test_name,
        input logic [31:0] expected,
        input logic [31:0] actual
    );
        tests++;
        #1;
        if (actual === expected) begin
            $display("PASS: %s", test_name);
        end else begin
            $display("ERROR: %s", test_name);
            $display("   Expected: 0x%h, Got: 0x%h", expected, actual);
            errors++;
        end
    endtask
    
    // Proceso de prueba
    initial begin
        $dumpfile("sim/DataMemory_tb.vcd");
        $dumpvars(0, DataMemory_tb);
        
        $display("\n========================================");
        $display("  DataMemory Testbench - RISC-V");
        $display("========================================\n");
        
        // Inicialización
        Address = 32'h0;
        DataWr  = 32'h0;
        DMWr    = 1'b0;
        DMCtrl  = 3'b0;
        
        @(posedge clk);
        #1;
        
        // ==================== STORE WORD ====================
        $display("--- STORE WORD (SW) ---\n");
        
        Address = 32'h00000000;
        DataWr  = 32'hDEADBEEF;
        DMWr    = 1'b1;
        DMCtrl  = 3'b010;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b010;
        #1;
        check_result("SW: Write and read 0xDEADBEEF", 32'hDEADBEEF, DataRd);
        
        @(posedge clk);
        #1;
        
        // ==================== STORE HALFWORD ====================
        $display("\n--- STORE HALFWORD (SH) ---\n");
        
        // SH en offset 0
        Address = 32'h00000004;
        DataWr  = 32'h0000CAFE;
        DMWr    = 1'b1;
        DMCtrl  = 3'b001;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b001;
        #1;
        check_result("SH offset 0: LH sign-extend 0xCAFE", 32'hFFFFCAFE, DataRd);
        
        DMCtrl = 3'b101;
        #1;
        check_result("SH offset 0: LHU zero-extend 0xCAFE", 32'h0000CAFE, DataRd);
        
        @(posedge clk);
        #1;
        
        // SH en offset 2
        Address = 32'h00000006;
        DataWr  = 32'h00001234;
        DMWr    = 1'b1;
        DMCtrl  = 3'b001;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b101;
        #1;
        check_result("SH offset 2: LHU 0x1234", 32'h00001234, DataRd);
        
        @(posedge clk);
        #1;
        
        // ==================== STORE BYTE ====================
        $display("\n--- STORE BYTE (SB) ---\n");
        
        // Guardar bytes en offsets 0-3
        for (int i = 0; i < 4; i++) begin
            Address = 32'h00000008 + i;
            DataWr  = 32'h000000A0 + i;
            DMWr    = 1'b1;
            DMCtrl  = 3'b000;
            
            @(posedge clk);
            #1;
        end
        
        // Verificar palabra completa
        Address = 32'h00000008;
        DMWr = 1'b0;
        DMCtrl = 3'b010;
        #1;
        check_result("SB: Four bytes form 0xA3A2A1A0", 32'hA3A2A1A0, DataRd);
        
        @(posedge clk);
        #1;
        
        // ==================== LOAD BYTE ====================
        $display("\n--- LOAD BYTE (LB/LBU) ---\n");
        
        // Verificar cada offset con LB y LBU
        for (int i = 0; i < 4; i++) begin
            Address = 32'h00000008 + i;
            DMWr = 1'b0;
            
            // LBU
            DMCtrl = 3'b100;
            #1;
            check_result($sformatf("LBU offset %0d: 0x%h", i, 32'h000000A0 + i), 
                        32'h000000A0 + i, DataRd);
            
            // LB (extensión de signo)
            DMCtrl = 3'b000;
            #1;
            check_result($sformatf("LB offset %0d: 0x%h", i, 32'hFFFFFFA0 + i), 
                        32'hFFFFFFA0 + i, DataRd);
            
            @(posedge clk);
            #1;
        end
        
        // ==================== LOAD BYTE SIGN EXTENSION ====================
        $display("\n--- LOAD BYTE SIGN EXTENSION ---\n");
        
        // Byte negativo (0xFF = -1)
        Address = 32'h0000000C;
        DataWr  = 32'h000000FF;
        DMWr    = 1'b1;
        DMCtrl  = 3'b000;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b000;
        #1;
        check_result("LB: Sign-extend 0xFF to 0xFFFFFFFF", 32'hFFFFFFFF, DataRd);
        
        DMCtrl = 3'b100;
        #1;
        check_result("LBU: Zero-extend 0xFF to 0x000000FF", 32'h000000FF, DataRd);
        
        @(posedge clk);
        #1;
        
        // Byte positivo (0x7F = 127)
        Address = 32'h0000000D;
        DataWr  = 32'h0000007F;
        DMWr    = 1'b1;
        DMCtrl  = 3'b000;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b000;
        #1;
        check_result("LB: Sign-extend 0x7F to 0x0000007F", 32'h0000007F, DataRd);
        
        @(posedge clk);
        #1;
        
        // ==================== LOAD HALFWORD SIGN EXTENSION ====================
        $display("\n--- LOAD HALFWORD SIGN EXTENSION ---\n");
        
        // Halfword negativo (0x8000 = -32768)
        Address = 32'h00000010;
        DataWr  = 32'h00008000;
        DMWr    = 1'b1;
        DMCtrl  = 3'b001;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b001;
        #1;
        check_result("LH: Sign-extend 0x8000 to 0xFFFF8000", 32'hFFFF8000, DataRd);
        
        DMCtrl = 3'b101;
        #1;
        check_result("LHU: Zero-extend 0x8000 to 0x00008000", 32'h00008000, DataRd);
        
        @(posedge clk);
        #1;
        
        // Halfword positivo (0x7FFF = 32767)
        Address = 32'h00000012;
        DataWr  = 32'h00007FFF;
        DMWr    = 1'b1;
        DMCtrl  = 3'b001;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b001;
        #1;
        check_result("LH: Sign-extend 0x7FFF to 0x00007FFF", 32'h00007FFF, DataRd);
        
        @(posedge clk);
        #1;
        
        // ==================== WRITE-READ SEQUENCE ====================
        $display("\n--- WRITE-READ SEQUENCE ---\n");
        
        Address = 32'h00000020;
        DataWr  = 32'h12345678;
        DMWr    = 1'b1;
        DMCtrl  = 3'b010;
        
        @(posedge clk);
        #1;
        
        DMWr = 1'b0;
        DMCtrl = 3'b010;
        #1;
        check_result("SW followed by LW: 0x12345678", 32'h12345678, DataRd);
        
        @(posedge clk);
        #1;
        
        // ==================== MULTIPLE ADDRESSES ====================
        $display("\n--- MULTIPLE ADDRESSES ---\n");
        
        // Escribir en múltiples direcciones
        for (int i = 0; i < 4; i++) begin
            Address = 32'h00000030 + (i * 4);
            DataWr  = 32'h11110000 + (i * 32'h00001111);
            DMWr    = 1'b1;
            DMCtrl  = 3'b010;
            
            @(posedge clk);
            #1;
        end
        
        // Leer y verificar
        for (int i = 0; i < 4; i++) begin
            Address = 32'h00000030 + (i * 4);
            DMWr = 1'b0;
            DMCtrl = 3'b010;
            #1;
            check_result($sformatf("Read address 0x%h", Address), 
                        32'h11110000 + (i * 32'h00001111), DataRd);
            
            @(posedge clk);
            #1;
        end
        
        // ==================== INVALID DMCTRL ====================
        $display("\n--- INVALID DMCTRL ---\n");
        
        Address = 32'h00000000;
        DMWr = 1'b0;
        DMCtrl = 3'b111;
        #1;
        check_result("Invalid DMCtrl returns 0x00000000", 32'h00000000, DataRd);
        
        @(posedge clk);
        #1;
        
        DMCtrl = 3'b011;
        #1;
        check_result("Invalid DMCtrl 0b011 returns 0x00000000", 32'h00000000, DataRd);
        
        @(posedge clk);
        #1;
        
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
        
        #100;
        $finish;
    end

endmodule
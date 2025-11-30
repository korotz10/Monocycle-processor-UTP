module DataMemory #(
    parameter ADDR_WIDTH = 10   // 1024 palabras => 4 KB
)(
    input  logic        clk,
    input  logic [31:0] Address,
    input  logic [31:0] DataWr,
    input  logic        DMWr,
    input  logic [2:0]  DMCtrl,
    output logic [31:0] DataRd
);

    // Memoria de 32 bits por palabra
    logic [31:0] mem [0:(1<<ADDR_WIDTH)-1];
    
    // Palabra leída de memoria (auxiliar)
    logic [31:0] read_word;

    // Inicialización de memoria a 0
    initial begin
        integer i;
        for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
            mem[i] = 32'h00000000;
        end
    end

    // ============================================================
    //    ESCRITURA SÍNCRONA (Store) - al flanco positivo del clk
    // ============================================================
    always_ff @(posedge clk) begin
        if (DMWr) begin
            case (DMCtrl)
                3'b000: begin  // SB - Store Byte
                    case (Address[1:0])
                        2'b00: mem[Address[31:2]][7:0]   <= DataWr[7:0];
                        2'b01: mem[Address[31:2]][15:8]  <= DataWr[7:0];
                        2'b10: mem[Address[31:2]][23:16] <= DataWr[7:0];
                        2'b11: mem[Address[31:2]][31:24] <= DataWr[7:0];
                    endcase
                end

                3'b001: begin  // SH - Store Halfword
                    case (Address[1])
                        1'b0: mem[Address[31:2]][15:0]  <= DataWr[15:0];
                        1'b1: mem[Address[31:2]][31:16] <= DataWr[15:0];
                    endcase
                end

                3'b010: begin  // SW - Store Word
                    mem[Address[31:2]] <= DataWr;
                end

                default: begin
                    // Otros códigos no realizan escritura
                end
            endcase
        end
    end

    // ============================================================
    //    LECTURA COMBINACIONAL (Load) - para procesador monociclo
    // ============================================================
    
    // Primero leemos la palabra completa
    assign read_word = mem[Address[31:2]];
    
    // Luego procesamos según el tipo de load
    always_comb begin
        case (DMCtrl)
            3'b000: begin  // LB - Load Byte (con extensión de signo)
                case (Address[1:0])
                    2'b00: DataRd = {{24{read_word[7]}},  read_word[7:0]};
                    2'b01: DataRd = {{24{read_word[15]}}, read_word[15:8]};
                    2'b10: DataRd = {{24{read_word[23]}}, read_word[23:16]};
                    2'b11: DataRd = {{24{read_word[31]}}, read_word[31:24]};
                endcase
            end

            3'b100: begin  // LBU - Load Byte Unsigned
                case (Address[1:0])
                    2'b00: DataRd = {24'b0, read_word[7:0]};
                    2'b01: DataRd = {24'b0, read_word[15:8]};
                    2'b10: DataRd = {24'b0, read_word[23:16]};
                    2'b11: DataRd = {24'b0, read_word[31:24]};
                endcase
            end

            3'b001: begin  // LH - Load Halfword (con extensión de signo)
                case (Address[1])
                    1'b0: DataRd = {{16{read_word[15]}}, read_word[15:0]};
                    1'b1: DataRd = {{16{read_word[31]}}, read_word[31:16]};
                endcase
            end

            3'b101: begin  // LHU - Load Halfword Unsigned
                case (Address[1])
                    1'b0: DataRd = {16'b0, read_word[15:0]};
                    1'b1: DataRd = {16'b0, read_word[31:16]};
                endcase
            end

            3'b010: begin  // LW - Load Word
                DataRd = read_word;
            end

            default: begin
                DataRd = 32'b0;
            end
        endcase
    end

endmodule
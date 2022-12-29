
/*
instructions:
000 addi 00000 arg
001 subi 00000 arg
010 mr 00000 arg
011 ml 00000 arg
10 io 000000 arg
110 bz 00000 arg
111 bnz 00000 arg
*/

//STEPS:
//0. read instruction from ROM, store it in register
//0. read data from RAM, store it in register
//1. execute instruction, store results in register
//2. update program counter
//2. write data to RAM
//3. -


//-- Fichero con la rom
parameter ROMFILE = "bf_program.list";

module bf_alu(
    input clk_in,
    input [7:0] instr, //instruction
    input [7:0] read_mem, //data read from memory

    output [7:0] write_mem, //data to write in memory
    output [7:0] addr_mem, //address to read or write
    output rw_mem, //read(1) or write(0)
    output [7:0] pc, //program counter
    );

    wire [1:0] opcode = instr[7:6];
    wire [5:0] args = instr[5:0];

    wire [7:0] change_pc;
    reg [7:0] pc;
    wire [7:0] change_pointer;
    reg [7:0] pointer;

    always @(posedge clk_in) begin
        pc <= pc + change_pc;
        pointer <= pointer + change_pointer;
    end

    always @(*)
      case (opcode)
        2'b00: begin//edit strip
            if (args[5]==0) begin
                write_mem=read_mem+args[4:0];
            end
            else begin
                write_mem=read_mem-args[4:0];
            end
            rw_mem=0;//write
            addr_mem=prev_addr;
            change_pc=1;
        end
        2'b01: begin//move cursor
            if (args[5]==0) begin//right
                change_pointer=args[4:0];
            end
            else begin//left
                change_pointer=-args[4:0];
            end
            write_mem=0;
            rw_mem=1;//read
            change_pc=1;
        end
        2'b10: begin//input/output
            change_pointer=0;
            write_mem=0;
            rw_mem=1;
            change_pc=1;
        end
        2'b11: begin//jump
            if (args[5]==0) begin//jump if zero
                if (read_mem==0) begin
                    change_pc=args[4:0];
                end
                else begin
                    change_pc=1;
                end
            end
            else begin//jump if not zero
                if (read_mem!=0) begin
                    change_pc=args[4:0];
                end
                else begin
                    change_pc=1;
                end
            end
            write_mem=0;
            rw_mem=1;
        end
      endcase
    
endmodule



module brainfuck(input clk_in, input [1:0] push, output [7:0] led);
    //GENERATE SLOW CLOCK
    wire slow_clk;
    prescaler #(.N(23))
    Pres(
        .clk_in(clk_in),
        .clk_out(slow_clk)
    );//generate slow clock, 12MHz to 1Hz

    wire [4:0] rom_addr;
    wire [7:0] rom_out;

    wire [7:0] ram_in;
    wire [7:0] ram_addr;
    wire ram_rw;
    wire [7:0] ram_out;

    genram #(.ROMFILE(ROMFILE),.AW(5),.DW(8)) INSTR_ROM (
        .clk(slow_clk),
        .addr(rom_addr),
        .data_in(0),
        .rw(1),//reading

        .data_out(rom_out)
    );
    
    genram #(.AW(5),.DW(8)) DATA_RAM (
        .clk(slow_clk),
        .addr(ram_addr),
        .data_in(ram_in),
        .rw(ram_rw),
        .data_out(ram_out)
    );

    bf_alu bf (
        .clk_in(slow_clk),
        .instr(rom_out),
        .read_mem(ram_out),

        .write_mem(ram_in),
        .addr_mem(ram_addr),
        .rw_mem(ram_rw),
        .pc(rom_addr)
    );
    
    always @(*) begin
        led = ram_out;
        //led = rom_addr;
    end

    /*
    assign led[0] = instr[0];
    assign led[1] = instr[1];
    assign led[2] = instr[2];
    assign led[3] = pc[25];
    assign led[4] = pc[24];
    assign led[5] = pc[23];
    assign led[6] = pc[22];
    assign led[7] = pc[21];
    */

    //assign led = data_out;

endmodule


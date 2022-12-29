//parameters:
// clk_in: clock input
// registers: 8 registers (8 bits each)
// op: operation (4 bit value)
  // 0: add
  // 1: sub
  // 2: addi
  // 3: zero
  // 4: and
  // 5: nand
  // 6: left shift
  // 7: right shift
  // 8: copy
  // 9: io
  // 10: cmp
  // 11: jump
  // 12: load
  // 13: store
  // 14: flag reset
  // 15: not used (nop)
// args: (4 bit value)
// memory: (8 bit value)

// outputs:
// result: result of the operation (8 bit value)
// control signal: (8 bit value)
  // register addresses: (4 bit value)
  // registers enable: (2 bit value)
  // memory control: (2 bit value)

module alu(input clk_in, input [7:0] param1, input [7:0] param2, input [1:0] op, output [7:0] result);
    always begin
      case (op)
        2'b00: result <= param1;
        2'b01: result <= param2;
        2'b10: result <= param1 + param2;
        2'b11: result <= param1 - param2;
      endcase
    end
endmodule

module alu_main (input clk_in, input [1:0] op, output [7:0] result);
    wire [7:0] result_wire;
    wire [7:0] param1;
    wire [7:0] param2;
    assign param1 = 8'b00000011;
    assign param2 = 8'b00000010;
    alu alu1(clk_in, param1, param2, op, result_wire);
    assign result = result_wire;
endmodule

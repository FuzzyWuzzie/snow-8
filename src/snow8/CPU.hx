package snow8;

import haxe.ds.Vector;
import haxe.ds.GenericStack;
import snow.api.buffers.Uint8Array;
using StringTools;

class CPU {
	public var memory:MemoryBus;
	public var display:DisplayBuffer;
	public var input:InputBuffer;

	public var stack:GenericStack<Int>;
	public var registers:Vector<Int>;
	public var index_register:Int;

	public function new(memory:MemoryBus, display:DisplayBuffer, input:InputBuffer) {
		this.memory = memory;
		this.display = display;
		this.input = input;
		this.stack = new GenericStack<Int>();
		this.registers = new Vector<Int>(16);
		index_register = 0;
	}

	public function run_instruction(opcode:Int) {
		switch(opcode & 0xF000) {
			case OpCodes.GRP_SYS: {
				switch(opcode) {
					case OpCodes.CLS: display.clear_screen();
					case OpCodes.RET: {
						var addr:Int = stack.pop();
						memory.program_counter = addr;
					}
					case _: {}
				}
			}

			case OpCodes.JP_ADDR: {
				var addr:Int = opcode & 0x0FFF;
				memory.program_counter = addr;
			}

			case OpCodes.CALL_ADDR: {
				var addr:Int = opcode & 0x0FFF;
				stack.add(memory.program_counter);
				memory.program_counter = addr;
			}

			case OpCodes.SE_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var byte:Int = opcode & 0x00FF;
				if(registers[reg] == byte) memory.program_counter += 2;
			}

			case OpCodes.SNE_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var byte:Int = opcode & 0x00FF;
				if(registers[reg] != byte) memory.program_counter += 2;
			}

			case OpCodes.SE_REG: {
				var reg_x:Int = (opcode & 0x0F00) >> 8;
				var reg_y:Int = (opcode & 0x00F0) >> 4;
				if(registers[reg_x] == registers[reg_y]) memory.program_counter += 2;
			}

			case OpCodes.LD_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var val:Int = opcode & 0x00FF;
				registers[reg] = val;
			}

			case OpCodes.ADD_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var val:Int = opcode & 0x00FF;
				registers[reg] = 0x0FF & (registers[reg] + val);
			}

			case OpCodes.GRP_MATH: {
				switch(opcode & 0xF00F) {
					case OpCodes.LD_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_y];
					}

					case OpCodes.OR_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_x] | registers[reg_y];
					}

					case OpCodes.AND_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_x] & registers[reg_y];
					}

					case OpCodes.XOR_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_x] ^ registers[reg_y];
					}

					case OpCodes.ADD_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] += registers[reg_y];
						registers[0x0f] = if(registers[reg_x] > 255) 1 else 0;
						registers[reg_x] = registers[reg_x] & 0xff;
					}

					case OpCodes.SUB_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[0x0f] = if(registers[reg_x] > registers[reg_y]) 1 else 0;
						registers[reg_x] -= registers[reg_y];
						registers[reg_x] = registers[reg_x] & 0xff;
					}

					case OpCodes.SHR_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						registers[0x0f] = registers[reg_x] & 0x01;
						registers[reg_x] = 0xff & (registers[reg_x] >>> 1);
					}

					case OpCodes.SUBN_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[0x0f] = if(registers[reg_y] > registers[reg_x]) 1 else 0;
						registers[reg_x] = 0xff & (registers[reg_y] - registers[reg_x]);
					}

					case OpCodes.SHL_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						registers[0x0f] = (registers[reg_x] & 0x80) >> 7;
						registers[reg_x] = 0xff & (registers[reg_x] << 1);
					}

					case _: {
						throw 'Unhandled opcode: 0x${opcode.hex(4)}!';
					}
				}
			}

			case OpCodes.SNE_REG: {
				var reg_x:Int = (opcode & 0x0F00) >> 8;
				var reg_y:Int = (opcode & 0x00F0) >> 4;
				if(registers[reg_x] != registers[reg_y]) memory.program_counter += 2;
			}

			case OpCodes.LD_I_ADDR: {
				var val:Int = opcode & 0x0FFF;
				index_register = val;
			}

			case OpCodes.JP_ADDR_OFFS: {
				var addr:Int = opcode & 0x0FFF;
				memory.program_counter = addr + registers[0];
			}

			case OpCodes.RND_BYTE: {
				var reg_x:Int = (opcode & 0x0F00) >> 8;
				var byte:Int = opcode & 0xff;
				var rand:Int = Math.floor((256 * Math.random()));
				registers[reg_x] = byte & rand;
			}

			case OpCodes.GRP_SKP: {
				switch(opcode & 0xF0FF) {
					case OpCodes.SKP_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						if(input.is_key_pressed(registers[reg_x])) memory.program_counter += 2;
					}

					case OpCodes.SKNP_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						if(!input.is_key_pressed(registers[reg_x])) memory.program_counter += 2;
					}

					case _: {
						throw 'Unhandled opcode: 0x${opcode.hex(4)}!';
					}
				}
			}

			case _: {
				throw 'Unhandled opcode: 0x${opcode.hex(4)}!';
			}
		}
	}
}
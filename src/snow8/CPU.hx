package snow8;

import haxe.ds.Vector;
import haxe.ds.GenericStack;
import snow.api.buffers.Uint8Array;
import debug.Log;
using StringTools;

class CPU {
	public var memory:MemoryBus;
	public var display:DisplayBuffer;
	public var input:InputBuffer;
	public var timers:TimerRegisters;

	public var stack:GenericStack<Int>;
	public var registers:Vector<Int>;
	public var index_register:Int;

	public function new(memory:MemoryBus, display:DisplayBuffer, input:InputBuffer, timers:TimerRegisters) {
		this.memory = memory;
		this.display = display;
		this.input = input;
		this.timers = timers;
		this.stack = new GenericStack<Int>();
		this.registers = new Vector<Int>(16);
		for(i in 0...16) {
			registers[i] = 0;
		}
		index_register = 0;
	}

	public function run_instruction(opcode:Int) {
		switch(opcode & 0xF000) {
			case OpCodes.GRP_SYS: {
				switch(opcode) {
					case OpCodes.CLS: {
						display.clear_screen();
						Log.trace('cls');
					}

					case OpCodes.RET: {
						var addr:Int = stack.pop();
						memory.program_counter = addr;
						Log.trace('ret -> ${addr}');
					}
					case _: {
						Log.trace('0x0000');
					}
				}
			}

			case OpCodes.JP_ADDR: {
				var addr:Int = opcode & 0x0FFF;
				memory.program_counter = addr;
				Log.trace('jp_addr ${addr}');
			}

			case OpCodes.CALL_ADDR: {
				var addr:Int = opcode & 0x0FFF;
				stack.add(memory.program_counter);
				memory.program_counter = addr;
				Log.trace('call_addr ${addr}');
			}

			case OpCodes.SE_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var byte:Int = opcode & 0x00FF;
				if(registers[reg] == byte) memory.program_counter += 2;
				Log.trace('se_byte [${reg}] == ${byte}');
			}

			case OpCodes.SNE_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var byte:Int = opcode & 0x00FF;
				if(registers[reg] != byte) memory.program_counter += 2;
				Log.trace('sne_byte [${reg}] == ${byte}');
			}

			case OpCodes.SE_REG: {
				var reg_x:Int = (opcode & 0x0F00) >> 8;
				var reg_y:Int = (opcode & 0x00F0) >> 4;
				if(registers[reg_x] == registers[reg_y]) memory.program_counter += 2;
				Log.trace('se_reg [${reg_x}] == [${reg_y}]');
			}

			case OpCodes.LD_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var val:Int = opcode & 0x00FF;
				registers[reg] = val;
				Log.trace('ld_byte [${reg}] = ${val}');
			}

			case OpCodes.ADD_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var val:Int = opcode & 0x00FF;
				registers[reg] = 0x0FF & (registers[reg] + val);
				Log.trace('add_byte [${reg}] + ${val}');
			}

			case OpCodes.GRP_MATH: {
				switch(opcode & 0xF00F) {
					case OpCodes.LD_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_y];
						Log.trace('ld_reg [${reg_x}] = [${reg_y}]');
					}

					case OpCodes.OR_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_x] | registers[reg_y];
						Log.trace('or_reg [${reg_x}] | [${reg_y}]');
					}

					case OpCodes.AND_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_x] & registers[reg_y];
						Log.trace('and_reg [${reg_x}] & [${reg_y}]');
					}

					case OpCodes.XOR_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] = registers[reg_x] ^ registers[reg_y];
						Log.trace('xor_reg [${reg_x}] ^ [${reg_y}]');
					}

					case OpCodes.ADD_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[reg_x] += registers[reg_y];
						registers[0x0f] = if(registers[reg_x] > 255) 1 else 0;
						registers[reg_x] = registers[reg_x] & 0xff;
						Log.trace('add_reg [${reg_x}] + [${reg_y}]');
					}

					case OpCodes.SUB_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[0x0f] = if(registers[reg_x] > registers[reg_y]) 1 else 0;
						registers[reg_x] -= registers[reg_y];
						registers[reg_x] = registers[reg_x] & 0xff;
						Log.trace('sub_reg [${reg_x}] - [${reg_y}]');
					}

					case OpCodes.SHR_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						registers[0x0f] = registers[reg_x] & 0x01;
						registers[reg_x] = 0xff & (registers[reg_x] >>> 1);
						Log.trace('shr_reg [${reg_x}]');
					}

					case OpCodes.SUBN_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var reg_y:Int = (opcode & 0x00F0) >> 4;
						registers[0x0f] = if(registers[reg_y] > registers[reg_x]) 1 else 0;
						registers[reg_x] = 0xff & (registers[reg_y] - registers[reg_x]);
						Log.trace('SUBN_REG [${reg_y}] - [${reg_x}]');
					}

					case OpCodes.SHL_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						registers[0x0f] = (registers[reg_x] & 0x80) >> 7;
						registers[reg_x] = 0xff & (registers[reg_x] << 1);
						Log.trace('shl_reg [${reg_x}]');
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
				Log.trace('sne_reg [${reg_x}] != [${reg_y}');
			}

			case OpCodes.LD_I_ADDR: {
				var val:Int = opcode & 0x0FFF;
				index_register = val;
				Log.trace('ld_i_addr = ${val}');
			}

			case OpCodes.JP_ADDR_OFFS: {
				var addr:Int = opcode & 0x0FFF;
				memory.program_counter = addr + registers[0];
				Log.trace('jp_addr_offs ${addr}');
			}

			case OpCodes.RND_BYTE: {
				var reg_x:Int = (opcode & 0x0F00) >> 8;
				var byte:Int = opcode & 0xff;
				var rand:Int = Math.floor((256 * Math.random()));
				registers[reg_x] = byte & rand;
				Log.trace('rnd_byte [${reg_x}] = ${byte} & ${rand}');
			}

			case OpCodes.DRW_NIBBLE: {
				// gather information
				var x:Int = (opcode & 0x0F00) >> 8;
				var y:Int = (opcode & 0x00F0) >> 4;
				var n:Int = (opcode & 0x000F);

				// clear the overflow register
				registers[0x0f] = 0;
				for(yl in 0...n) {
					var pixels:Int = memory.read_from_address(index_register + yl);
					for(xl in 0...8) {
						if((pixels & (0x80 >> xl)) != 0) {
							if(display.get_pixel(x + xl, y + yl)) {
								registers[0x0f] = 0;
							}
							display.xor_pixel(x + xl, y + yl);
						}
					}
				}

				Log.trace('drw_nibble @ ${x},${y} (${n})');
			}

			case OpCodes.GRP_SKP: {
				switch(opcode & 0xF0FF) {
					case OpCodes.SKP_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						if(input.is_key_pressed(registers[reg_x])) memory.program_counter += 2;
						Log.trace('skp_reg [${reg_x}]');
					}

					case OpCodes.SKNP_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						if(!input.is_key_pressed(registers[reg_x])) memory.program_counter += 2;
						Log.trace('sknp_reg [${reg_x}]');
					}

					case _: {
						throw 'Unhandled opcode: 0x${opcode.hex(4)}!';
					}
				}
			}

			case OpCodes.GRP_LD: {
				switch(opcode & 0xF0FF) {
					case OpCodes.LD_REG_DT: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						registers[reg_x] = timers.delay_timer;
						Log.trace('ld_reg_dt [${reg_x}]');
					}

					case OpCodes.LD_DT_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						timers.delay_timer = registers[reg_x];
						Log.trace('ld_dt_reg [${reg_x}]');
					}

					case OpCodes.LD_ST_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						timers.sound_timer = registers[reg_x];
						Log.trace('ld_st_reg [${reg_x}]');
					}

					case OpCodes.ADD_I_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						index_register += registers[reg_x];
						Log.trace('add_i_reg [${reg_x}]');
					}

					case OpCodes.LD_F_REG: {
						var char:Int = (opcode & 0x0F00) >> 8;
						index_register = 0x50 + (char * 5);
						Log.trace('ld_f_reg ${char}');
					}

					case OpCodes.LD_B_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						var x:Int = registers[reg_x];
						var hundreds:Int = Math.floor(x / 100);
						var tens:Int = Math.floor(x / 10) % 10;
						var ones:Int = (x % 100) % 10;
						memory.write_to_address(index_register, hundreds);
						memory.write_to_address(index_register + 1, tens);
						memory.write_to_address(index_register + 2, ones);
						Log.trace('ld_b_reg [${reg_x}]');
					}

					case OpCodes.LD_I_REG: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						for(i in 0...reg_x) {
							memory.write_to_address(index_register + i, registers[i]);
						}
						Log.trace('ld_i_reg [${reg_x}]');
					}

					case OpCodes.LD_REG_I: {
						var reg_x:Int = (opcode & 0x0F00) >> 8;
						for(i in 0...reg_x) {
							registers[i] = memory.read_from_address(index_register + i);
						}
						Log.trace('ld_reg_i [${reg_x}]');
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
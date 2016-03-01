package snow8;

import haxe.ds.Vector;
import haxe.ds.GenericStack;
import snow.api.buffers.Uint8Array;
using StringTools;

class CPU {
	public var memory:MemoryBus;
	public var display:DisplayBuffer;

	public var stack:GenericStack<Int>;
	public var registers:Vector<Int>;
	public var index_register:Int;

	public function new(memory:MemoryBus, display:DisplayBuffer) {
		this.memory = memory;
		this.display = display;
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

			case OpCodes.LD_BYTE: {
				var reg:Int = (opcode & 0x0F00) >> 8;
				var val:Int = opcode & 0x00FF;
				registers[reg] = val;
			}

			case _: {
				throw 'Unhandled opcode: 0x${opcode.hex(4)}!';
			}
		}
	}
}
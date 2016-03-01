package snow8;

import haxe.ds.Vector;
import snow.api.buffers.Uint8Array;
using StringTools;

class CPU {
	public var memory:MemoryBus;
	public var registers:Vector<Int>;
	public var indexRegister:Bool;

	public function new(memory:MemoryBus) {
		this.memory = memory;
		this.registers = new Vector<Int>(16);
		indexRegister = false;
	}

	public function run_instruction(opcode:Int) {
		switch(opcode & 0xF000) {
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
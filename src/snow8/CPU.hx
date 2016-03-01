package snow8;

import haxe.ds.Vector;
import snow.api.buffers.Uint8Array;
using StringTools;

class CPU {
	public var registers:Uint8Array;
	public var indexRegister:Bool;

	private var opcodes:Vector<OpCode> = new Vector<OpCode>(38);

	public function new() {
		this.registers = new Uint8Array(0, null, null, null, 0, 16);
		indexRegister = false;

		// intialize the opcodes
		opcodes[20] = new snow8.opcodes.LD();
	}

	public function run_instruction(code:Int) {
		for(opcode in opcodes) {
			if(opcode != null && opcode.matches(code)) {
				opcode.handle(code);
				return;
			}
		}
		throw 'Unhandled opcode: 0x${code.hex(4)}!';
	}
}
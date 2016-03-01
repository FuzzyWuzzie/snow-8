package snow8;

import snow.api.buffers.Uint8Array;

class CPU {
	public var registers:Uint8Array;
	public var indexRegister:Bool;

	public function new() {
		this.registers = new Uint8Array(0, null, null, null, 0, 16);
		indexRegister = false;
	}

	public function run_instruction(opcode:Int) {
		throw "Unhandled opcode: ${opcode}!";
	}
}
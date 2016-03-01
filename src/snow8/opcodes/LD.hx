package snow8.opcodes;

import snow8.OpCode;

class LD implements OpCode {
	public function new(){}

	public function matches(opcode:Int):Bool {
		return opcode & 0xa000 != 0;
	}

	public function handle(opcode:Int):Void {
		throw 'TODO!';
	}
}
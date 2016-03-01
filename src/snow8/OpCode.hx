package snow8;

interface OpCode {
	public function matches(opcode:Int):Bool;
	public function handle(opcode:Int):Void;
}
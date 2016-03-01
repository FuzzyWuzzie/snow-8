package snow8;

interface MemoryBus {
	public var program_counter(default, default):Int;
	public function write_to_address(address:Int, value:Int):Void;
	public function read_from_address(address:Int):Int;
}
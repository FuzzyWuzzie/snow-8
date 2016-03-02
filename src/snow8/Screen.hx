package snow8;

import haxe.ds.Vector;

class Screen implements DisplayBuffer {
	public var buffer:Vector<Int>;

	public function new() {
		buffer = new Vector(64 * 32);
	}

	public function clear_screen():Void {
		buffer = new Vector(64 * 32);
	}

	public function get_pixel(x:Int, y:Int):Bool {
		return buffer[(y * 64) + x] == 1;
	}

	public function xor_pixel(x:Int, y:Int):Void {
		buffer[(y * 64) + x] = buffer[(y * 64) + x] ^ 1;
	}
}
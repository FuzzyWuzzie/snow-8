package snow8;

import haxe.ds.Vector;

class Screen implements DisplayBuffer {
	public var buffer:Vector<Int>;

	public function new() {
		buffer = new Vector<Int>(64 * 32);
		for(i in 0...buffer.length) {
			buffer[i] = 0;
		}
	}

	public function clear_screen():Void {
		for(i in 0...buffer.length) {
			buffer[i] = 0;
		}
	}

	public function get_pixel(x:Int, y:Int):Bool {
		return buffer[(y * 64) + x] == 1;
	}

	public function xor_pixel(x:Int, y:Int):Void {
		buffer[(y * 64) + x] = 1;
	}
}
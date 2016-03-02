package snow8;

interface DisplayBuffer {
	public function clear_screen():Void;
	public function get_pixel(x:Int, y:Int):Bool;
	public function xor_pixel(x:Int, y:Int):Void;
}
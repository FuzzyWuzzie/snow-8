package snow8;

interface DisplayBuffer {
	public function clear_screen():Void;
	public function set_pixel(x:Int, y:Int, on:Bool):Void;
}
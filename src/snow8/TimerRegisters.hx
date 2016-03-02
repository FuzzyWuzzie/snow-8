package snow8;

class TimerRegisters {
	public var delay_timer:Int;
	public var sound_timer:Int;

	public var sound_listeners:Array<Void->Void>;

	public function new() {
		delay_timer = 0;
		sound_timer = 0;
		sound_listeners = new Array<Void->Void>();
	}

	public function tick() {
		if(delay_timer > 0) delay_timer -= 1;
		if(sound_timer > 0) {
			sound_timer -= 1;
			if(sound_timer == 0) {
				for(sound_listener in sound_listeners) {
					sound_listener();
				}
			}
		}
	}
}
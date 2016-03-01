package snow8;

import snow.api.Debug.*;
import snow.api.buffers.Uint8Array;

@:log_as('app')
class Chip8 {
	private var rom:Uint8Array;
	private var cpu:CPU;
	private var ram:Uint8Array;
	private var stack:Uint8Array;

	public function new(romBytes:Uint8Array) {
		// store the rom
		this.rom = romBytes;

		// initialize the CPU
		cpu = new CPU();

		// set up the memory
		ram = new Uint8Array(0, null, null, null, 0, 4096);
		stack = new Uint8Array(0, null, null, null, 0, 64);

		// tell the user we started up
		log('Welcome to snow-8!');
	}

	public function run_instruction() {

	}
}
package snow8;

import snow.api.Debug.*;
import snow.api.buffers.Uint8Array;

@:log_as('app')
class Chip8 {
	public var rom:Uint8Array;
	public var cpu:CPU;
	public var ram:Uint8Array;
	public var stack:Uint8Array;
	public var programCounter:Int;

	public function new(romBytes:Uint8Array) {
		// store the rom
		this.rom = romBytes;

		// initialize the CPU
		cpu = new CPU();
		programCounter = 0;

		// set up the memory
		ram = new Uint8Array(0, null, null, null, 0, 4096);
		stack = new Uint8Array(0, null, null, null, 0, 64);

		// load the fontset into memory
		// TODO

		// copy the ROM into memory
		for(i in 0...rom.length) {
			ram[i + 0x200] = rom[i];
		}
		
		// initialize the program counter
		programCounter = 0x200;

		// tell the user we started up
		log('Welcome to snow-8!');
	}

	public function run_instruction() {
		// get the opcode
		var opcode:Int = rom[programCounter] << 8 | rom[programCounter + 1];
		programCounter += 2;

		// run the opcode
		cpu.run_instruction(opcode);
	}
}
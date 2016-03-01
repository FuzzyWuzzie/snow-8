package snow8;

import snow.api.Debug.*;
import snow.api.buffers.Uint8Array;
import haxe.ds.Vector;

@:log_as('app')
class Chip8 implements MemoryBus {
	public var rom:Uint8Array;
	public var cpu:CPU;

	public var program_counter(default, default):Int;
	public var ram:Vector<Int>;

	private var fontset:Array<Int> = [
		0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
		0x20, 0x60, 0x20, 0x20, 0x70, // 1
		0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
		0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
		0x90, 0x90, 0xF0, 0x10, 0x10, // 4
		0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
		0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
		0xF0, 0x10, 0x20, 0x40, 0x40, // 7
		0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
		0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
		0xF0, 0x90, 0xF0, 0x90, 0x90, // A
		0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
		0xF0, 0x80, 0x80, 0x80, 0xF0, // C
		0xE0, 0x90, 0x90, 0x90, 0xE0, // D
		0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
		0xF0, 0x80, 0xF0, 0x80, 0x80  // F
	];

	public function new(romBytes:Uint8Array) {
		// store the rom
		this.rom = romBytes;

		// initialize the CPU
		cpu = new CPU(this, null);
		program_counter = 0;

		// set up the memory
		ram = new Vector<Int>(4096);

		// load the fontset into memory
		for(i in 0...80) {
			ram[i + 0x50] = fontset[i];
		}

		// copy the ROM into memory
		for(i in 0...rom.length) {
			ram[i + 0x200] = rom[i];
		}
		
		// initialize the program counter
		program_counter = 0x200;

		// tell the user we started up
		log('Welcome to snow-8!');
	}

	public function run_instruction() {
		// get the opcode
		var opcode:Int = (rom[program_counter] << 8) | rom[program_counter + 1];
		program_counter += 2;

		// run the opcode
		cpu.run_instruction(opcode);
	}

	public function write_to_address(address:Int, value:Int):Void {
		ram[address] = value;
	}

	public function read_from_address(address:Int):Int {
		return ram[address];
	}
}
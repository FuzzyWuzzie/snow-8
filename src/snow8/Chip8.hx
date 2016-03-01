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

	public function new(romBytes:Uint8Array) {
		// store the rom
		this.rom = romBytes;

		// initialize the CPU
		cpu = new CPU(this);
		program_counter = 0;

		// set up the memory
		ram = new Vector<Int>(4096);

		// load the fontset into memory
		// TODO

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
		var opcode:Int = rom[program_counter] << 8 | rom[program_counter + 1];
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
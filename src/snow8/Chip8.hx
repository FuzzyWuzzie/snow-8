package snow8;

import snow.api.buffers.Uint8Array;
import haxe.ds.Vector;
import debug.Log;

class Chip8 implements MemoryBus implements InputBuffer {
	public var frequency(default, set):Float;
	public function set_frequency(f:Float) {
		period = 1 / f;
		return frequency = f;
	}
	private var period:Float;
	private var time_accumulator:Float;
	private var timer:Float;

	public var rom:Uint8Array;
	public var cpu:CPU;

	public var program_counter(default, default):Int;
	public var ram:Vector<Int>;
	public var screen:Screen;
	public var timers:TimerRegisters;

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
		// set the frequency
		frequency = 500;
		time_accumulator = 0;
		timer = 0;

		// store the rom
		this.rom = romBytes;

		// initialize the timers
		timers = new TimerRegisters();

		// initialize the display
		screen = new Screen();

		// initialize the CPU
		cpu = new CPU(this, screen, this, timers);
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
		Log.info('Welcome to snow-8!');
	}

	private function run_instruction() {
		// get the opcode
		var opcode:Int = (ram[program_counter] << 8) | ram[program_counter + 1];
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

	public function is_key_pressed(key:Int):Bool {
		return false;
	}

	public function tick(delta:Float) {
		// figure out how many cycles to emulate
		var cycles_to_emulate:Int = Math.floor(delta / period);
		time_accumulator += delta - (cycles_to_emulate * period);
		while(time_accumulator >= period) {
			cycles_to_emulate += 1;
			time_accumulator -= period;
		}

		// emulate the cycles
		for(i in 0...cycles_to_emulate) {
			run_instruction();
			timer += period;
			if(timer >= (1.0/60.0)) {
				timers.tick();
				timer -= (1.0/60.0);
			}
		}
	}
}
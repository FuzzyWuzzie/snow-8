package snow8;

import buddy.*;
using buddy.Should;
import snow8.CPU;
import haxe.ds.IntMap;
import haxe.ds.Vector;
import snow8.MemoryBus;
import snow8.DisplayBuffer;
import snow8.InputBuffer;
import snow8.TimerRegisters;
import snow8.Screen;
using StringTools;

class MemoryMapFixture implements MemoryBus {
	public var map:IntMap<Int>;
	public var program_counter(default, default):Int;

	public function new() {
		map = new IntMap<Int>();
		program_counter = 0x200;
	}

	public function write_to_address(address:Int, value:Int):Void {
		map.set(address, value);
	}

	public function read_from_address(address:Int):Int {
		if(!map.exists(address)) return 0;
		return map.get(address);
	}
}

/*class DisplayFixture extends Screen {
	public var was_cleared:Bool = false;

	public function new() {
		super();
		trace()
	}

	override public function clear_screen() {
		was_cleared = true;
		super.clear_screen();
	}
}*/

class InputFixture implements InputBuffer {
	public var keys:Vector<Bool>;

	public function new() {
		keys = new Vector<Bool>(16);
	}

	public function is_key_pressed(key:Int):Bool {
		return keys[key];
	}
}

class TestCPU extends BuddySuite {
	private function print_exception(e:String) {
		if(e != null) {
			trace(e);
			if(!e.startsWith('Unhandled opcode')) {
				trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			}
		}
	}

	public function new() {
		describe('Using the CPU', {
			var mem:MemoryMapFixture;
			var display:Screen;
			var input:InputFixture;
			var timers:TimerRegisters;
			var cpu:CPU;

			before({
				mem = new MemoryMapFixture();
				display = new Screen();
				input = new InputFixture();
				timers = new TimerRegisters();
				cpu = new CPU(mem, display, input, timers);
			});

			it('should decode and execute \'0nnn - SYS addr\'', {
				print_exception(cpu.run_instruction.bind(0x0000).should.not.throwType(String));
			});
			it('should decode and execute \'00E0 - CLS\'', {
				print_exception(cpu.run_instruction.bind(0x00e0).should.not.throwType(String));
				//display.was_cleared.should.be(true);
				for(b in display.buffer) {
					b.should.be(0);
				}
			});
			it('should decode and execute \'00EE - RET\'', {
				print_exception(cpu.run_instruction.bind(0x00ee).should.not.throwType(String));
			});
			it('should decode and execute \'1nnn - JP addr\'', {
				print_exception(cpu.run_instruction.bind(0x121a).should.not.throwType(String));
				mem.program_counter.should.be(0x021a);
			});
			it('should decode and execute \'2nnn - CALL addr\'', {
				print_exception(cpu.run_instruction.bind(0x2010).should.not.throwType(String));
				var oldaddr:Int = cpu.stack.pop();
				oldaddr.should.be(0x200);
				mem.program_counter.should.be(0x0010);
			});
			it('should decode and execute \'3xkk - SE Vx, byte\'', {
				cpu.registers[0] = 0;
				print_exception(cpu.run_instruction.bind(0x3001).should.not.throwType(String));
				mem.program_counter.should.be(0x200);
				cpu.run_instruction(0x3000);
				mem.program_counter.should.be(0x202);
			});
			it('should decode and execute \'4xkk - SNE Vx, byte\'', {
				cpu.registers[0] = 0;
				print_exception(cpu.run_instruction.bind(0x4000).should.not.throwType(String));
				mem.program_counter.should.be(0x200);
				cpu.run_instruction(0x4001);
				mem.program_counter.should.be(0x202);
			});
			it('should decode and execute \'5xy0 - SE Vx, Vy\'', {
				cpu.registers[0] = 0;
				cpu.registers[1] = 1;
				print_exception(cpu.run_instruction.bind(0x5010).should.not.throwType(String));
				mem.program_counter.should.be(0x200);
				cpu.registers[1] = 0;
				cpu.run_instruction(0x5010);
				mem.program_counter.should.be(0x202);
			});
			it('should decode and execute \'6xkk - LD Vx, byte\'', {
				print_exception(cpu.run_instruction.bind(0x6a02).should.not.throwType(String));
				cpu.registers[0x0a].should.be(0x02);
			});
			it('should decode and execute \'7xkk - ADD Vx, byte\'', {
				cpu.registers[0] = 0;
				print_exception(cpu.run_instruction.bind(0x7005).should.not.throwType(String));
				cpu.registers[0].should.be(5);
			});
			it('should decode and execute \'8xy0 - LD Vx, Vy\'', {
				cpu.registers[0] = 0;
				cpu.registers[1] = 7;
				print_exception(cpu.run_instruction.bind(0x8010).should.not.throwType(String));
				cpu.registers[0].should.be(7);
				cpu.registers[1].should.be(7);
			});
			it('should decode and execute \'8xy1 - OR Vx, Vy\'', {
				cpu.registers[0] = 0x02;
				cpu.registers[1] = 0x05;
				print_exception(cpu.run_instruction.bind(0x8011).should.not.throwType(String));
				cpu.registers[0].should.be(0x02 | 0x05);
				cpu.registers[1].should.be(0x05);
			});
			it('should decode and execute \'8xy2 - AND Vx, Vy\'', {
				cpu.registers[0] = 0x01;
				cpu.registers[1] = 0x05;
				print_exception(cpu.run_instruction.bind(0x8012).should.not.throwType(String));
				cpu.registers[0].should.be(0x01 & 0x05);
				cpu.registers[1].should.be(0x05);
			});
			it('should decode and execute \'8xy3 - XOR Vx, Vy\'', {
				cpu.registers[0] = 0x01;
				cpu.registers[1] = 0x05;
				print_exception(cpu.run_instruction.bind(0x8013).should.not.throwType(String));
				cpu.registers[0].should.be(0x01 ^ 0x05);
				cpu.registers[1].should.be(0x05);
			});
			it('should decode and execute \'8xy4 - ADD Vx, Vy\'', {
				cpu.registers[0] = 100;
				cpu.registers[1] = 242;
				print_exception(cpu.run_instruction.bind(0x8014).should.not.throwType(String));
				cpu.registers[0].should.be(86);
				cpu.registers[1].should.be(242);
				cpu.registers[0x0F].should.be(1);
			});
			it('should decode and execute \'8xy5 - SUB Vx, Vy\'', {
				cpu.registers[0] = 42;
				cpu.registers[1] = 12;
				print_exception(cpu.run_instruction.bind(0x8015).should.not.throwType(String));
				cpu.registers[0].should.be(30);
				cpu.registers[1].should.be(12);
				cpu.registers[0x0F].should.be(1);
			});
			it('should decode and execute \'8xy6 - SHR Vx {, Vy}\'', {
				cpu.registers[0] = 0x05;
				print_exception(cpu.run_instruction.bind(0x8006).should.not.throwType(String));
				cpu.registers[0].should.be(0x02);
				cpu.registers[0x0F].should.be(1);
			});
			it('should decode and execute \'8xy7 - SUBN Vx, Vy\'', {
				cpu.registers[0] = 42;
				cpu.registers[1] = 12;
				print_exception(cpu.run_instruction.bind(0x8017).should.not.throwType(String));
				cpu.registers[0] = 226;
				cpu.registers[1] = 12;
				cpu.registers[0x0F].should.be(0);
			});
			it('should decode and execute \'8xyE - SHL Vx {, Vy}\'', {
				cpu.registers[0] = 226;
				print_exception(cpu.run_instruction.bind(0x801E).should.not.throwType(String));
				cpu.registers[0].should.be(196);
				cpu.registers[0x0F].should.be(1);
			});
			it('should decode and execute \'9xy0 - SNE Vx, Vy\'', {
				cpu.registers[0] = 0;
				cpu.registers[1] = 0;
				print_exception(cpu.run_instruction.bind(0x9010).should.not.throwType(String));
				mem.program_counter.should.be(0x200);
				cpu.registers[1] = 1;
				cpu.run_instruction(0x9010);
				mem.program_counter.should.be(0x202);
			});
			it('should decode and execute \'Annn - LD I, addr\'', {
				print_exception(cpu.run_instruction.bind(0xa042).should.not.throwType(String));
				cpu.index_register.should.be(0x042);
			});
			it('should decode and execute \'Bnnn - JP V0, addr\'', {
				cpu.registers[0] = 4;
				print_exception(cpu.run_instruction.bind(0xB010).should.not.throwType(String));
				mem.program_counter.should.be(0x014);
			});
			it('should decode and execute \'Cxkk - RND Vx, byte\'', {
				print_exception(cpu.run_instruction.bind(0xC0FF).should.not.throwType(String));
			});
			it('should decode and execute \'Dxyn - DRW Vx, Vy, nibble\'', {
				cpu.index_register = 0;
				mem.write_to_address(0, 0x01);
				cpu.registers[0] = 0;
				cpu.registers[1] = 0;
				print_exception(cpu.run_instruction.bind(0xD001).should.not.throwType(String));
				for(i in 0...7) {
					display.get_pixel(i, 0).should.be(false);
				}
				display.get_pixel(7, 0).should.be(true);
			});
			it('should decode and execute \'Ex9E - SKP Vx\'', {
				cpu.registers[1] = 1;
				print_exception(cpu.run_instruction.bind(0xE19E).should.not.throwType(String));
				mem.program_counter.should.be(0x200);
				input.keys[1] = true;
				cpu.run_instruction(0xE19E);
				mem.program_counter.should.be(0x202);
			});
			it('should decode and execute \'ExA1 - SKNP Vx\'', {
				cpu.registers[1] = 1;
				print_exception(cpu.run_instruction.bind(0xE1A1).should.not.throwType(String));
				mem.program_counter.should.be(0x202);
				input.keys[1] = true;
				cpu.run_instruction(0xE1A1);
				mem.program_counter.should.be(0x202);
			});
			it('should decode and execute \'Fx07 - LD Vx, DT\'', {
				timers.delay_timer = 0x42;
				print_exception(cpu.run_instruction.bind(0xF007).should.not.throwType(String));
				cpu.registers[0].should.be(0x42);
			});
			it('should decode and execute \'Fx0A - LD Vx, K\'', {
				//print_exception(cpu.run_instruction.bind(0xF00A).should.not.throwType(String));
			});
			it('should decode and execute \'Fx15 - LD DT, Vx\'', {
				timers.delay_timer.should.be(0);
				cpu.registers[0] = 0x42;
				print_exception(cpu.run_instruction.bind(0xF015).should.not.throwType(String));
				timers.delay_timer.should.be(0x42);
			});
			it('should decode and execute \'Fx18 - LD ST, Vx\'', {
				timers.sound_timer.should.be(0);
				cpu.registers[0] = 0x24;
				print_exception(cpu.run_instruction.bind(0xF018).should.not.throwType(String));
				timers.sound_timer.should.be(0x24);
			});
			it('should decode and execute \'Fx1E - ADD I, Vx\'', {
				cpu.index_register = 27;
				cpu.registers[0] = 5;
				print_exception(cpu.run_instruction.bind(0xF01E).should.not.throwType(String));
				cpu.index_register.should.be(32);
			});
			it('should decode and execute \'Fx29 - LD F, Vx\'', {
				print_exception(cpu.run_instruction.bind(0xF129).should.not.throwType(String));
				cpu.index_register.should.be(0x55);
			});
			it('should decode and execute \'Fx33 - LD B, Vx\'', {
				cpu.index_register = 10;
				cpu.registers[1] = 123;
				print_exception(cpu.run_instruction.bind(0xF133).should.not.throwType(String));
				mem.read_from_address(10).should.be(1);
				mem.read_from_address(11).should.be(2);
				mem.read_from_address(12).should.be(3);
			});
			it('should decode and execute \'Fx55 - LD [I], Vx\'', {
				cpu.index_register = 10;
				for(i in 0...0x0f) {
					cpu.registers[i] = i;
				}
				print_exception(cpu.run_instruction.bind(0xFF55).should.not.throwType(String));
				for(i in 0...0x0f) {
					mem.read_from_address(i + 10).should.be(i);
				}
			});
			it('should decode and execute \'Fx65 - LD Vx, [I]\'', {
				cpu.index_register = 10;
				for(i in 0...0x0f) {
					mem.write_to_address(i + 10, i);
				}
				print_exception(cpu.run_instruction.bind(0xFF65).should.not.throwType(String));
				for(i in 0...0x0f) {
					cpu.registers[i].should.be(i);
				}
			});

			after({
				cpu = null;
				timers = null;
				input = null;
				input = null;
				mem = null;
			});
		});
	}
}
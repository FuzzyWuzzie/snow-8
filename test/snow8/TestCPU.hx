package snow8;

import buddy.*;
using buddy.Should;
import snow8.CPU;

class TestCPU extends BuddySuite {
	public function new() {
		describe('Using the CPU', {
			var cpu:CPU;

			before({
				cpu = new CPU();
			});

			it('should decode \'call RCA 1802\' (0NNN)');
			it('should decode \'clear screen\' (00e0)', {
				var e:String = cpu.run_instruction.bind(0x00e0).should.not.throwType(String);
				trace(e);
			});
			it('should decode \'return\' (00ee)');
			it('should decode \'jump\' (1NNN)');
			it('should decode \'call subroutine\' (2NNN)');
			it('should decode \'skip if equals address\' (3XNN)');
			it('should decode \'skip if not equals address\' (4XNN)');
			it('should decode \'skip if equals register\' (5XY0)');
			it('should decode \'set to address\' (6XNN)');
			it('should decode \'add address to register\' (7XNN)');
			it('should decode \'set register to register\' (8XY0)');
			it('should decode \'set register to register OR register\' (8XY1)');
			it('should decode \'set register to register AND register\' (8XY2)');
			it('should decode \'set register to register XOR register\' (8XY3)');
			it('should decode \'add register to register\' (8XY4)');
			it('should decode \'subtract register from register\' (8XY5)');
			it('should decode \'shift register right\' (8XY6)');
			it('should decode \'set register to register minus register\' (8XY7)');
			it('should decode \'shift register left\' (8XYe)');
			it('should decode \'skip if register doesn\'t equal register\' (9XY0)');
			it('should decode \'set index register to address\' (aNNN)', {
				var e:String = cpu.run_instruction.bind(0xa000).should.not.throwType(String);
				trace(e);
			});
			it('should decode \'jump to address plus register\' (bNNN)');
			it('should decode \'set register to bit and random and address\' (cXNN)');
			it('should decode \'\' (dXYN)');
			it('should decode \'skip if key in register is pressed\' (eX9e)');
			it('should decode \'skip if key in register isn\'t pressed\' (eXa1)');
			it('should decode \'set register to delay timer\' (fX07)');
			it('should decode \'wait for key press, then store in register\' (fX0a)');
			it('should decode \'set delay timer to register\' (fX15)');
			it('should decode \'set sound timer to register\' (fX18)');
			it('should decode \'add register to index register\' (fX1e)');
			it('should decode \'set index register to location of the sprite\' (fX29)');
			it('should decode \'store the BCD of register\' (fX33)');
			it('should decode \'set v0 to register in memory starting at index register\' (fX55)');
			it('should decode \'fill registers with values from memory\' (fX65)');

			after({
				cpu = null;
			});
		});
	}
}
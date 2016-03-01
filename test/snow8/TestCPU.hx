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

			it('should decode \'clear screen\'');

			after({
				cpu = null;
			});
		});
	}
}
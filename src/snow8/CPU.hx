package snow8;

import snow.api.buffers.Uint8Array;

class CPU {
	private var registers:Uint8Array;

	public function new() {
		this.registers = new Uint8Array(0, null, null, null, 0, 16);
	}
}
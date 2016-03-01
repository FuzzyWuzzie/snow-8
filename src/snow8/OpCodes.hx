package snow8;

@:enum
abstract OpCodes(Int) {
	var CLSRETSYS = 0x0000;
	var JP = 0x1000;
	var CALL = 0x2000;
	var SE = 0x3000;
	var SNE = 0x4000;
	var SE_REG = 0x5000;
	var LD = 0x6000;
}
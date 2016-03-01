package snow8;

@:enum
abstract OpCodes(Int) {
	var GRP_SYS      = 0x0000;
	var SYS_ADDR     = 0x0000;
	var CLS          = 0x00E0;
	var RET          = 0x00EE;
	var JP_ADDR      = 0x1000;
	var CALL_ADDR    = 0x2000;
	var SE_BYTE      = 0x3000;
	var SNE_BYTE     = 0x4000;
	var SE_REG       = 0x5000;
	var LD_BYTE      = 0x6000;
	var ADD_BYTE     = 0x7000;
	var GRP_MATH     = 0x8000;
	var LD_REG       = 0x8000;
	var OR_REG       = 0x8001;
	var AND_REG      = 0x8002;
	var XOR_REG      = 0x8003;
	var ADD_REG      = 0x8004;
	var SUB_REG      = 0x8005;
	var SHR_REG      = 0x8006;
	var SUBN_REG     = 0x8007;
	var SHL_REG      = 0x800E;
	var SNE_REG      = 0x9000;
	var LD_ADDR      = 0xA000;
	var JP_ADDR_OFFS = 0xB000;
	var RND_BYTE     = 0xC000;
	var DRW_NIBBLE   = 0xD000;
	var GRP_SKP      = 0xE000;
	var SKP_REG      = 0xE09E;
	var SKNP_REG     = 0xE0A1;
	var GRP_LD       = 0xF000;
	var LD_REG_DT    = 0xF007;
	var LD_REG_K     = 0xF00A;
	var LD_DT_REG    = 0xF015;
	var LD_ST_REG    = 0xF018;
	var ADD_I_REG    = 0xF01E;
	var LD_F_REG     = 0xF029;
	var LD_B_REG     = 0xF033;
	var LD_I_REG     = 0xF055;
	var LD_REG_I     = 0xF065;
}
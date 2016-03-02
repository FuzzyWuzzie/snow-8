import snow.types.Types;
import snow.modules.opengl.GL;
import snow8.Chip8;
import debug.Log;
import debug.Assert;

typedef UserConfig = {
	var rom:String;
}

class Main extends snow.App {
	private var chip8:Chip8 = null;

	function new() {}

	override function config(config:AppConfig): AppConfig {
		config.window.title = 'snow-8';
		return config;
	}

	override function ready() {
		// start loading a ROM!
		Assert.assert(app.config.user.rom != null);
		var asset:snow.api.Promise = app.assets.bytes('assets/ROMs/${app.config.user.rom}');
		asset.then(function(asset:AssetBytes) {
			Log.info('loaded ${asset.bytes.length} bytes from ${app.config.user.rom}!');

			// create our virtual machine
			chip8 = new Chip8(asset.bytes);
		});
	}

	override function onkeyup(keycode:Int, _,_, mod:ModState, _,_) {
		if(keycode == Key.escape) {
			app.shutdown();
		}
	} 

	override function tick(delta:Float) {
		GL.clearColor(0.0, 0.0, 0.0, 1.0);
		GL.clear(GL.COLOR_BUFFER_BIT);

		if(chip8 != null) {
			chip8.tick(delta);
		}

		// TODO: separate rendering + emulation
		// TODO: rendering
		// TODO: input
	}

}
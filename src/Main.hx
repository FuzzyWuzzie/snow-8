import snow.api.Debug.*;
import snow.types.Types;
import snow.modules.opengl.GL;
import snow8.Chip8;

typedef UserConfig = {
	var rom:String;
}

@:log_as('app')
class Main extends snow.App {
	function new() {}

	override function config(config:AppConfig): AppConfig {
		config.window.title = 'snow-8';
		return config;
	}

	override function ready() {
		log('ready');

		// start loading a ROM!
		assert(app.config.user.rom != null);
		var asset:snow.api.Promise = app.assets.bytes('assets/ROMs/${app.config.user.rom}');
		asset.then(function(asset:AssetBytes) {
			log('loaded ${asset.bytes.length} bytes from ${app.config.user.rom}!');

			// create our virtual machine
			var chip8:Chip8 = new Chip8(asset.bytes);
		});
	}

	override function onkeyup(keycode:Int, _,_, mod:ModState, _,_) {
		if(keycode == Key.escape) {
			app.shutdown();
		}
	} 

	override function tick(delta:Float) {
		GL.clearColor(1.0, 1.0, 1.0, 1.0);
		GL.clear(GL.COLOR_BUFFER_BIT);
	}

}
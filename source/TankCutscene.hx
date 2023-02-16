package;

import flixel.FlxSprite;
import flixel.system.FlxSound;

class TankCutscene extends FlxSprite
{
	public var startSyncAudio:FlxSound;

	public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	var startedPlayingSound:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

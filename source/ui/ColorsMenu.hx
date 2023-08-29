package ui;

import flixel.FlxG;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

using StringTools;

typedef Colors = {
	var purple:String;
	var blue:String;
	var green:String;
	var red:String;
}

class ColorsMenu extends ui.OptionsState.Page
{
	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

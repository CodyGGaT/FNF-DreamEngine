package;

import flixel.FlxState;
import flixel.FlxG;

class ModifiersState extends FlxState
{
    override public function create():Void
    {
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
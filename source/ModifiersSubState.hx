package;

import flixel.FlxState;
import flixel.FlxG;

class ModifiersSubState extends FlxState
{
    var checkboxes:Array<CheckboxThingie> = [];
    override public function create():Void
    {
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        super.create();
    }

    function prefToggle(prefName:String)
        {
            var daSwap:Bool = preferences.get(prefName);
            daSwap = !daSwap;
            preferences.set(prefName, daSwap);
            checkboxes[items.selectedIndex].daValue = daSwap;
            trace('toggled? ' + preferences.get(prefName));
        }

    function createCheckbox(prefString:String)
    {
        var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(prefString));
        checkboxes.push(checkbox);
        add(checkbox);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}
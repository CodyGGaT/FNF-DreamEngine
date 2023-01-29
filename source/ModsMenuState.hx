package;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ds.EnumValueMap;

class ModsMenuState extends MusicBeatState
{
	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFEA71FD;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);
		var optionsmenu:OptionsMenu = addPage(Options, new OptionsMenu(false));
		var preferencesmenu:PreferencesMenu = addPage(Preferences, new PreferencesMenu());
		var controlsmenu:ControlsMenu = addPage(Controls, new ControlsMenu());
		if (optionsmenu.hasMultipleOptions())
		{
			optionsmenu.onExit.add(exitToMainMenu);
			controlsmenu.onExit.add(function()
			{
				switchPage(Options);
			});
			preferencesmenu.onExit.add(function()
			{
				switchPage(Options);
			});
		}
		else
		{
			controlsmenu.onExit.add(exitToMainMenu);
			setPage(Controls);
		}
		super.create();
	}

	override function finishTransIn()
	{
		super.finishTransIn();
		currentPage.enabled = true;
	}

	function exitToMainMenu()
	{
		currentPage.enabled = false;
		FlxG.switchState(new MainMenuState());
	}
}
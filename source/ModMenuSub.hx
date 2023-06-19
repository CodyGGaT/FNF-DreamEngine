package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import openfl.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class ModMenuSub extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String>;

	public static var modsEnabled:Array<String> = [];

	var curSelected:Int = 0;

	public static var inMod:Bool = true;
	
	public function new(x:Float, y:Float)
	{
		super();

		var bg = new FlxSprite(0, 0);
		bg.scrollFactor.set();
		bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.3;
		add(bg);

		#if html5
		menuItems = ['imagine being on html5'];
		#end

		#if sys
		if (FileSystem.exists('./mods') && FileSystem.isDirectory('./mods'))
		{
			trace('mods loaded');
			var modsInDaFolder = [];
			for (file in FileSystem.readDirectory("./mods")) {
				if (FileSystem.isDirectory(FileSystem.absolutePath("mods/" + file)))
					modsInDaFolder.push(file);
			}
			menuItems = (modsInDaFolder.length > 0) ? modsInDaFolder : ['no mods'];
		}
		else
		{
			FileSystem.createDirectory('./mods');
			menuItems = ['No mods'];
		}
		#end

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	private function regenMenu():Void
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.scrollFactor.set();
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			if (modsEnabled != null)
			{
				if (!modsEnabled.contains(daSelected))
					modsEnabled.push(daSelected);
				else
					modsEnabled.remove(daSelected);
			}
			else
				modsEnabled = [daSelected];

			#if sys
			File.saveContent('./mods/modList.txt', modsEnabled.toString());
			#end
		}

		if (FlxG.keys.justPressed.ESCAPE)
			close();
	}

	override function close()
	{
		super.close();
		inMod = false;
		#if sys
		polymod.Polymod.init({
			modRoot: "mods",
			dirs: CoolUtil.coolStringFile(sys.io.File.getContent('./mods/modList.txt')),
			errorCallback: (e) ->
			{
				trace(e.message);
			},
			frameworkParams: {
				assetLibraryPaths: [
					"songs" => "assets/songs",
					"images" => "assets/images",
					"shared" => "assets/shared",
					"data" => "assets/data",
					"characters" => "assets/characters",
					"fonts" => "assets/fonts",
					"sounds" => "assets/sounds",
					"music" => "assets/music",
					"tutorial" => "assets/tutorial",
					"week1" => "assets/week1",
					"week2" => "assets/week2",
					"week3" => "assets/week3",
					"week4" => "assets/week4",
					"week5" => "assets/week5",
					"week6" => "assets/week6",
					"week7" => "assets/week7",
				]
			}
		});
		#end
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
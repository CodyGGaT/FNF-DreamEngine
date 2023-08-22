package ui;

import ui.OptionsState.OptionsMenu;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class ToolboxState extends MusicBeatState {
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var menuItems:Array<String> = ['Chart Editor', 'Character Editor', 'Stage Editor'];
	var curSelected:Int = 0;

	override function create() {
		var bg:FlxSprite = new FlxSprite(-80, 0, Paths.image("menuDesat"));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF0000ff;
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case 'Chart Editor':
					FlxG.switchState(new editors.ChartingState());
				case 'Character Editor':
					FlxG.switchState(new editors.CharacterEditorState('dad'));
				case 'Stage Editor': //brandon u better fucking code this shit
					FlxG.switchState(new editors.StageEditorState());
			}
		}

		if (controls.BACK)
			FlxG.switchState(new OptionsState());
	}

	private function regenMenu():Void {
		while (grpMenuShit.members.length > 0) {
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}

	function changeSelection(change:Int = 0):Void {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}
}

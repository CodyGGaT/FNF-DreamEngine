package editors;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
#if discord_rpc
import Discord.DiscordClient;
#end

using StringTools;

/**
	*DEBUG MODE
 */
class CharacterEditorState extends FlxState
{
	var bf:Boyfriend;
	var dad:Character;
	var char:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;
	var UI_box:FlxUITabMenu;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Character Editor", null);
		#end

		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;
		FlxG.mouse.enabled = true;

		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('breakfast'));
		}

		if (daAnim.startsWith('bf'))
			isDad = false;

		if (isDad)
		{
			var dads = new Character(0, 0, daAnim);
			dads.color = 0xff000000;
			dads.alpha = 0.3;
			dads.screenCenter();
			dads.debugMode = true;
			add(dads);

			dad = new Character(0, 0, daAnim);
			dad.screenCenter();
			dad.debugMode = true;
			add(dad);

			char = dad;
			dad.flipX = false;
		}
		else
		{
			var bfs = new Character(0, 0, daAnim);
			bfs.color = 0xff000000;
			bfs.alpha = 0.3;
			bfs.screenCenter();
			bfs.debugMode = true;
			add(bfs);
			
			bf = new Boyfriend(0, 0, daAnim);
			bf.screenCenter();
			bf.debugMode = true;
			add(bf);

			char = bf;
			bf.flipX = false;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.setFormat(Paths.font("funkin.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textAnim.size = 26;
		textAnim.scrollFactor.set();
		add(textAnim);

		var tabs = [
			{name: "Character", label: 'Character'},
			{name: "Animations", label: 'Animations'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 300);
		UI_box.x = FlxG.width / 1.35;
		UI_box.y = 20;
		add(UI_box);

		charTabShit();
		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(Paths.font("funkin.ttf"), 16, FlxColor.BLUE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.scrollFactor.set();
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new PlayState());

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim]);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

	if (FlxG.keys.justPressed.F1) {
			var outputString:String = "";

			for (swagAnim in animList)
			{
				outputString += swagAnim + " " + char.animOffsets.get(swagAnim)[0] + " " + char.animOffsets.get(swagAnim)[1] + "\n";
			}

			outputString.trim();
			saveOffsets(outputString);
		};

		super.update(elapsed);
	}

	function saveChar()
	{
		var char = {
			"img": char.Char.img,
			"hpColor": char.Char.hpColor,
			"anims": char.Char.anims
		};

		for (animOffset in animList)
			{
				for (anim in char.anims)
				{
					if (anim.anim == animOffset)
					{
						anim.X = this.char.animOffsets.get(animOffset)[0];
						anim.Y = this.char.animOffsets.get(animOffset)[1];
					}
				}
			}

		var data:String = haxe.Json.stringify(char);

		if ((data != null) && (data.length > 0))
		{
			var file = new FileReference();

			file.save(data, daAnim + '.json');
		}
	}

	var _file:FileReference;

	private function saveOffsets(saveString:String)
	{
		if ((saveString != null) && (saveString.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(saveString, daAnim + "Offsets.txt");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function charTabShit()
	{
		var charUI = new FlxUI(null, UI_box);
		charUI.name = 'Character';

		var saveChar = new FlxButton(10, 30, 'Save Character', function()
		{
			saveChar();
		});
		charUI.add(saveChar);

		var hpBar = new FlxSprite(110, 210).loadGraphic(Paths.image('healthBar'));
		hpBar.scale.x = 0.3;
		charUI.add(hpBar);

		var hpBarFill = new FlxSprite(hpBar.x + 211.64, hpBar.y + 5).makeGraphic(177, 9, char.hpColor);
		charUI.add(hpBarFill);

	}
}

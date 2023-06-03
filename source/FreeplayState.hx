package;

import flixel.FlxSubState;
#if discord_rpc
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	// var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var coolColors:Array<FlxColor> = [];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	var bg:FlxSprite;
	var scoreBG:FlxSprite;

	override function create()
	{
		#if discord_rpc
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		ModMenuSub.inMod = false;

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if (openfl.Assets.exists(Paths.txt('freeplaySonglist')))
		{
			for (i in 0...initSonglist.length)
			{
				var data:Array<String> = initSonglist[i].split(':');

				addSong(data[0], Std.parseInt(data[1]), data[2], FlxColor.fromString(data[3]), data[4]);
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			coolColors.push(songs[i].color);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0x99000000);
		scoreBG.antialiasing = false;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:FlxColor, diffs:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, diffs));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?color:FlxColor, ?diffs:String)
	{
		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num], color, diffs);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.TAB && !ModMenuSub.inMod)
			openSubState(new ModMenuSub(0, 0));

		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.7)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);
		bg.color = FlxColor.interpolate(bg.color, coolColors[curSelected % coolColors.length], CoolUtil.camLerpShit(0.045));

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);

		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP && !ModMenuSub.inMod){
			changeSelection(-1);
			if (songs[curSelected].songName == '')
				changeSelection(-1);
		}

		if (downP && !ModMenuSub.inMod){
			changeSelection(1);
			if (songs[curSelected].songName == '')
				changeSelection(1);
		}

		if (FlxG.mouse.wheel != 0 && !ModMenuSub.inMod)
			changeSelection(Math.round(FlxG.mouse.wheel / 7));

		if (controls.UI_LEFT_P && !ModMenuSub.inMod)
			changeDiff(-1);
		if (controls.UI_RIGHT_P && !ModMenuSub.inMod)
			changeDiff(1);

		if (controls.BACK && !ModMenuSub.inMod)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (accepted && !ModMenuSub.inMod)
		{
			trace(CoolUtil.difficultyString().toLowerCase());

			if (Assets.exists('assets/data/${songs[curSelected].songName.toLowerCase()}/${songs[curSelected].songName.toLowerCase()}-${CoolUtil.difficultyString().toLowerCase()}.json') || CoolUtil.difficultyString().toLowerCase() == 'normal' && Assets.exists('assets/data/${songs[curSelected].songName.toLowerCase()}/${songs[curSelected].songName.toLowerCase()}.json')) {
				var poop = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.storyDifficulty = curDifficulty;
				PlayState.isStoryMode = false;
				PlayState.storyWeek = songs[curSelected].week;
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				LoadingState.loadAndSwitchState(new PlayState());
		}else{
			FlxG.game.stage.window.alert('hey looks like ${songs[curSelected].songName.toLowerCase()} doesnt have a json is it just this difficulty?', 'Dream Engine Crash Handler');
		}
	}
}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyString().length - 2;
		if (curDifficulty > CoolUtil.difficultyString().length - 2)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		PlayState.storyDifficulty = curDifficulty;

		diffText.text = "< " + CoolUtil.difficultyString() + " >";
		positionHighscore();

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		trace(curDifficulty);
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		CoolUtil.difficultyArray = songs[curSelected].diffs.toString().split(',');
		diffText.text = "< " + CoolUtil.difficultyString() + " >";
		positionHighscore();

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

	function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - scoreBG.scale.x / 2;

		diffText.x = Std.int(scoreBG.x + scoreBG.width / 2);
		diffText.x -= (diffText.width / 2);
	}

	override function openSubState(SubState:FlxSubState)
	{
		super.openSubState(SubState);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:FlxColor;
	public var diffs:String;

	public function new(song:String, week:Int, songCharacter:String, Color:FlxColor, diffss:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = Color;
		this.diffs = diffss;
	}
}
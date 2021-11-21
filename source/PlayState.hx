package;

import openfl.display.ShaderInput;
import haxe.iterators.StringIterator;
import BlendModeEffect.BlendModeShader;
import flixel.math.FlxRandom;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.media.Video;
import Achievements;
import Random;
import openfl.display.BlendMode;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.helpers.FlxPointRangeBounds;
import flixel.addons.display.FlxPieDial;
import flixel.addons.display.FlxPieDial.FlxPieDialShape;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	]; 

	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var gf2:Character;
	private var gf3:Character;
	private var boyfriend:Boyfriend;
	private var girlfriend:Boyfriend;
	private var viobot:Character;
	private var cardinal:Character;
	private var pistachio:Character;
	private var azura:Character;
	private var banana:Character;

	private var crystalRed:FlxSprite;
	private var crystalYellow:FlxSprite;
	private var crystalGreen:FlxSprite;
	private var crystalBlue:FlxSprite;
	private var crystalViolet:FlxSprite;

	private var stageDarkness:FlxSprite;
	private var floodLights:FlxSprite;
	private var stageDarknessWhole:FlxSprite;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var eventNotes:Array<Dynamic> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	private var strumLineNotes:FlxTypedGroup<StrumNote>;
	private var playerStrums:FlxTypedGroup<StrumNote>;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarP1:FlxSprite;
	private var healthBarP2:FlxSprite;
	private var healthBarP1Split:FlxSprite;
	private var healthBarP2Split:FlxSprite;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var healthBarMarker:FlxSprite;
	private var healthBarCover:FlxSprite;
	private var shieldIcon:FlxSprite;
	var songPercent:Float = 0;
	var shieldOn:Bool = false;
	var shieldTimer:FlxPieDial;

	private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camDialog:FlxCamera;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var halloweenWhite:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var phillyBlack:FlxSprite;
	var phillyCityLightsEvent:FlxTypedGroup<FlxSprite>;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:FlxSprite;
	var limoMetalPole:FlxSprite;
	var limoLight:FlxSprite;
	var limoCorpse:FlxSprite;
	var limoCorpseTwo:FlxSprite;
	var bgLimo:FlxSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var heyTimer:Float;
	var lights:FlxSprite;
	var speakers:FlxSprite;
	var crowd:FlxSprite;
	var podium:FlxSprite;
	var podiumBroken:FlxSprite;
	var vioDisc:FlxSprite;
	var bfDisc:FlxSprite;
	var gfDisc:FlxSprite;
	var harmonyWhite:FlxSprite;
	var templeLight:FlxSprite;
	var templeDark:FlxSprite;
	var templePurple:FlxSprite;
	var templeFogB:FlxSprite;
	var templeFogP:FlxSprite;
	var emitter:FlxEmitter;
	var emitter2:FlxEmitter;
	var vines:FlxSprite;
	var foregrObj:FlxSprite;
	var leaves:FlxSprite;
	var leavesShadow:FlxSprite;
	var bfFly:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var bgGhouls:BGSprite;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songHits:Int = 0;
	var songMisses:Int = 0;
	var scoreTxt:FlxText;
	var timeTxt:FlxText;

	var animModulo:Int = 0;
	var doFloodLights:Bool = false;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var centerCamera:Bool = false;
	var gfArray:Array<Character> = [];

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	var songLength:Float = 0;
	public static var displaySongName:String = "";

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	var crystalWave:Float = 0;
	var crystalWaveYellow:Float = 0;
	var crystalWaveBlue:Float = 0;
	var crystalWaveViolet:Float = 0;
	var crystalWaveGreen:Float = 0;

	var vibrantsRate:Float = 1;

	var hideHealth:Bool = false;
	var holdOnP1:Bool = false;
	var holdOnP2:Bool = false;

	public static var keys:Int = 4;

	var followWho = null;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camDialog = new FlxCamera();
		camAchievement = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camDialog.bgColor.alpha = 0;
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camDialog);
		FlxG.cameras.add(camAchievement);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		keys = SONG.keys;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		var songName:String = SONG.song;
		displaySongName = StringTools.replace(songName, '-', ' ');

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Vibrant";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			switch (storyWeek) {
				case 1:
					detailsText = "Story Mode: Violastro";
				case 2:
					detailsText = "Story Mode: Vibrants";
				default:
					detailsText = "Story Mode: Week " + storyWeek;
			}
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
			case 'bwehehe' | 'stupefy' | 'supernova' | 'the-ups-and-downs' | 'psychic': {
				defaultCamZoom = 0.45;
				if (SONG.song == 'Psychic') defaultCamZoom = 0.75;
				curStage = 'arena';

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('bgWall'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.3, 0.3);
				bg.active = false;
				add(bg);

				if (SONG.song != 'Psychic') {
					if (!ClientPrefs.lowQuality) {
						speakers = new FlxSprite(-1000, -500);
						speakers.frames = Paths.getSparrowAtlas('violastroSpeakers');
						speakers.animation.addByPrefix('bounce', 'speakersBounce', 24, false);
						speakers.antialiasing = ClientPrefs.globalAntialiasing;
						speakers.scrollFactor.set(0.25, 0.25);
						add(speakers);
		
						crowd = new FlxSprite(-1000, -500);
						crowd.frames = Paths.getSparrowAtlas('stageCrowd');
						crowd.animation.addByPrefix('bop', 'crowdBop', 24, false);
						crowd.antialiasing = ClientPrefs.globalAntialiasing;
						crowd.scrollFactor.set(0.33, 0.33);
						add(crowd);
					}
				}

				var balcony:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('balconies'));
				balcony.antialiasing = ClientPrefs.globalAntialiasing;
				balcony.scrollFactor.set(0.3, 0.3);
				balcony.active = false;
				add(balcony);

				if (SONG.song != 'Psychic') {
					if (!ClientPrefs.lowQuality) {
						lights = new FlxSprite(-1000, -600);
						lights.frames = Paths.getSparrowAtlas('violastroLights');
						lights.animation.addByPrefix('flash', 'lightsFlash', 24, false);
						lights.antialiasing = ClientPrefs.globalAntialiasing;
						lights.scrollFactor.set(0.5, 0.5);
						add(lights);
					}
				}

				// Particles

				emitter = new FlxEmitter(-1000, 1000);
				for (i in 0...1000) { // Might be a bit of a large number, dunno.
					var p = new FlxParticle();
					p.makeGraphic(40, 40, 0xFFFFFFFF);
					p.exists = false;
					emitter.add(p);
				}
				emitter.launchMode = FlxEmitterMode.SQUARE;
				emitter.setSize(3200, 100); // Don't ask, that's just the size LMAO
				emitter.velocity.start.min.x = -40;
				emitter.velocity.start.max.x = 40;
				emitter.velocity.start.min.y = -100;
				emitter.velocity.start.max.y = -600;
				emitter.alpha.set(1, 1, 0, 0);
				emitter.color.set(FlxColor.WHITE, FlxColor.YELLOW, FlxColor.PURPLE, FlxColor.MAGENTA);
				if (SONG.song == 'Psychic') emitter.color.set(FlxColor.BLUE, FlxColor.PURPLE, FlxColor.PURPLE, FlxColor.BLUE);
				emitter.scale.set(1, 1, 2, 2, 0, 0, 0, 0);
				emitter.blend = BlendMode.ADD;
				emitter.start(false, 0.05);
				if (SONG.song != 'Psychic') add(emitter);

				// Particles End

				stageDarknessWhole = new FlxSprite(-2000, -1000).makeGraphic(Std.int(FlxG.width * 4), Std.int(FlxG.height * 4), FlxColor.BLACK);
				stageDarknessWhole.antialiasing = ClientPrefs.globalAntialiasing;
				stageDarknessWhole.active = false;
				stageDarknessWhole.alpha = 0.001;
				add(stageDarknessWhole);

				if (SONG.song == 'Psychic')
					stageDarknessWhole.alpha = 0.85;
					add(emitter);

				podium = new FlxSprite(-875, -500).loadGraphic(Paths.image('violastroPodium'));
				podium.antialiasing = ClientPrefs.globalAntialiasing;
				podium.active = false;
				add(podium);

				if (SONG.song == 'Supernova') {
					//podiumBroken = new FlxSprite(-875, -500).loadGraphic(Paths.image('arena/violastroPodiumBusted'));
					//podiumBroken.antialiasing = ClientPrefs.globalAntialiasing;
					//podiumBroken.active = false;
					//add(podiumBroken);
					//podiumBroken.alpha = 0.001;

					vioDisc = new FlxSprite(-650, 600);
					vioDisc.frames = Paths.getSparrowAtlas('violastroDisc');
					vioDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
					vioDisc.antialiasing = ClientPrefs.globalAntialiasing;
					vioDisc.animation.play('spin');
					add(vioDisc);
					vioDisc.alpha = 0.001;

					gfDisc = new FlxSprite(1100, 300);
					gfDisc.frames = Paths.getSparrowAtlas('violastroDisc');
					gfDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
					gfDisc.antialiasing = ClientPrefs.globalAntialiasing;
					gfDisc.scrollFactor.set(0.95, 0.95);
					gfDisc.animation.play('spin');
					add(gfDisc);
					gfDisc.alpha = 0.001;

					bfDisc = new FlxSprite(1300, 600);
					bfDisc.frames = Paths.getSparrowAtlas('violastroDisc');
					bfDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
					bfDisc.antialiasing = ClientPrefs.globalAntialiasing;
					bfDisc.animation.play('spin');
					add(bfDisc);
					bfDisc.alpha = 0.001;
				}

				if (SONG.song == 'The-Ups-and-Downs') {
					defaultCamZoom = 0.55;
					podium.alpha = 0.001;
					podium.y += 10000;

					gfDisc = new FlxSprite(200, 300);
					gfDisc.frames = Paths.getSparrowAtlas('violastroDisc');
					gfDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
					gfDisc.antialiasing = ClientPrefs.globalAntialiasing;
					gfDisc.scrollFactor.set(0.95, 0.95);
					gfDisc.animation.play('spin');
					add(gfDisc);

					bfDisc = new FlxSprite(1000, 600);
					bfDisc.frames = Paths.getSparrowAtlas('violastroDisc');
					bfDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
					bfDisc.antialiasing = ClientPrefs.globalAntialiasing;
					bfDisc.animation.play('spin');
					add(bfDisc);
				}
				
				stageDarkness = new FlxSprite(-2000, -600).loadGraphic(Paths.image('stageDarkness'));
				stageDarkness.antialiasing = ClientPrefs.globalAntialiasing;
				stageDarkness.scrollFactor.set(0.3, 0.3);
				stageDarkness.setGraphicSize(Std.int(stageDarkness.width * 2));
				stageDarkness.updateHitbox();
				stageDarkness.alpha = 0.001;

				floodLights = new FlxSprite(-1100, -800).loadGraphic(Paths.image('violastroSideLights'));
				floodLights.antialiasing = ClientPrefs.globalAntialiasing;
				floodLights.scrollFactor.set(0.5, 0.5);
				floodLights.setGraphicSize(Std.int(floodLights.width * 1.1));
				floodLights.updateHitbox();
				floodLights.alpha = 0.001;
				floodLights.blend = BlendMode.ADD;

				// Particles

				emitter2 = new FlxEmitter(-1000, -800);
				for (i in 0...2000) {
					var p = new FlxParticle();
					p.makeGraphic(40, 40, 0xFFFFFFFF);
					p.exists = false;
					emitter2.add(p);
				}
				emitter2.launchMode = FlxEmitterMode.SQUARE;
				emitter2.setSize(4000, 4000);
				emitter2.velocity.start.min.x = -80;
				emitter2.velocity.start.max.x = 80;
				emitter2.velocity.start.min.y = -80;
				emitter2.velocity.start.max.y = 80;
				emitter2.alpha.set(1, 1, 0, 0);
				emitter2.color.set(FlxColor.WHITE, FlxColor.WHITE, FlxColor.WHITE, FlxColor.WHITE);
				emitter2.scale.set(1, 1, 1.5, 1.5, 0, 0, 0, 0);
				emitter2.blend = BlendMode.ADD;
				emitter2.start(false, 0.05);
				emitter2.emitting = false;

				// Particles End
			}

			case 'harmony' | 'tutorial': {
				defaultCamZoom = 1.25;
				//defaultCamZoom = 0.5125;
				curStage = 'temple';

				var bg:FlxSprite = new FlxSprite(-1300, -1375).loadGraphic(Paths.image('harmony/templeWall'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.95, 0.95);
				bg.active = false;
				add(bg);

				var floor:FlxSprite = new FlxSprite(-1300, 300).loadGraphic(Paths.image('harmony/templeFloor'));
				floor.antialiasing = ClientPrefs.globalAntialiasing;
				floor.scrollFactor.set(0.95, 0.95);
				floor.active = false;
				add(floor);

				var backPillars:FlxSprite = new FlxSprite(-1125, -1250).loadGraphic(Paths.image('harmony/templeBack'));
				backPillars.antialiasing = ClientPrefs.globalAntialiasing;
				backPillars.scrollFactor.set(0.9, 0.9);
				backPillars.active = false;
				add(backPillars);

				var crystalPillars:FlxSprite = new FlxSprite(-500, -200).loadGraphic(Paths.image('harmony/templePillars'));
				crystalPillars.antialiasing = ClientPrefs.globalAntialiasing;
				crystalPillars.scrollFactor.set(0.95, 0.95);
				crystalPillars.active = false;
				add(crystalPillars);

				crystalRed = new FlxSprite(-660, -775);
				crystalRed.frames = Paths.getSparrowAtlas('harmony/powerCrystalFire');
				crystalRed.animation.addByPrefix('spin', 'Power Crystal Fire', 24, true);
				crystalRed.animation.play('spin', false, FlxG.random.bool());
				crystalRed.antialiasing = ClientPrefs.globalAntialiasing;
				crystalRed.scrollFactor.set(0.95, 0.95);
				add(crystalRed);
				
				crystalGreen = new FlxSprite(-115, -725);
				crystalGreen.frames = Paths.getSparrowAtlas('harmony/powerCrystalLeaf');
				crystalGreen.animation.addByPrefix('spin', 'Power Crystal Leaf', 24, true);
				crystalGreen.animation.play('spin', false, FlxG.random.bool());
				crystalGreen.antialiasing = ClientPrefs.globalAntialiasing;
				crystalGreen.scrollFactor.set(0.95, 0.95);
				add(crystalGreen);
				
				crystalViolet = new FlxSprite(450, -675);
				crystalViolet.frames = Paths.getSparrowAtlas('harmony/powerCrystalStar');
				crystalViolet.animation.addByPrefix('spin', 'Power Crystal Star', 24, true);
				crystalViolet.animation.play('spin', false, FlxG.random.bool());
				crystalViolet.antialiasing = ClientPrefs.globalAntialiasing;
				crystalViolet.scrollFactor.set(0.95, 0.95);
				add(crystalViolet);
				
				crystalYellow = new FlxSprite(1000, -725);
				crystalYellow.frames = Paths.getSparrowAtlas('harmony/powerCrystalEarth');
				crystalYellow.animation.addByPrefix('spin', 'Power Crystal Earth', 24, true);
				crystalYellow.animation.play('spin', false, FlxG.random.bool());
				crystalYellow.antialiasing = ClientPrefs.globalAntialiasing;
				crystalYellow.scrollFactor.set(0.95, 0.95);
				add(crystalYellow);
				
				crystalBlue = new FlxSprite(1550, -775);
				crystalBlue.frames = Paths.getSparrowAtlas('harmony/powerCrystalWater');
				crystalBlue.animation.addByPrefix('spin', 'Power Crystal Water', 24, true);
				crystalBlue.animation.play('spin', false, FlxG.random.bool());
				crystalBlue.antialiasing = ClientPrefs.globalAntialiasing;
				crystalBlue.scrollFactor.set(0.95, 0.95);
				add(crystalBlue);

				bfDisc = new FlxSprite(1000, 200);
				bfDisc.frames = Paths.getSparrowAtlas('violastroDisc');
				bfDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
				bfDisc.animation.play('spin');
				bfDisc.antialiasing = ClientPrefs.globalAntialiasing;

				templeLight = new FlxSprite(-875, -1000).loadGraphic(Paths.image('light'));
				templeLight.antialiasing = ClientPrefs.globalAntialiasing;
				templeLight.scrollFactor.set(0.9, 0.9);
				templeLight.active = false;
				templeLight.alpha = 0.65;
				templeLight.blend = BlendMode.ADD;

				// Particles

				emitter = new FlxEmitter(-1300, -1275);
				for (i in 0...1000) {
					var p = new FlxParticle();
					p.makeGraphic(15, 15, 0xFFFFFFFF);
					p.exists = false;
					emitter.add(p);
				}
				emitter.launchMode = FlxEmitterMode.SQUARE;
				emitter.setSize(4000, 4000);
				emitter.velocity.start.min.x = -40;
				emitter.velocity.start.max.x = 40;
				emitter.velocity.start.min.y = -40;
				emitter.velocity.start.max.y = 40;
				emitter.alpha.set(1, 1, 0, 0);
				emitter.color.set(FlxColor.WHITE, FlxColor.WHITE, FlxColor.WHITE, FlxColor.WHITE);
				emitter.scale.set(1, 1, 1.5, 1.5, 0, 0, 0, 0);
				emitter.blend = BlendMode.ADD;
				emitter.start(false, 0.0375);

				// Particles End
			
				/*
				stageDarkness = new FlxSprite(-1000, -600).loadGraphic(Paths.image('arena/stageDarkness'));
				stageDarkness.antialiasing = ClientPrefs.globalAntialiasing;
				stageDarkness.scrollFactor.set(0.5, 0.5);
				stageDarkness.setGraphicSize(Std.int(stageDarkness.width), Std.int(stageDarkness.height * 1.5));
				stageDarkness.updateHitbox();
				stageDarkness.blend = BlendMode.OVERLAY;
				stageDarkness.alpha = 0.001;*/

				// Temple Darkness

				vines = new FlxSprite(-1400, -1575).loadGraphic(Paths.image('harmony/templeVines'));
				vines.antialiasing = ClientPrefs.globalAntialiasing;
				vines.scrollFactor.set(1.5, 2);
				vines.active = false;
				vines.alpha = 0.001;

				templeFogP = new FlxSprite(bg.x + 200, bg.y + 400).loadGraphic(Paths.image('templeVioletFog'));
				templeFogP.antialiasing = ClientPrefs.globalAntialiasing;
				templeFogP.setGraphicSize(Std.int(templeFogP.width * 1.2), Std.int(templeFogP.height));
				templeFogP.scrollFactor.set(1.2, 1.4);
				templeFogP.blend = BlendMode.LIGHTEN;
				templeFogP.alpha = 0.001;

				templePurple = new FlxSprite(bg.x + 200, bg.y + 400).loadGraphic(Paths.image('templeVioletDark'));
				templePurple.antialiasing = ClientPrefs.globalAntialiasing;
				templePurple.setGraphicSize(Std.int(templePurple.width * 1.2), Std.int(templePurple.height));
				templePurple.scrollFactor.set(1.3, 1.5);
				templePurple.blend = BlendMode.OVERLAY;
				templePurple.alpha = 0.001;

				templeDark = new FlxSprite(bg.x + 200, bg.y + 400).loadGraphic(Paths.image('templeDarkness'));
				templeDark.antialiasing = ClientPrefs.globalAntialiasing;
				templeDark.setGraphicSize(Std.int(templeDark.width * 1.2), Std.int(templeDark.height));
				templeDark.scrollFactor.set(1.4, 1.65);
				templeDark.blend = BlendMode.OVERLAY;
				templeDark.alpha = 0.001;

				templeFogB = new FlxSprite(bg.x + 200, bg.y + 400).loadGraphic(Paths.image('templeBlackFog'));
				templeFogB.antialiasing = ClientPrefs.globalAntialiasing;
				templeFogB.setGraphicSize(Std.int(templeFogB.width * 1.2), Std.int(templeFogB.height));
				templeFogB.scrollFactor.set(1.5, 1.75);
				templeFogB.blend = BlendMode.OVERLAY;
				templeFogB.alpha = 0.001;

				// Particles

				emitter2 = new FlxEmitter(-1300, -1275);
				for (i in 0...4000) {
					var p = new FlxParticle();
					p.makeGraphic(15, 15, 0xFFFFFFFF);
					p.exists = false;
					emitter2.add(p);
				}
				emitter2.launchMode = FlxEmitterMode.SQUARE;
				emitter2.setSize(4000, 4000);
				emitter2.velocity.start.min.x = -400;
				emitter2.velocity.start.max.x = -4000;
				emitter2.velocity.start.min.y = 200;
				emitter2.velocity.start.max.y = 1000;
				emitter2.angularVelocity.set(0, 360, 180, 720);
				emitter2.alpha.set(1, 1, 0, 0);
				emitter2.color.set(FlxColor.PURPLE, FlxColor.PURPLE, FlxColor.PURPLE, FlxColor.PURPLE);
				emitter2.scale.set(1, 1, 1.5, 1.5, 0, 0, 0, 0);
				emitter2.blend = BlendMode.ADD;
				emitter2.start(false, 0.0025);
				emitter2.emitting = false;

				// Particles End

				// Temple Darkness End
			}

			
			case 'corruption': {
				defaultCamZoom = 0.45;
				curStage = 'sparklestone';

				var bg:FlxSprite = new FlxSprite(-1302, -739).loadGraphic(Paths.image('corruption/dark sky'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0, 0);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 1.5), Std.int(bg.height));
				add(bg);

				var clouds:FlxSprite = new FlxSprite(-1117, -816).loadGraphic(Paths.image('corruption/clouds'));
				clouds.antialiasing = ClientPrefs.globalAntialiasing;
				clouds.scrollFactor.set(0.2, 0.2);
				clouds.active = false;
				add(clouds);

				var ocean01:FlxSprite = new FlxSprite(-1146, 250).loadGraphic(Paths.image('corruption/ocean 01'));
				ocean01.antialiasing = ClientPrefs.globalAntialiasing;
				ocean01.scrollFactor.set(0.45, 0.45);
				ocean01.active = false;
				add(ocean01);

				bfFly = new FlxSprite(0, 0);
				bfFly.frames = Paths.getSparrowAtlas('corruption/BF flying');
				bfFly.animation.addByPrefix('fly', 'BF flying', 24, true);
				bfFly.animation.play('fly');
				bfFly.scrollFactor.set(0.35, 0.35);
				bfFly.antialiasing = ClientPrefs.globalAntialiasing;
				add(bfFly);

				var ocean02:FlxSprite = new FlxSprite(-1246, 691).loadGraphic(Paths.image('corruption/ocean 02'));
				ocean02.antialiasing = ClientPrefs.globalAntialiasing;
				ocean02.scrollFactor.set(0.65, 0.65);
				ocean02.active = false;
				add(ocean02);

				var land:FlxSprite = new FlxSprite(-1389, -293).loadGraphic(Paths.image('corruption/bg land 01'));
				land.antialiasing = ClientPrefs.globalAntialiasing;
				land.scrollFactor.set(0.8, 0.8);
				land.active = false;
				add(land);

				var ground:FlxSprite = new FlxSprite(-672, 1375).loadGraphic(Paths.image('corruption/beach'));
				ground.antialiasing = ClientPrefs.globalAntialiasing;
				ground.scrollFactor.set(0.95, 0.95);
				ground.active = false;
				add(ground);

				var cacti01:FlxSprite = new FlxSprite(-370, 923).loadGraphic(Paths.image('corruption/cacti back'));
				cacti01.antialiasing = ClientPrefs.globalAntialiasing;
				cacti01.scrollFactor.set(0.9, 0.9);
				cacti01.active = false;
				add(cacti01);

				var cacti02:FlxSprite = new FlxSprite(-144, 1919).loadGraphic(Paths.image('corruption/cacti front'));
				cacti02.antialiasing = ClientPrefs.globalAntialiasing;
				cacti02.scrollFactor.set(1.1, 1.1);
				cacti02.active = false;
				add(cacti02);

				// Particles

				emitter = new FlxEmitter(land.x + 1200, land.y - 400);
				for (i in 0...4000) {
					var p = new FlxParticle();
					p.makeGraphic(15, 15, 0xFFFFFFFF);
					p.exists = false;
					emitter.add(p);
				}
				emitter.launchMode = FlxEmitterMode.SQUARE;
				emitter.setSize(4000, 4000);
				emitter.velocity.start.min.x = -400;
				emitter.velocity.start.max.x = -4000;
				emitter.velocity.start.min.y = 200;
				emitter.velocity.start.max.y = 1000;
				emitter.angularVelocity.set(0, 360, 180, 720);
				emitter.alpha.set(1, 1, 0, 0);
				emitter.color.set(FlxColor.PURPLE, FlxColor.PURPLE, FlxColor.PURPLE, FlxColor.PURPLE);
				emitter.scale.set(1, 1, 1.5, 1.5, 0, 0, 0, 0);
				emitter.blend = BlendMode.ADD;
				emitter.start(false, 0.0025);
				emitter.emitting = false;

				// Particles End

				templeFogP = new FlxSprite(emitter.x + 200, emitter.y + 1200).loadGraphic(Paths.image('templeVioletFog'));
				templeFogP.antialiasing = ClientPrefs.globalAntialiasing;
				templeFogP.setGraphicSize(Std.int(templeFogP.width * 1.5), Std.int(templeFogP.height * 1.3));
				templeFogP.scrollFactor.set(1.2, 1.4);
				templeFogP.blend = BlendMode.LIGHTEN;
				templeFogP.alpha = 0.001;

				templePurple = new FlxSprite(emitter.x + 200, emitter.y + 1200).loadGraphic(Paths.image('templeVioletDark'));
				templePurple.antialiasing = ClientPrefs.globalAntialiasing;
				templePurple.setGraphicSize(Std.int(templePurple.width * 1.5), Std.int(templePurple.height * 1.3));
				templePurple.scrollFactor.set(1.3, 1.5);
				templePurple.blend = BlendMode.OVERLAY;
				templePurple.alpha = 0.001;

				templeDark = new FlxSprite(emitter.x + 200, emitter.y + 1200).loadGraphic(Paths.image('templeDarkness'));
				templeDark.antialiasing = ClientPrefs.globalAntialiasing;
				templeDark.setGraphicSize(Std.int(templeDark.width * 1.5), Std.int(templeDark.height * 1.3));
				templeDark.scrollFactor.set(1.4, 1.65);
				templeDark.blend = BlendMode.OVERLAY;
				templeDark.alpha = 0.001;

				templeFogB = new FlxSprite(emitter.x + 200, emitter.y + 1200).loadGraphic(Paths.image('templeBlackFog'));
				templeFogB.antialiasing = ClientPrefs.globalAntialiasing;
				templeFogB.setGraphicSize(Std.int(templeFogB.width * 1.5), Std.int(templeFogB.height * 1.3));
				templeFogB.scrollFactor.set(1.5, 1.75);
				templeFogB.blend = BlendMode.OVERLAY;
				templeFogB.alpha = 0.001;
			}

			case 'eclipse': {
				defaultCamZoom = 0.8;
				curStage = 'foreverfall';

				var bg:FlxSprite = new FlxSprite(-885, -1227).loadGraphic(Paths.image('eclipse/sky'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0, 0);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 1.5), Std.int(bg.height));
				add(bg);

				var woods02:FlxSprite = new FlxSprite(-800, -1836).loadGraphic(Paths.image('eclipse/deep woods 02'));
				woods02.antialiasing = ClientPrefs.globalAntialiasing;
				woods02.scrollFactor.set(0.35, 0.35);
				woods02.active = false;
				add(woods02);

				var woods01:FlxSprite = new FlxSprite(-447, -1168).loadGraphic(Paths.image('eclipse/deep woods 01'));
				woods01.antialiasing = ClientPrefs.globalAntialiasing;
				woods01.scrollFactor.set(0.55, 0.55);
				woods01.active = false;
				add(woods01);

				var rocks:FlxSprite = new FlxSprite(198, 398).loadGraphic(Paths.image('eclipse/behind ground'));
				rocks.antialiasing = ClientPrefs.globalAntialiasing;
				rocks.scrollFactor.set(0.85, 0.85);
				rocks.active = false;
				add(rocks);

				var ground:FlxSprite = new FlxSprite(-900, 512).loadGraphic(Paths.image('eclipse/ground'));
				ground.antialiasing = ClientPrefs.globalAntialiasing;
				ground.scrollFactor.set(0.95, 0.95);
				ground.active = false;
				add(ground);

				var bgObj:FlxSprite = new FlxSprite(-573, -685).loadGraphic(Paths.image('eclipse/background objects'));
				bgObj.antialiasing = ClientPrefs.globalAntialiasing;
				bgObj.scrollFactor.set(1, 1);
				bgObj.active = false;
				add(bgObj);

				bfDisc = new FlxSprite(1899, 804);
				bfDisc.frames = Paths.getSparrowAtlas('violastroDisc');
				bfDisc.animation.addByPrefix('spin', 'discSpin', 24, true);
				bfDisc.animation.play('spin');
				bfDisc.antialiasing = ClientPrefs.globalAntialiasing;
				add(bfDisc);

				// Particles

				emitter = new FlxEmitter(bg.x + 1000, bg.y);
				for (i in 0...1000) {
					var p = new FlxParticle();
					p.makeGraphic(15, 150, 0xFFFFFFFF);
					p.exists = false;
					emitter.add(p);
				}
				emitter.launchMode = FlxEmitterMode.SQUARE;
				emitter.setSize(4000, 4000);
				emitter.velocity.start.min.x = -2500;
				emitter.velocity.start.max.x = -5000;
				emitter.velocity.start.min.y = 2500;
				emitter.velocity.start.max.y = 5000;
				emitter.alpha.set(1, 1, 1, 0.5);
				emitter.color.set(0xFF00A7ED, 0xFF00A7ED, 0xFF00A7ED, 0xFF00A7ED);
				emitter.angle.set(45, 45, 45, 45);
				emitter.scale.set(0.1, 0.5, 0.5, 1, 0, 0, 0, 0);
				emitter.blend = BlendMode.ADD;
				emitter.start(false, 0.0025);

				foregrObj = new FlxSprite(-127, 65).loadGraphic(Paths.image('eclipse/foreground objects'));
				foregrObj.antialiasing = ClientPrefs.globalAntialiasing;
				foregrObj.scrollFactor.set(1.35, 1.15);
				foregrObj.active = false;

				leavesShadow = new FlxSprite(-600, -700).loadGraphic(Paths.image('eclipse/large shadow'));
				leavesShadow.antialiasing = ClientPrefs.globalAntialiasing;
				leavesShadow.scrollFactor.set(1.35, 1.15);
				leavesShadow.blend = BlendMode.SUBTRACT;
				leavesShadow.active = false;
				leavesShadow.alpha = 0.55;

				leaves = new FlxSprite(-800, -840).loadGraphic(Paths.image('eclipse/TOP leaves'));
				leaves.antialiasing = ClientPrefs.globalAntialiasing;
				leaves.scrollFactor.set(1.35, 1.15);
				leaves.active = false;

				templeDark = new FlxSprite(bg.x + 600, bg.y + 600).loadGraphic(Paths.image('templeDarkness'));
				templeDark.antialiasing = ClientPrefs.globalAntialiasing;
				templeDark.setGraphicSize(Std.int(templeDark.width * 1.5), Std.int(templeDark.height * 1.2));
				templeDark.scrollFactor.set(1.4, 1.65);
				templeDark.blend = BlendMode.OVERLAY;
				templeDark.alpha = 0.85;

				templeFogB = new FlxSprite(bg.x + 600, bg.y + 600).loadGraphic(Paths.image('templeBlackFog'));
				templeFogB.antialiasing = ClientPrefs.globalAntialiasing;
				templeFogB.setGraphicSize(Std.int(templeFogB.width * 1.5), Std.int(templeFogB.height * 1.2));
				templeFogB.scrollFactor.set(1.5, 1.75);
				templeFogB.blend = BlendMode.OVERLAY;
				templeFogB.alpha = 0.95;
			}
			

			default:
				defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
				bg.antialiasing = ClientPrefs.globalAntialiasing;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = ClientPrefs.globalAntialiasing;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				if(!ClientPrefs.lowQuality) {
					var stageLight:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('stage_light'));
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.antialiasing = ClientPrefs.globalAntialiasing;
					stageLight.scrollFactor.set(0.9, 0.9);
					stageLight.active = false;
					add(stageLight);

					var stageLight:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.image('stage_light'));
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.antialiasing = ClientPrefs.globalAntialiasing;
					stageLight.scrollFactor.set(0.9, 0.9);
					stageLight.active = false;
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = ClientPrefs.globalAntialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
					add(stageCurtains);
				}
		}

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'arena':
					if (SONG.song == 'The-Ups-and-Downs')
						gfVersion = 'gf-pillow';
					else gfVersion = 'gf-viobot';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		if (dad.curCharacter == 'venturers') {
			cardinal = new Character(dad.x, dad.y - 10, 'cardinal');
			azura = new Character(dad.x + 30, dad.y, 'azura');
			pistachio = new Character(dad.x - 30, dad.y, 'pistachio');
			banana = new Character(dad.x, dad.y + 10, 'banana');
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
			case 'bf-pixel': //I like the Test track
				dad.x += 100;
				dad.y += 500;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y - 50);
			case 'violastro':
				dad.x -= 400;
				dad.y -= 300;
				camPos.set(dad.getGraphicMidpoint().x + 550, dad.getGraphicMidpoint().y + 100);
			case 'violastrobot':
				dad.x -= 400;
				dad.y -= 200;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y + 100);
			case 'venturers':
				dad.x -= 100;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x - 250, dad.getGraphicMidpoint().y - 100);
				cardinal.x = dad.x;
				cardinal.y = dad.y - 10;
				pistachio.x = dad.x - 30;
				pistachio.y = dad.y;
				banana.x = dad.x;
				banana.y = dad.y + 10;
				azura.x = dad.x + 10;
				azura.y = dad.y + 10;
			case 'psychic':
				dad.y -= 150;
			case 'pistachio':
				dad.x += 160;
				dad.y += 90;
			case 'cardinal':
				dad.x += 20;
				dad.y += 100;
			case 'banana':
				dad.x += 30;
				dad.y += 85;
			case 'azura':
				dad.x -= 40;
				dad.y += 85;
		}

		if (SONG.player1 == 'duo-bfgf') {
			boyfriend = new Boyfriend(770, 450, 'bf-vio');
			girlfriend = new Boyfriend(1070, 350, 'pgf-vio');
		} else if (SONG.player1 == 'duo-viobotgf') {
			boyfriend = new Boyfriend(770, -50, 'violastrobotPlayer');
			girlfriend = new Boyfriend(1120, 350, 'pgf-vio');
		} else {
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		}
		
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'arena': {
				boyfriend.x += 200;
				gf.y -= 60;

				if (SONG.song == 'The-Ups-and-Downs') {
					boyfriend.x = bfDisc.getMidpoint().x - 210;
					boyfriend.y = bfDisc.getMidpoint().y - 440;
					gf.x = gfDisc.getMidpoint().x - 240;
					gf.y = gfDisc.getMidpoint().y - 380;
					dad.x -= 300;
				}
			}

			case 'temple': {
				if (SONG.song == 'Harmony') {
					boyfriend.x += 300;
					boyfriend.y -= 50;
					gf.x += 80;
					gf.y -= 275;
					boyfriend.x = bfDisc.getMidpoint().x - 210;
					boyfriend.y = bfDisc.getMidpoint().y - 440;
					camPos.set(gf.getMidpoint().x + 20, gf.getMidpoint().y - 1000);
				} else if (SONG.song == 'Corruption') {
					gf.x += 65;
					girlfriend.x += 225;
					girlfriend.y -= 80;
					boyfriend.x += 175;
					boyfriend.y -= 70;

					vines.alpha = 1;
				} else if (SONG.song == 'Eclipse') {
					gf.x -= 65;
					gf.y -= 500;
					girlfriend.x += 225;
					girlfriend.y -= 80;

					vines.alpha = 1;
				}
				dad.y -= 70;
			}

			case 'sparklestone': {
				dad.y += 950;
				dad.x += 600;
				boyfriend.x += 1200;
				boyfriend.y += 800;
				girlfriend.x += 1200;
				girlfriend.y += 700;

				gf.x = dad.x + (boyfriend.x - dad.x) - 600;
				gf.y = dad.y;
				
				camPos.set(gf.getMidpoint().x, gf.getMidpoint().y);
			}

			case 'foreverfall': {
				dad.x += 800;
				dad.y += 625;
				girlfriend.x = bfDisc.x + 450;
				girlfriend.y = bfDisc.y + 100;
				gf.x += 800;
				gf.y += 400;
				
				camPos.set(gf.getMidpoint().x, gf.getMidpoint().y);
			}
		}

		add(gf);
		if (SONG.song == 'Supernova') {
			gf2 = new Character(gf.x, gf.y, 'gf-viobot-bomb');
			gf2.scrollFactor.set(0.95, 0.95);
			add(gf2);
			gf2.alpha = 0.001;

			gf3 = new Character(gf.x, gf.y, 'gf-pillow');
			gf3.scrollFactor.set(0.95, 0.95);
			add(gf3);
			gf3.alpha = 0.001;

			gfArray.push(gf);
			gfArray.push(gf2);
			gfArray.push(gf3);

			gf = gfArray[0];

			viobot = new Character(gf.x - 140, gf.y - 300, 'viobot-dancin');
			viobot.scrollFactor.set(0.95, 0.95);
			add(viobot);
			viobot.alpha = 0.001;
		}

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		var color = FlxColor.BLACK;
		if (SONG.song == 'Tutorial' || SONG.song == 'Harmony')
			color = FlxColor.WHITE;
		harmonyWhite = new FlxSprite(-1000, -750).makeGraphic(FlxG.width * 3, FlxG.height * 3, color);
		harmonyWhite.scrollFactor.set();

		halloweenWhite = new FlxSprite(-1000, -750).makeGraphic(FlxG.width * 8, FlxG.height * 8, FlxColor.WHITE);
		halloweenWhite.scrollFactor.set();
		halloweenWhite.alpha = 0.001;

		if (dad.curCharacter == 'venturers') {
			cardinal.x = dad.x;
			cardinal.y = dad.y - 10;
			pistachio.x = dad.x - 30;
			pistachio.y = dad.y;
			banana.x = dad.x;
			banana.y = dad.y + 10;
			azura.x = dad.x + 10;
			azura.y = dad.y + 10;
		}

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);
		
/*
		if (SONG.song == 'Corruption') {
			add(bfDisc);
			bfDisc.x -= 3000;
			viobot = new Character(bfDisc.x - 140, bfDisc.y - 300, 'bf-vio');
			viobot.scrollFactor.set(1, 1);
			add(viobot);
			viobot.flipX = true;
		}
*/

		add(dad);

		if (dad.curCharacter == 'venturers') {
			add(cardinal);
			add(pistachio);
			add(azura);
			add(banana);
		}

		if (SONG.song == 'Harmony') {
			add(bfDisc);		
			centerCamera = true;
		}

		if (SONG.song == 'Corruption') {
			centerCamera = true;
			followWho = girlfriend;
			bfFly.x = gf.x - 2500;
			bfFly.y = gf.y - 900;
		}

		if (SONG.song == 'Eclipse') {
			followWho = boyfriend;
			//centerCamera = true;
		}

		add(boyfriend);
		if (SONG.player1 == 'duo-bfgf' || SONG.player1 == 'duo-viobotgf') {
			add(girlfriend);
		}

		if (SONG.song == 'Corruption') {
			harmonyWhite.x -= 150;
			add(templeFogP);
			add(templePurple);
			add(templeDark);
			add(emitter);
			add(templeFogB);
			add(harmonyWhite);
		}

		if (SONG.song == 'Eclipse') {
			add(foregrObj);
			add(leavesShadow);
			add(leaves);
			add(emitter);
			add(templeDark);
			add(templeFogB);
			add(halloweenWhite);
			add(harmonyWhite);
		}

		if (curStage == 'arena') {
			add(stageDarkness);
			add(floodLights);
			add(emitter2);
		}

		if (SONG.song == 'Psychic')
			stageDarkness.alpha = 0.85;

		if (curStage == 'temple') {
			add(templeLight);
			add(emitter);
			add(vines);
			//add(stageDarkness);
			add(templeFogP);
			add(templePurple);
			add(templeDark);
			add(emitter2);
			add(templeFogB);
			//if (SONG.song == "Tutorial" || SONG.song == "Harmony")
			add(harmonyWhite);
		}

		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		if (SONG.player1 == 'pgf-vio') {
			boyfriend.x -= 100;
			boyfriend.y -= 400;
		}


		var lowercaseSong:String = SONG.song.toLowerCase();
		switch (lowercaseSong)
		{
			case 'senpai' | 'roses' | 'thorns' | 'bwehehe' | 'stupefy' | 'supernova' | 'psychic':
				dialogue = CoolUtil.coolTextFile(Paths.txt(lowercaseSong + '/' + lowercaseSong + 'Dialogue'));
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		timeTxt = new FlxText(strumLine.x + (strumLine.width / 2) - 248, strumLine.y - 30, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideHud;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;

		timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).loadGraphic(Paths.image('timeBar'));
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideHud;
		timeBarBG.color = FlxColor.BLACK;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideHud;
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		/*
		healthBarBG = new FlxSprite(0, FlxG.height * 0.89).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		*/

		// Bruh

		var p1:String = Paths.image('healthbar/bar-' + SONG.player1);
		var p1Split:String = Paths.image('healthbar/bar-' + SONG.player1 + '-split');
		var p2:String = Paths.image('healthbar/bar-' + SONG.player2);
		var p2Split:String = Paths.image('healthbar/bar-' + SONG.player2 + '-split');

		if (!OpenFlAssets.exists(p1)) p1 = Paths.image('healthbar/bar-bf');
		if (!OpenFlAssets.exists(p1Split)) p1Split = Paths.image('healthbar/bar-bf-split');
		if (!OpenFlAssets.exists(p2)) p2 = Paths.image('healthbar/bar-bf');
		if (!OpenFlAssets.exists(p2Split)) p2Split = Paths.image('healthbar/bar-bf-split');

		healthBarBG = new FlxSprite(0, FlxG.height * 0.87).loadGraphic(Paths.image('healthbar/hp-outline'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.antialiasing = ClientPrefs.globalAntialiasing;
		if (ClientPrefs.downScroll)
			healthBarBG.y = 0.10 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.visible = !ClientPrefs.hideHud;

		healthBarCover = new FlxSprite(healthBarBG.x + 4, healthBarBG.y + 4).makeGraphic(Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), 0xFF6640B9);
		healthBarCover.scrollFactor.set();
		healthBarCover.visible = !ClientPrefs.hideHud;
		healthBarCover.alpha = 0.0001;

		healthBarP1 = new FlxSprite(healthBarBG.x - 40, healthBarBG.y - 65);
		healthBarP1.loadGraphic(p1);
		healthBarP1.visible = !ClientPrefs.hideHud;
		healthBarP1.antialiasing = ClientPrefs.globalAntialiasing;
		healthBarP1.flipX = true;

		healthBarP1Split = new FlxSprite(healthBarBG.x - 40, healthBarBG.y - 65);
		healthBarP1Split.loadGraphic(p1Split);
		healthBarP1Split.visible = !ClientPrefs.hideHud;
		healthBarP1Split.antialiasing = ClientPrefs.globalAntialiasing;
		healthBarP1Split.flipX = true;
		healthBarP1Split.flipY = true;

		healthBarP2 = new FlxSprite(healthBarBG.x - 40, healthBarBG.y - 65);
		healthBarP2.loadGraphic(p2);
		healthBarP2.visible = !ClientPrefs.hideHud;
		healthBarP2.antialiasing = ClientPrefs.globalAntialiasing;

		healthBarP2Split = new FlxSprite(healthBarBG.x - 40, healthBarBG.y - 65);
		healthBarP2Split.loadGraphic(p2Split);
		healthBarP2Split.visible = !ClientPrefs.hideHud;
		healthBarP2Split.antialiasing = ClientPrefs.globalAntialiasing;

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;

		healthBarMarker = new FlxSprite(healthBarBG.x + 4, healthBarBG.y + 4).loadGraphic(Paths.image('healthbar/hp-marker'));
		healthBarMarker.visible = !ClientPrefs.hideHud;
		healthBarMarker.antialiasing = ClientPrefs.globalAntialiasing;

		scoreTxt = new FlxText(0, healthBarBG.y + 66, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;

		shieldIcon = new FlxSprite(iconP1.x, iconP1.y + 50);
		shieldIcon.frames = Paths.getSparrowAtlas('shieldNoteHealthbar');
		shieldIcon.animation.addByPrefix('shield', 'Shield Icon', 24, true);
		shieldIcon.animation.play('shield');
		shieldIcon.flipX = true;
		shieldIcon.alpha = 0;
		shieldIcon.antialiasing = ClientPrefs.globalAntialiasing;

		add(healthBarP1);
		add(healthBarP2);
		add(healthBarP1Split);
		add(healthBarP2Split);
		add(healthBar);
		add(healthBarCover);
		add(healthBarBG);
		add(iconP1);
		add(iconP2);
		add(healthBarMarker);
		add(shieldIcon);
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		healthBarP1.cameras = [camHUD];
		healthBarP1Split.cameras = [camHUD];
		healthBarP2.cameras = [camHUD];
		healthBarP2Split.cameras = [camHUD];
		healthBarMarker.cameras = [camHUD];
		healthBarCover.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		shieldIcon.cameras = [camHUD];
		doof.cameras = [camDialog];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;
		
		if (storyWeek == 2)
			camHUD.alpha = 0.001;

		var daSong:String = curSong.toLowerCase();
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
							ease: FlxEase.linear,
							onComplete: function(twn:FlxTween) {
								remove(blackScreen);
							}
						});
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						snapCamFollowToPos(400, -2050);
						FlxG.camera.focusOn(camFollow);
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);

				case 'bwehehe':
					FlxG.camera.zoom = 0.85;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
					dialogueIntro(dialogue, 'vio_dialogue');

				case 'stupefy':
					dialogueIntro(dialogue, 'vio_dialogue', false);

				case 'supernova':
					FlxG.sound.play(Paths.sound('BEEGFART'));
					dialogueIntro(dialogue);

				default:
					startCountdown();
			}
			seenCutscene = true;
		} else {
			switch (daSong) {
				case 'psychic':
					dialogueIntro(dialogue);
				default:
					startCountdown();
			}
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');
		super.create();
	}

	function dialogueIntro(dialogue:Array<String>, ?song:String = '', ?doBlack:Bool = true):Void
	{
		// TO DO: Make this more flexible
		inCutscene = true;

		CoolUtil.precacheSound('dialogue');
		CoolUtil.precacheSound('dialogueClose');
		var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogue, song);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.cameras = [camDialog];
		switch (SONG.song.toLowerCase()) {
			case 'supernova' | 'the-ups-and-downs': {
				if (endingSong) {
					doof.finishThing = endSong;
				} else {
					doof.finishThing = startCountdown;
				}
			}
			default: {
				doof.finishThing = startCountdown;
			}
		}
		add(doof);
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		var mult:Int = 5;

		if (SONG.song == 'Eclipse')
			mult = 1;

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * mult;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (curBeat % gfSpeed == 0)
			{
				gf.dance();
			}
			if(curBeat % 2 == 0) {
				if (!boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.specialAnim)
				{
					boyfriend.dance();
				}
				if (SONG.player1 == 'duo-bfgf' || SONG.player1 == 'duo-viobotgf') {
					if (!girlfriend.animation.curAnim.name.startsWith("sing") && !girlfriend.stunned)
						girlfriend.dance();
				}
				if (!dad.animation.curAnim.name.startsWith('sing'))
				{
					dad.dance();
				}
				if (dad.curCharacter == 'venturers') {
					if (!cardinal.animation.curAnim.name.startsWith("sing") && !cardinal.stunned)
						cardinal.dance();
					if (!pistachio.animation.curAnim.name.startsWith("sing") && !pistachio.stunned)
						pistachio.dance();
					if (!azura.animation.curAnim.name.startsWith("sing") && !azura.stunned)
						azura.dance();
					if (!banana.animation.curAnim.name.startsWith("sing") && !banana.stunned)
						banana.dance();
				}
			}
			else if(dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', 'set', 'go']);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var antialias:Bool = ClientPrefs.globalAntialiasing;
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}
			switch(curStage) {
				case 'school' | 'schoolEvil':
					antialias = false;
			}

			if (SONG.song != 'Eclipse') {
				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();
	
						if (curStage.startsWith('school'))
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
	
						ready.screenCenter();
						ready.antialiasing = antialias;
						add(ready);
						FlxTween.tween(ready, {y: ready.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();
	
						if (curStage.startsWith('school'))
							set.setGraphicSize(Std.int(set.width * daPixelZoom));
	
						set.screenCenter();
						set.antialiasing = antialias;
						add(set);
						FlxTween.tween(set, {y: set.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();
	
						if (curStage.startsWith('school'))
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
	
						go.updateHitbox();
	
						go.screenCenter();
						go.antialiasing = antialias;
						add(go);
						FlxTween.tween(go, {y: go.y + 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					case 4:
				}
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = SONG.song.toLowerCase();
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (sys.FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('events', songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					swagNote.scrollFactor.set(0, 0);

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData, oldNote, true);
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					swagNote.mustPress = gottaHitNote;

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}
				} else { //Event Notes
					eventNotes.push(songNotes);
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}

		/*if(unspawnNotes.length > 1) { //Removes duplicated notes
			var i:Int = 1;
			while (i < unspawnNotes.length) {
				var deleted:Int = 0;
				var curNote:Note = unspawnNotes[i];
				if(curNote.noteData > -1) {
					for (j in 0...i) {
						var lastNote:Note = unspawnNotes[j];
						if(lastNote != null && curNote != null &&					//Checks if both notes are valid
						Math.abs(lastNote.strumTime - curNote.strumTime) <= 1 &&	//Checks if notes have a 1 milisecond difference maximum
						lastNote.isSustainNote == curNote.isSustainNote &&			//Checks if both are sustain notes
						lastNote.sustainLength == curNote.sustainLength &&			//Checks if their lengths are the same
						lastNote.noteData == curNote.noteData &&					//Checks if both notes are up/left/right/down
						lastNote.mustPress == curNote.mustPress) {					//Checks note side
							#if debug
							var side:String = "";
							switch(lastNote.noteData) {
								case 0: side = 'Left';
								case 1: side = 'Down';
								case 2: side = 'Up';
								case 3: side = 'Right';
							}
							
							FlxG.log.add("Removed dupe note: " + side + " on milisec " + lastNote.strumTime);
							#end
							unspawnNotes.remove(lastNote);
							deleted++;
							break;
						}
					}
				}

				i += 1 - deleted;
			}
		}*/

		generatedMusic = true;
	}

	function eventNoteEarlyTrigger(obj:Array<Dynamic>):Float {
		switch(obj[2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(STRUM_X, strumLine.y, i);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_WeekViolastro');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = ClientPrefs.globalAntialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
							if (SONG.song.toLowerCase() == 'the-ups-and-downs')
								babyArrow.visible = false;
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
							if (SONG.song.toLowerCase() == 'the-ups-and-downs')
								babyArrow.visible = false;
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

	//	if (FlxG.keys.justPressed.NINE)
	//	{
	//		iconP1.swapOldIcon();
	//	}

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.animation.play('bop', true);
						heyTimer = 0;
					}
				}
			case 'arena': {
				if (doFloodLights)
					floodLights.alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			}	
			/*
			case 'temple': {
				var rotRate = curStep * 0.25;
				var duh = 12;

				var discToY = 200 + Math.sin(rotRate) * 40;
				bfDisc.y += (discToY - bfDisc.y) / duh;
				boyfriend.x = bfDisc.getMidpoint().x - 210;
				boyfriend.y = bfDisc.getMidpoint().y - 440;
			}*/
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if(ratingString == '?') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingString;
		} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingString + ' (' + Math.floor(ratingPercent * 100) + '%)';
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

//		THIS FUCKING KILLS THE PAUSE MENU BASICALLY WHOOOPS LMAOOOOOOOOOOOO
//		if (paused)
//			FlxTween.globalManager.active = false;
//		else
//			FlxTween.globalManager.active = true;

		if (paused)
			FlxTimer.globalManager.active = false;
		else
			FlxTimer.globalManager.active = true;

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		shieldIcon.setGraphicSize(Std.int(FlxMath.lerp(225, shieldIcon.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// var iconOffset:Int = 0;

		if (!hideHealth) {
			if (!holdOnP1) {
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01));
			} else {
				var destP1 = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01));
			//	iconP1.x -= 1;
				if (Math.floor(iconP1.x) <= Math.floor(destP1)) {
					FlxTween.cancelTweensOf(iconP1);
					holdOnP1 = false;
				}
			}
			if (!holdOnP2) {
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - iconP2.width;
			} else {
				var destP2 = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - iconP2.width;
			//	iconP2.x += 1;
				if ((Math.floor(iconP2.x) >= Math.floor(destP2))) {
					FlxTween.cancelTweensOf(iconP2);
					holdOnP2 = false;
				}
			}
	
			healthBarMarker.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - 3;
	
			if (health >= 1.99 || health <= 0.01)
				healthBarMarker.alpha = 0;
			else
				healthBarMarker.alpha = 1;
	
			if (healthBar.percent < 25)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
	
			if (healthBar.percent > 75)
				iconP2.animation.curAnim.curFrame = 1;
			else
				iconP2.animation.curAnim.curFrame = 0;
		} else {
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
			healthBarMarker.alpha = 0;
		}

		if (health > 2)
			health = 2;

		shieldIcon.x = iconP1.x - 15;
		shieldIcon.y = iconP1.y - 5;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;
					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
					timeTxt.text = minutesRemaining + ':' + secondsRemaining;
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong)
		{
			moveCamera(Std.int(curStep / 16));
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (curSong == 'Tutorial') {
			switch (curStep) {
				case 0: harmonyIntro();
			}
			if (curStep >= 0)
			crystalWave += 0.0125;
			if (curStep >= 2)
				crystalWaveGreen += 0.0125;
			if (curStep >= 4)
				crystalWaveViolet += 0.0125;
			if (curStep >= 6)
				crystalWaveYellow += 0.0125;
			if (curStep >= 8)
				crystalWaveBlue += 0.0125;

			crystalRed.y += Math.sin(crystalWave) * 0.5;
			crystalGreen.y += Math.sin(crystalWaveGreen) * 0.5;
			crystalViolet.y += Math.sin(crystalWaveViolet) * 0.5;
			crystalYellow.y += Math.sin(crystalWaveYellow) * 0.5;
			crystalBlue.y += Math.sin(crystalWaveBlue) * 0.5;
		}

		if (curSong == 'Bwehehe') {
			switch (curStep) {
				case 576: {
					defaultCamZoom = 0.55;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
				}
				case 704, 800: {
					centerCamera = true;
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 50;
				}
				case 736: {
					centerCamera = false;
				}
				case 832: {
					centerCamera = false;
					defaultCamZoom = 0.45;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
				}
			}
		}

		if (curSong == 'Stupefy') {
			switch (curStep) {
				case 640, 1024, 1920:
					centerCamera = true;
					defaultCamZoom = 0.55;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 50;
				case 896, 1152:
					centerCamera = false;
					defaultCamZoom = 0.45;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
			}
		}

		if (curSong == 'Supernova') {
			switch (curStep) {
				case 32:
				case 1088: // Beat 272 Step 1088
					arenaBoom();
				case 1280, 1664, 1920, 2176:
					centerCamera = true;
					defaultCamZoom = 0.45;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
					camFollow.x = viobot.getMidpoint().x;
					camFollow.y = viobot.getMidpoint().y - 50;
				case 1408, 1792, 2048:
					centerCamera = false;
					defaultCamZoom = 0.55;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
			}
		}

		if (curSong == 'The-Ups-and-Downs') {
			if (!inCutscene && !endingSong) {
				if (controls.NOTE_LEFT || controls.NOTE_RIGHT) {
					health = 0;
					trace("You fool!");
				}
			}
			switch (curStep) {
				case 320, 640, 1024:
					centerCamera = true;
					defaultCamZoom = 0.45;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 50;
				case 384, 768:
					centerCamera = false;
					defaultCamZoom = 0.55;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
			}
		}

		if (curSong == 'Harmony') {
			switch (curStep) {
				case 0:
					harmonyIntro();
				case 304:
					boyfriend.playAnim('laughing', true);
					boyfriend.specialAnim = true;
					FlxTween.tween(FlxG.camera, { zoom: 0.8 }, 1, { ease: FlxEase.quadInOut });
				case 320, 1280:
					FlxTween.tween(FlxG.camera, { zoom: 0.375 }, 2, { ease: FlxEase.quadInOut });
					centerCamera = true;
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 50;
					gfSpeed = 1;
				case 448, 1024:
					centerCamera = false;
				case 576, 960:
					centerCamera = true;
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 50;
				case 704:
					FlxTween.tween(FlxG.camera, { zoom: 0.415 }, 2, { ease: FlxEase.quadInOut });
					centerCamera = false;
		//		case 1536:
		//			FlxTween.tween(FlxG.camera, { zoom: 0.415 }, 2, { ease: FlxEase.quadInOut });
				case 1696: {
					centerCamera = true;
					defaultCamZoom = 0.375;
					camFollow.y = gf.getMidpoint().y - 150;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 3, { ease: FlxEase.quadInOut });
					FlxTween.tween(camHUD, { alpha: 0 }, 3, { ease: FlxEase.quadInOut });
					camZooming = false;
					/*
					boyfriend.playAnim('laughing', true);
					boyfriend.specialAnim = true;
					gf.color = 0xff6640b9;
					FlxTween.tween(bfDisc, { y: bfDisc.y - 2000 }, 3, { ease: FlxEase.quadInOut });
					FlxTween.tween(gf, { alpha: 0, color: 0xffffffff }, 3, { ease: FlxEase.quadInOut });
					FlxTween.tween(iconP1, { alpha: 0 }, 3, { ease: FlxEase.quadInOut });
					cardinal.playAnim('glance', true);
					cardinal.specialAnim = true;
					cardinal.stunned = true;
					pistachio.playAnim('glance', true);
					pistachio.specialAnim = true;
					pistachio.stunned = true;
					banana.playAnim('glance', true);
					banana.specialAnim = true;
					banana.stunned = true;
					azura.playAnim('glance', true);
					azura.specialAnim = true;
					azura.stunned = true;
					inCutscene = true;
					*/
				}
				case 1712:
//					FlxTween.tween(bfDisc, { x: bfDisc.x - 3000, y: bfDisc.y - 50 }, 2, { ease: FlxEase.quadInOut });
					harmonyWhite.screenCenter();
					harmonyWhite.color = FlxColor.BLACK;
					FlxTween.tween(harmonyWhite, { alpha: 1 }, 4, { ease: FlxEase.quadInOut });
			}

			/*
			var WHYDUMBSHIT:Float = Math.sin(crystalWave);
			FlxG.watch.addQuick("crystalWaveRed", WHYDUMBSHIT);
			*/

			if (curStep >= 0)
				crystalWave += 0.0125;
			if (curStep >= 2)
				crystalWaveGreen += 0.0125;
			if (curStep >= 4)
				crystalWaveViolet += 0.0125;
			if (curStep >= 6)
				crystalWaveYellow += 0.0125;
			if (curStep >= 8)
				crystalWaveBlue += 0.0125;

			crystalRed.y += Math.sin(crystalWave) * 0.5;
			crystalGreen.y += Math.sin(crystalWaveGreen) * 0.5;
			crystalViolet.y += Math.sin(crystalWaveViolet) * 0.5;
			crystalYellow.y += Math.sin(crystalWaveYellow) * 0.5;
			crystalBlue.y += Math.sin(crystalWaveBlue) * 0.5;

			bfDisc.y += Math.sin(crystalWaveViolet) * 0.35;
			boyfriend.x = bfDisc.getMidpoint().x - 210;
			boyfriend.y = bfDisc.getMidpoint().y - 440;
		}

		if (curSong == 'Corruption') {
			switch (curStep) {
				case 0, 256, 896, 1408:
					camZooming = true;
					centerCamera = true;
					defaultCamZoom = 0.375;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 200;

					if (harmonyWhite.alpha > 0.001)
						FlxTween.tween(harmonyWhite, { alpha: 0.001 }, 11, { ease: FlxEase.quadInOut });
					if (camHUD.alpha < 1)
						FlxTween.tween(camHUD, { alpha: 1 }, 11, { ease: FlxEase.quadInOut });
				case 128, 384, 1152:
					centerCamera = false;
					defaultCamZoom = 0.45;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
				case 1696:
					FlxTween.tween(harmonyWhite, { alpha: 1 }, 4, { ease: FlxEase.quadInOut });
					FlxTween.tween(camHUD, { alpha: 0 }, 4, { ease: FlxEase.quadInOut });
//				case 704:
//					FlxTween.tween(bfDisc, { x: bfDisc.x + 3500, y: bfDisc.y - 50 }, 2.5, { ease: FlxEase.quadInOut, onComplete: function(fuck) {
//						viobot.flipX = false;
//					} });
				case 736:
//					viobot.playAnim('smack', true);
//					viobot.specialAnim = true;
//					viobot.heyTimer = 1.35;
					followWho = boyfriend;
					boyfriend.playAnim('riseUp', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = 1.35;
					FlxTween.tween(boyfriend, { y: boyfriend.y - 75 }, 0.85, {startDelay: 0.5});
				case 512:
					FlxTween.tween(bfFly, { x: bfFly.x + 6000, y: bfFly.y - 150 }, 50);
			}

			switch (curBeat) { // lol
				case 0:
					iconP1.changeIcon('pgf-vio');
				case 192:
					iconP1.changeIcon('violastrobot');
				case 288:
					iconP1.changeIcon('duo-viobotgf');
			}
			
//			if (curStep >= 0)
//				crystalWave += 0.0125;
//			if (curStep >= 2)
//				crystalWaveGreen += 0.0125;
			if (curStep >= 4)
				crystalWaveViolet += 0.0125;
//			if (curStep >= 6)
//				crystalWaveYellow += 0.0125;
//			if (curStep >= 8)
//				crystalWaveBlue += 0.0125;

//			crystalRed.y += Math.sin(crystalWave) * 0.5;
//			crystalGreen.y += Math.sin(crystalWaveGreen) * 0.5;
//			crystalViolet.y += Math.sin(crystalWaveViolet) * 0.5;
//			crystalYellow.y += Math.sin(crystalWaveYellow) * 0.5;
//			crystalBlue.y += Math.sin(crystalWaveBlue) * 0.5;

			bfFly.y += Math.sin(crystalWaveViolet) * 0.85;
//			viobot.x = bfDisc.getMidpoint().x - 210;
//			viobot.y = bfDisc.getMidpoint().y - 440;	

			if (curStep >= 1152) {
				followWho = boyfriend;
			}

			if (curBeat < 184) {
				boyfriend.specialAnim = true;
				boyfriend.playAnim('powerOut', true);
			}
		}

		if (curSong == 'Eclipse') {
			switch (curStep) {
				case 0:
					camZooming = true;
					defaultCamZoom = 0.475;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
					camFollow.x = gf.getMidpoint().x;
					camFollow.y = gf.getMidpoint().y - 200;
				case 1216:
					defaultCamZoom = 0.525;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
				case 1600:
					defaultCamZoom = 0.475;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
				case 2240:
					centerCamera = true;
					defaultCamZoom = 0.40;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { ease: FlxEase.quadInOut });
					camFollow.x = gf.getMidpoint().x + 20;
					camFollow.y = gf.getMidpoint().y + 75;
				case 2256:
					FlxTween.tween(harmonyWhite, { alpha: 1 }, 4, { startDelay: 0.5, ease: FlxEase.quadInOut });
					FlxTween.tween(camHUD, { alpha: 0 }, 4, { startDelay: 0.5, ease: FlxEase.quadInOut });
			}
			
			if (curStep >= 0)
				crystalWave += 0.0125;
			if (curStep >= 2)
				crystalWaveGreen += 0.0125;
			if (curStep >= 4)
				crystalWaveViolet += 0.0125;
			if (curStep >= 6)
				crystalWaveYellow += 0.0125;
			if (curStep >= 8)
				crystalWaveBlue += 0.0125;

	//		crystalRed.y += Math.sin(crystalWave) * 0.5;
	//		crystalGreen.y += Math.sin(crystalWaveGreen) * 0.5;
	//		crystalViolet.y += Math.sin(crystalWaveViolet) * 0.5;
	//		crystalYellow.y += Math.sin(crystalWaveYellow) * 0.5;
	//		crystalBlue.y += Math.sin(crystalWaveBlue) * 0.5;

			bfDisc.y += Math.sin(crystalWaveViolet) * 0.35;
			boyfriend.x = bfDisc.getMidpoint().x - 210;
			boyfriend.y = bfDisc.getMidpoint().y - 440;

			gf.alpha = 0.0001;

			if ((curStep >= 64) && (curStep <= 2064)) {
				harmonyWhite.alpha = 0.001;
				camHUD.alpha = 1;
			}
		}

		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}

		if (health <= 0 && !practiceMode)
		{
			boyfriend.stunned = true;
			deathCounter++;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, displaySongName + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// i am so fucking sorry for this if condition
				var center:Float = strumLine.y + Note.swagWidth / 2;
				if (ClientPrefs.downScroll) {
					daNote.y = (strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));
					if (daNote.isSustainNote) {
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null) {
							daNote.y += daNote.prevNote.height;
						} else {
							daNote.y += daNote.height / 2;
						}

						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				} else {
					daNote.y = (strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2));

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var isAlt:Bool = false;

					if (daNote.noteType == 3) {
						if (curStage.startsWith('school')) {
							boyfriend.playAnim('singDOWNmiss', true);
						} else {
							boyfriend.playAnim('damaged', true);
						}
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 1;
						health -= 0.1;
					}

					if(daNote.noteType == 2) {
						dad.playAnim('hey', true);
						dad.specialAnim = true;
						dad.heyTimer = 0.6;
					} else {
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 1) {
								altAnim = '-alt';
								isAlt = true;
							}
						}

						switch (dad.curCharacter) {
							case 'violastro' | 'violastrobot': {
								/*
								var animToPlay:String = 'sing';
								switch (Math.abs(daNote.noteData)) {
									case 0:
										animToPlay += 'LEFT';
									case 1:
										animToPlay += 'DOWN';
									case 2:
										animToPlay += 'UP';
									case 3:
										animToPlay += 'RIGHT';
								}

								var doForce:Bool = true;
								if (daNote.isSustainNote) {
									animToPlay += '-loop';
									doForce = false;
								} else if (daNote.sustainLength > 0) { //Start of a hold note
									animToPlay += '-start';
								} else {
									animToPlay += altAnim;
								}
								dad.playAnim(animToPlay, doForce);
								*/

								switch (Math.abs(daNote.noteData)) {
									case 0:
										if (daNote.isSustainNote) {
											if (dad.animation.name == 'singLEFT-loop')
												dad.playAnim('singLEFT-loop');
											else dad.playAnim('singLEFT-start', true);
										} else {
											dad.playAnim('singLEFT' + altAnim, true);
										}
									case 1:
										if (daNote.isSustainNote) {
											if (dad.animation.name == 'singDOWN-loop')
												dad.playAnim('singDOWN-loop');
											else dad.playAnim('singDOWN-start', true);
										} else {
											dad.playAnim('singDOWN' + altAnim, true);
										}
									case 2:
										if (daNote.isSustainNote) {
											if (dad.animation.name == 'singUP-loop')
												dad.playAnim('singUP-loop');
											else dad.playAnim('singUP-start', true);
										} else {
											dad.playAnim('singUP' + altAnim, true);
										}
									case 3:
										if (daNote.isSustainNote) {
											if (dad.animation.name == 'singRIGHT-loop')
												dad.playAnim('singRIGHT-loop');
											else dad.playAnim('singRIGHT-start', true);
										} else {
											dad.playAnim('singRIGHT' + altAnim, true);
										}
									}
							}

							case 'venturers': {
								switch (Math.abs(daNote.noteData)) {
									case 0:
										pistachio.playAnim('singLeaf' + daNote.vibrantNum, true);
										pistachio.holdTimer = 0;
									case 1:
										banana.playAnim('singEarth' + daNote.vibrantNum, true);
										banana.holdTimer = 0;
									case 2:
										cardinal.playAnim('singFire' + daNote.vibrantNum, true);
										cardinal.holdTimer = 0;
									case 3:
										azura.playAnim('singWater' + daNote.vibrantNum, true);
										azura.holdTimer = 0;
								}
								if (!shieldOn) {
									health -= (0.005 * health * 4) * vibrantsRate;
//									if (health >= 0.2)
								}
							}

							default: {
								var animToPlay:String = '';
								switch (Math.abs(daNote.noteData))
								{
									case 0:
										animToPlay = 'singLEFT';
									case 1:
										animToPlay = 'singDOWN';
									case 2:
										animToPlay = 'singUP';
									case 3:
										animToPlay = 'singRIGHT';
								}
								dad.playAnim(animToPlay + altAnim, true);
							}
						}
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					DadStrumPlayAnim(daNote.noteData % 4, time);

					FlxTween.cancelTweensOf(daNote);
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill:Bool = daNote.y < -daNote.height;
				if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.mustPress && daNote.noteType != 3 && daNote.noteType != 4)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							if(!endingSong) {
								health -= 0.0475; //For testing purposes
								songMisses++;
							}
							vocals.volume = 0;
							RecalculateRating();
						}
					}

					daNote.active = false;
					daNote.visible = false;

					FlxTween.cancelTweensOf(daNote);
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}


		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			switch(eventNotes[0][2]) {
				case 'Hey!':
					var value:Int = Std.parseInt(value1);
					var time:Float = Std.parseFloat(value2);
					if(Math.isNaN(time) || time <= 0) time = 0.6;

					if(value != 0) {
						if(dad.curCharacter == 'gf') { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
							dad.playAnim('cheer', true);
							dad.specialAnim = true;
							dad.heyTimer = time;
						} else {
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = time;
						}

						if(curStage == 'mall') {
							bottomBoppers.animation.play('hey', true);
							heyTimer = time;
						}
					}
					if(value != 1) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					}

				case 'Set GF Speed':
					var value:Int = Std.parseInt(value1);
					if(Math.isNaN(value)) value = 1;
					gfSpeed = value;

				case 'Blammed Lights': {
					if (ClientPrefs.flashing) {
						if (curStage == 'philly') {
							var lightId:Int = Std.parseInt(value1);
							if (Math.isNaN(lightId)) lightId = 0;

							if (lightId > 0 && curLightEvent != lightId) {
								if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

								var color:Int = 0xffffffff;
								switch(lightId) {
									case 1: //Blue
										color = 0xff31a2fd;
									case 2: //Green
										color = 0xff31fd8c;
									case 3: //Pink
										color = 0xfff794f7;
									case 4: //Red
										color = 0xfff96d63;
									case 5: //Orange
										color = 0xfffba633;
								}
								curLightEvent = lightId;

								if (phillyBlack.alpha != 1) {
									FlxTween.cancelTweensOf(phillyBlack);
									FlxTween.tween(phillyBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
									FlxTween.color(dad, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									FlxTween.color(boyfriend, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									FlxTween.color(gf, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
								} else {
									dad.color = color;
									boyfriend.color = color;
									gf.color = color;
								}

								phillyCityLightsEvent.forEach(function(spr:FlxSprite) {
									spr.visible = false;
								});
								phillyCityLightsEvent.members[lightId - 1].visible = true;
								phillyCityLightsEvent.members[lightId - 1].alpha = 1;
							} else {
								if (phillyBlack.alpha != 0) {
									FlxTween.cancelTweensOf(phillyBlack);
									FlxTween.tween(phillyBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
								}

								phillyCityLights.forEach(function(spr:FlxSprite) {
									spr.visible = false;
								});
								phillyCityLightsEvent.forEach(function(spr:FlxSprite) {
									spr.visible = false;
								});

								var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
								if(memb != null) {
									memb.visible = true;
									memb.alpha = 1;
									FlxTween.tween(memb, {alpha: 0}, 1, {ease: FlxEase.quadInOut});
								}

								FlxTween.color(dad, 1, dad.color, 0xffffffff, {ease: FlxEase.quadInOut});
								FlxTween.color(boyfriend, 1, boyfriend.color, 0xffffffff, {ease: FlxEase.quadInOut});
								FlxTween.color(gf, 1, gf.color, 0xffffffff, {ease: FlxEase.quadInOut});

								curLight = 0;
								curLightEvent = 0;
							}
						}

						if (curStage == 'arena') {
							var lightId:Int = Std.parseInt(value1);
							if (Math.isNaN(lightId)) lightId = 0;

							if (lightId > 0 && curLightEvent != lightId) {
								if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

								var color:Int = 0xffffffff;
								switch(lightId) {
									case 1: //Red
										color = 0xffee3242;
									case 2: //Green
										color = 0xff48d904;
									case 3: //Yellow
										color = 0xffffbb00;
									case 4: //Blue
										color = 0xff0c6dee;
									case 5: //Violet
										color = 0xff6640b9;
								}
								curLightEvent = lightId;
								doFloodLights = true;
								emitter2.emitting = true;

								if (stageDarkness.alpha != 1) {
									FlxTween.cancelTweensOf(stageDarkness);
									FlxTween.tween(stageDarkness, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
									FlxTween.tween(stageDarknessWhole, {alpha: 0.85}, 1, {ease: FlxEase.quadInOut});
									FlxTween.tween(floodLights, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
									FlxTween.color(floodLights, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									FlxTween.color(podium, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									FlxTween.color(dad, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									FlxTween.color(boyfriend, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									FlxTween.color(gf, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									emitter2.color.set(color, color, color, color);
									if (curSong == 'Supernova') {
										FlxTween.color(viobot, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
										FlxTween.color(gfDisc, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
										FlxTween.color(bfDisc, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
										FlxTween.color(vioDisc, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									}
									if (curSong == 'The-Ups-and-Downs') {
										FlxTween.color(gfDisc, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
										FlxTween.color(bfDisc, 1, 0xffffffff, color, {ease: FlxEase.quadInOut});
									}
								} else {
									dad.color = color;
									boyfriend.color = color;
									gf.color = color;
									floodLights.color = color;
									podium.color = color;
									emitter2.color.set(color, color, color, color);
									if (curSong == 'Supernova') {
										viobot.color = color;
										gfDisc.color = color;
										bfDisc.color = color;
										vioDisc.color = color;
									}
									if (curSong == 'The-Ups-and-Downs') {
										gfDisc.color = color;
										bfDisc.color = color;
									}
								}
							} else {
								if (stageDarkness.alpha != 0) {
									FlxTween.cancelTweensOf(stageDarkness);
									FlxTween.tween(stageDarkness, {alpha: 0.001}, 1, {ease: FlxEase.quadInOut});
									FlxTween.tween(stageDarknessWhole, {alpha: 0.001}, 1, {ease: FlxEase.quadInOut});
									FlxTween.color(floodLights, 1, floodLights.color, 0xffffffff, {ease: FlxEase.quadInOut});
									FlxTween.tween(floodLights, {alpha: 0.001}, 1, {ease: FlxEase.quadInOut});
								}

								FlxTween.color(dad, 1, dad.color, 0xffffffff, {ease: FlxEase.quadInOut});
								FlxTween.color(boyfriend, 1, boyfriend.color, 0xffffffff, {ease: FlxEase.quadInOut});
								FlxTween.color(gf, 1, gf.color, 0xffffffff, {ease: FlxEase.quadInOut});
								FlxTween.color(podium, 1, podium.color, 0xffffffff, {ease: FlxEase.quadInOut});
								emitter2.color.set(0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff);
								if (curSong == 'Supernova') {
									FlxTween.color(viobot, 1, viobot.color, 0xffffffff, {ease: FlxEase.quadInOut});
									FlxTween.color(gfDisc, 1, gfDisc.color, 0xffffffff, {ease: FlxEase.quadInOut});
									FlxTween.color(bfDisc, 1, bfDisc.color, 0xffffffff, {ease: FlxEase.quadInOut});
									FlxTween.color(vioDisc, 1, vioDisc.color, 0xffffffff, {ease: FlxEase.quadInOut});
								}
								if (curSong == 'The-Ups-and-Downs') {
									FlxTween.color(gfDisc, 1, gfDisc.color, 0xffffffff, {ease: FlxEase.quadInOut});
									FlxTween.color(bfDisc, 1, bfDisc.color, 0xffffffff, {ease: FlxEase.quadInOut});
								}

								// TURN INVISIBLE FOR FUCKS SAKE AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
								new FlxTimer().start(0.5, function(tmr:FlxTimer) {
									FlxTween.tween(floodLights, {alpha: 0.001}, 1, {ease: FlxEase.quadInOut});
								});

								curLight = 0;
								curLightEvent = 0;
								doFloodLights = false;
								emitter2.emitting = false;
							}
						}
					}

					if (curStage == 'temple') {
						var lightId:Int = Std.parseInt(value1);
						if (Math.isNaN(lightId)) lightId = 0;
						
						if (lightId == 1) {
							FlxTween.tween(templeFogP, {alpha: 0.825}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templePurple, {alpha: 0.885}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templeDark, {alpha: 0.75}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templeFogB, {alpha: 0.85}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templeLight, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
							doFloodLights = true;
							emitter.emitting = false;
							emitter2.emitting = true;
							vibrantsRate = 1.2;
							//FlxTween.tween(stageDarkness, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
						} else {
							FlxTween.tween(templeFogP, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templePurple, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templeDark, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
							FlxTween.tween(templeFogB, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
							doFloodLights = false;
							emitter.emitting = true;
							emitter2.emitting = false;
							vibrantsRate = 1;
							//FlxTween.tween(stageDarkness, {alpha: 0.001}, 1, {ease: FlxEase.quadInOut});
						}
					}

					if (curStage == 'sparklestone' || curStage == 'foreverfall') {
						var lightId:Int = Std.parseInt(value1);
						if (Math.isNaN(lightId)) lightId = 0;

						if (lightId == 1) {
							if (curStage == 'sparklestone') {
								FlxTween.tween(templeFogP, {alpha: 0.825}, 2, {ease: FlxEase.quadInOut});
								FlxTween.tween(templePurple, {alpha: 0.885}, 2, {ease: FlxEase.quadInOut});
								FlxTween.tween(templeDark, {alpha: 0.75}, 2, {ease: FlxEase.quadInOut});
								FlxTween.tween(templeFogB, {alpha: 0.85}, 2, {ease: FlxEase.quadInOut});
								emitter.emitting = true;
							}
							vibrantsRate = 1.2;
						} else {
							if (curStage == 'sparklestone') {
								FlxTween.tween(templeFogP, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
								FlxTween.tween(templePurple, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
								FlxTween.tween(templeDark, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
								FlxTween.tween(templeFogB, {alpha: 0.001}, 2, {ease: FlxEase.quadInOut});
								emitter.emitting = false;
							}
							vibrantsRate = 1;
						}
					}
				}

//				case 'Kill Henchmen':
//					killHenchmen();

				case 'Add Camera Zoom':
					if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = 0.015;
						if(Math.isNaN(hudZoom)) hudZoom = 0.03;

						FlxG.camera.zoom += camZoom;
						camHUD.zoom += hudZoom;
					}

				case 'Trigger BG Ghouls':
					if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
						bgGhouls.dance(true);
						bgGhouls.visible = true;
					}

				case 'Play Animation':
					trace('Anim to play: ' + value1);
					dad.playAnim(value1, true);
					dad.specialAnim = true;

				case 'Change Camera Zoom':
					var zoom:Float = Std.parseFloat(value1);
					var time:Float = Std.parseFloat(value2);
					if (Math.isNaN(zoom)) zoom = 1;
					if (Math.isNaN(time)) time = 1;
					defaultCamZoom = zoom;
					FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, time, { startDelay: 0.5, ease: FlxEase.smootherStepInOut });
				
				case 'Center Camera':
					var toggle:Int = Std.parseInt(value1);
					switch (toggle) {
						case 0:
							centerCamera = false;
						case 1:
							centerCamera = true;
							if (curSong == 'Supernova') {
								camFollow.x = viobot.getMidpoint().x;
								camFollow.y = viobot.getMidpoint().y - 50;
							} else {
								camFollow.x = gf.getMidpoint().x;
								camFollow.y = gf.getMidpoint().y - 50;
							}
					}

				case 'Hide Health': {
					hideHealth = !hideHealth;

					if (hideHealth) {
						FlxTween.tween(healthBarCover, { alpha: 1 }, 0.5, { ease: FlxEase.smootherStepInOut });
						FlxTween.tween(iconP1, { x: (healthBar.x + healthBar.width + 50) }, 1.5, { ease: FlxEase.smootherStepInOut });
						FlxTween.tween(iconP2, { x: (healthBar.x - iconP2.width - 50) }, 1.5, { ease: FlxEase.smootherStepInOut });
					} else {
						FlxTween.tween(healthBarCover, { alpha: 0.0001 }, 0.5, { ease: FlxEase.smootherStepInOut });
						holdOnP1 = true;
						FlxTween.tween(iconP1, { x: iconP2.x }, 2, { ease: FlxEase.smootherStepInOut });
						holdOnP2 = true;
						FlxTween.tween(iconP2, { x: iconP1.x }, 2, { ease: FlxEase.smootherStepInOut });
					//	new FlxTimer().start(1.5, function(tmr:FlxTimer) {
					//		holdOn = false;
					//	});
					//	
					//	
					}

					//iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01));
					//iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - iconP2.width;
				}

				case 'Change Scroll Speed': {
					var speed:Float = Std.parseFloat(value1);
					if(Math.isNaN(speed)) speed = 1;
					PlayState.SONG.speed = speed;
				}
			}
			eventNotes.shift();
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE)
				FlxG.sound.music.onComplete();
			if (FlxG.keys.justPressed.TWO) { // Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
		#end
	}

	function harmonyIntro():Void {
		if (curSong == 'Harmony') {
			camHUD.alpha = 0;
			gfSpeed = 2;
	
			//centerCamera = true;
			//camFollow.x = gf.getMidpoint().x + 10;
			//camFollow.y = gf.getMidpoint().y - 1000;
	
			FlxTween.tween(FlxG.camera, { zoom: 0.575 }, 5, { ease: FlxEase.smootherStepInOut });
			FlxTween.tween(harmonyWhite, { alpha: 0 }, 4.5, { ease: FlxEase.smootherStepInOut });
			FlxTween.tween(camHUD, { alpha: 1 }, 7.5, { ease: FlxEase.smootherStepInOut });
			new FlxTimer().start(5, function(tmr:FlxTimer) {
				harmonyWhite.alpha = 0.001;
				centerCamera = false;
				defaultCamZoom = 0.4;
				FlxTween.tween(vines, { alpha: 1 }, 1, { ease: FlxEase.smootherStepInOut });
				FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 2, { ease: FlxEase.smootherStepInOut });
			});
		} else {
			FlxTween.tween(FlxG.camera, { zoom: 0.575 }, 2, { ease: FlxEase.smootherStepInOut });
			FlxTween.tween(harmonyWhite, { alpha: 0 }, 2, { ease: FlxEase.smootherStepInOut });
			new FlxTimer().start(2, function(tmr:FlxTimer) {
				harmonyWhite.alpha = 0.001;
				FlxTween.tween(vines, { alpha: 1 }, 1, { ease: FlxEase.smootherStepInOut });
			});
		}
	}

	function arenaBoom():Void {
		var white:FlxSprite = new FlxSprite(-1000, -750).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
		white.scrollFactor.set();
		white.visible = false;
		add(white);

		gf.visible = false;
		gf = gfArray[1];
		gf.visible = true;
		gf2.alpha = 1;
		gf2.playAnim('danceRight', true);
		gf.specialAnim = true;

		centerCamera = true;

		FlxTween.tween(FlxG.camera, { zoom: 0.65 }, 2, { startDelay: 0.5, ease: FlxEase.smootherStepInOut });
		camFollow.x = gf.getMidpoint().x - 75;
		camFollow.y = gf.getMidpoint().y - 50;

		new FlxTimer().start(5.55, function(tmr:FlxTimer) {
			white.visible = true;
		});

		new FlxTimer().start(5.6, function(tmr:FlxTimer) {
			gf.visible = false;
			gf = gfArray[2];
			gf.visible = true;
			gf3.alpha = 1;
			gf.specialAnim = false;
			centerCamera = false;

			boyfriend.x = bfDisc.getMidpoint().x - 210;
			boyfriend.y = bfDisc.getMidpoint().y - 440;
			dad.x = vioDisc.getMidpoint().x - 540;
			dad.y = vioDisc.getMidpoint().y - 1120;
			gf.x = gfDisc.getMidpoint().x - 240;
			gf.y = gfDisc.getMidpoint().y - 380;

			viobot.alpha = 1;
			vioDisc.alpha = 1;
			bfDisc.alpha = 1;
			gfDisc.alpha = 1;

			podium.alpha = 0.001;
			podium.y += 10000;
			//podiumBroken.alpha = 1;

			defaultCamZoom = 0.55;

			health = 0.5;

			FlxTween.tween(FlxG.camera, { zoom: defaultCamZoom }, 1, { startDelay: 0.5, ease: FlxEase.smootherStepInOut });
			new FlxTimer().start(0.1, function(swagTimer:FlxTimer)
				{
					white.alpha -= 0.05;
					if (white.alpha > 0)
					{
						swagTimer.reset();
					} else {
						remove(white);
					}
				});
		});
	}

	function moveCamera(?id:Int = 0):Void {
		if (!centerCamera) {
			if (SONG.notes[id] != null && camFollow.x != dad.getMidpoint().x + 150 && !SONG.notes[id].mustHitSection)
			{
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.set(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'bf-pixel':
						camFollow.y = dad.getMidpoint().y - 200;
					case 'violastro': 
						camFollow.x = dad.getMidpoint().x + 200;
						camFollow.y = dad.getMidpoint().y - 50;
					case 'venturers': 
						camFollow.x = cardinal.getMidpoint().x + 200;
						camFollow.y = cardinal.getMidpoint().y - 100;
					case 'pistachio': 
						camFollow.x = dad.getMidpoint().x + 100;
						camFollow.y = dad.getMidpoint().y - 50;
					case 'banana': 
						camFollow.x = dad.getMidpoint().x + 225;
						camFollow.y = dad.getMidpoint().y + 175;
					case 'azura': 
						camFollow.x = dad.getMidpoint().x + 425;
						camFollow.y = dad.getMidpoint().y + 75;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;
/*
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}*/
			}

			if (SONG.notes[id] != null && SONG.notes[id].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school' | 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'arena':
						if (SONG.song == 'The-Ups-and-Downs')
							camFollow.y = boyfriend.getMidpoint().y - 100;
						else camFollow.y = boyfriend.getMidpoint().y - 300;
					case 'temple':
						if (curSong == 'Corruption' || curSong == 'Eclipse') {
							camFollow.x = followWho.getMidpoint().x - 200;
							camFollow.y = followWho.getMidpoint().y + (followWho == girlfriend ? -250 : 100);
						} else {
							camFollow.x = boyfriend.getMidpoint().x - 200;
							camFollow.y = boyfriend.getMidpoint().y - (curSong == 'Harmony' ? 0 : 100);
						}
					case 'sparklestone':
						camFollow.x = followWho.getMidpoint().x - 50;
						camFollow.y = followWho.getMidpoint().y + (followWho == girlfriend ? -250 : 100);
					case 'foreverfall':
						camFollow.x = followWho.getMidpoint().x - 200;
						camFollow.y = followWho.getMidpoint().y + (followWho == girlfriend ? -250 : 100);
				}

				/*
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}*/
			}
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.
		if (isStoryMode) {
			switch (SONG.song.toLowerCase()) {
				case 'supernova': {
					finishCallback = supernovaEndSong;
				}
			}
		} else {
			switch (SONG.song.toLowerCase()) {
				case 'the-ups-and-downs': {
					finishCallback = supernovaEndSong;
				}
			}
		}

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	var transitioning = false;
	function endSong():Void
	{
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		KillNotes();

		if(achievementObj != null) {
			return;
		} else {
			var achieve:Int = checkForAchievement([0, 1, 2, 3, 4, 5]);
			if(achieve > -1) {
				startAchievement(achieve);
				return;
			}
		}

		if (SONG.validScore)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignMisses += songMisses;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
				usedPractice = false;
				changedDifficulty = false;
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				if (storyDifficulty == 3)
					difficulty = '-vibrant';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				var winterHorrorlandNext = (SONG.song.toLowerCase() == "eggnog");
				if (winterHorrorlandNext)
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				var supernovaNext = (SONG.song.toLowerCase() == "stupefy");
				if (supernovaNext)
				{
					var blackShit:FlxSprite = new FlxSprite(-1000, -750).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				prevCamFollow = camFollow;
				prevCamFollowPos = camFollowPos;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				if(winterHorrorlandNext || supernovaNext) {
					new FlxTimer().start(1.5, function(tmr:FlxTimer) {
						LoadingState.loadAndSwitchState(new PlayState());
					});
				} else {
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			usedPractice = false;
			changedDifficulty = false;
		}
	}

	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camAchievement);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}

	function supernovaEndSong():Void {
		songPercent = 1.0;
		timeTxt.text = '0:00';
		inCutscene = true;
		endingSong = true;
		canPause = false;
		camZooming = false;
		centerCamera = true;

		deathCounter = 0;
		seenCutscene = false;
		updateTime = false;
		KillNotes();

		// Cue the end lol

		// I'M SORRY FOR THIS LMAOOOOOOOOOOOOOOOOOOOOOOOOOOOO
		strumLineNotes.visible = false;
//		grpNoteSplashes.visible = false;
//		notes.visible = false;
//		FlxTween.tween(healthBar, {alpha: 0}, 2);
//		FlxTween.tween(healthBarBG, {alpha: 0}, 2);
//		FlxTween.tween(iconP1, {alpha: 0}, 2);
//		FlxTween.tween(iconP2, {alpha: 0}, 2);
//		FlxTween.tween(scoreTxt, {alpha: 0}, 2);
//		FlxTween.tween(timeBar, {alpha: 0}, 2);
//		FlxTween.tween(timeBarBG, {alpha: 0}, 2);
//		FlxTween.tween(timeTxt, {alpha: 0}, 2);

		FlxTween.tween(camHUD, { alpha: 0 }, 2);

		var blackShit:FlxSprite = new FlxSprite(-1000, -750).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackShit.scrollFactor.set();
		blackShit.alpha = 0;
		add(blackShit);

		FlxTween.tween(blackShit, { alpha: 1 }, 2, { ease: FlxEase.quadInOut });
		boyfriend.specialAnim = true;
		gf.stunned = true;
		dad.stunned = true;

		switch (SONG.song.toLowerCase()) {
			case 'supernova': {
				FlxTween.tween(FlxG.camera, { zoom: 1 }, 2, { startDelay: 0.5, ease: FlxEase.quadInOut });
				dialogue = CoolUtil.coolTextFile(Paths.txt('supernova/supernovaEndDialogue'));
				dialogueIntro(dialogue, 'empty', false);
			}
			
			case 'the-ups-and-downs': {
				endSong();
			}
		}
	}

	private function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			FlxTween.cancelTweensOf(daNote);
			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		if(daRating == 'sick' && ClientPrefs.noteSplashes && note != null)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(splash);
		}

		if(!practiceMode) {
			songScore += score;
			songHits++;
			RecalculateRating();
			FlxTween.cancelTweensOf(scoreTxt.scale);
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2);
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
		{
			// HOLDING
			var up = controls.NOTE_UP;
			var right = controls.NOTE_RIGHT;
			var down = controls.NOTE_DOWN;
			var left = controls.NOTE_LEFT;
	
			var upP = controls.NOTE_UP_P;
			var rightP = controls.NOTE_RIGHT_P;
			var downP = controls.NOTE_DOWN_P;
			var leftP = controls.NOTE_LEFT_P;
	
			var upR = controls.NOTE_UP_R;
			var rightR = controls.NOTE_RIGHT_R;
			var downR = controls.NOTE_DOWN_R;
			var leftR = controls.NOTE_LEFT_R;
	
			var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
			var controlReleaseArray:Array<Bool> = [leftR, downR, upR, rightR];
			var controlHoldArray:Array<Bool> = [left, down, up, right];
	
			// FlxG.watch.addQuick('asdfa', upP);
			if (!boyfriend.stunned && generatedMusic)
			{
				// rewritten inputs???
				notes.forEachAlive(function(daNote:Note)
				{
					// hold note functions
					if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
					&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
						goodNoteHit(daNote);
					}
				});
	
				if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong) {
					var canMiss:Bool = !ClientPrefs.ghostTapping;
					if (controlArray.contains(true)) {
						for (i in 0...controlArray.length) {
							// heavily based on my own code LOL if it aint broke dont fix it
							var pressNotes:Array<Note> = [];
							var notesDatas:Array<Int> = [];
							var notesStopped:Bool = false;
	
							var sortedNotesList:Array<Note> = [];
							notes.forEachAlive(function(daNote:Note)
							{
								if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
								&& !daNote.wasGoodHit && daNote.noteData == i) {
									sortedNotesList.push(daNote);
									notesDatas.push(daNote.noteData);
									canMiss = true;
								}
							});
							sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
							if (sortedNotesList.length > 0) {
								for (epicNote in sortedNotesList)
								{
									for (doubleNote in pressNotes) {
										if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
											doubleNote.kill();
											notes.remove(doubleNote, true);
											doubleNote.destroy();
										} else
											notesStopped = true;
									}
										
									// eee jack detection before was not super good
									if (controlArray[epicNote.noteData] && !notesStopped) {
										goodNoteHit(epicNote);
										pressNotes.push(epicNote);
									}
	
								}
							}
	
							// I dunno what you need this for but here you go
							//									- Shubs
	
							// Shubs, this is for the "Just the Two of Us" achievement lol
							//									- Shadow Mario
							if (!keysPressed[i] && controlArray[i]) 
								keysPressed[i] = true;
						}
					}
	
//					#if ACHIEVEMENTS_ALLOWED
//					var achieve:Int = checkForAchievement([12]);
//					if (achieve > -1) {
//						startAchievement(achieve);
//					}
//					#end
				} else {
					if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing')
						&& !boyfriend.animation.curAnim.name.endsWith('miss')) {
							boyfriend.dance();
						}
					if (SONG.player1 == 'duo-bfgf' || SONG.player1 == 'duo-viobotgf') {	
						if (girlfriend.holdTimer > Conductor.stepCrochet * 0.001 * girlfriend.singDuration && girlfriend.animation.curAnim.name.startsWith('sing')
							&& !girlfriend.animation.curAnim.name.endsWith('miss')) {
								girlfriend.dance();
							}
					}
				}
	
			playerStrums.forEach(function(spr:StrumNote)
			{
				if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
					spr.playAnim('pressed');
					spr.resetAnim = 0;
				}
				if(controlReleaseArray[spr.ID]) {
					spr.playAnim('static');
					spr.resetAnim = 0;
				}
			});
		}
	}

	function badNoteHit():Void {
		var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		for (i in 0...controlArray.length) {
			if(controlArray[i]) noteMiss(i);
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			if (curSong == 'Supernova') {
				health -= 0.02;
			} else {
				health -= 0.04;
			}
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) songMisses++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			//boyfriend.stunned = true;

			// get stunned for 5 seconds
			/*
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});
			*/

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function fakeNoteHit(note:Note):Void
	{
		if (curSong == 'Supernova') {
			health -= 0.075;
		} else {
			health -= 0.15;
		}
		
		if (curStage.startsWith('school')) {
			boyfriend.playAnim('singDOWNmiss', true);
		} else {
			boyfriend.playAnim('damaged', true);
		}
		boyfriend.specialAnim = true;
		boyfriend.heyTimer = 1;

		if (combo > 5 && gf.animOffsets.exists('sad'))
		{
			gf.playAnim('sad');
		}
		combo = 0;

		if (!practiceMode) songScore -= 10;
		if (!endingSong) songMisses++;
		RecalculateRating();

		if (!note.isSustainNote)
		{
			FlxTween.cancelTweensOf(note);
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}

		FlxG.sound.play(Paths.sound('bonk'), FlxG.random.float(0.2, 0.4));

		Achievements.starNotesHit++;

		var achieve:Int = checkForAchievement([5]);
		if(achieve > -1) {
			startAchievement(achieve);
		} else {
			FlxG.save.data.starNotesHit = Achievements.starNotesHit;
			FlxG.save.flush();
		}
	}

	function shieldNote(note:Note):Void {
		boyfriend.playAnim('hey', true);
		boyfriend.specialAnim = true;
		boyfriend.heyTimer = 0.6;

		if (!shieldOn) {
//			shieldTimer = new FlxPieDial(healthBarBG.x + healthBarBG.width + 200, healthBarBG.y - 100, 72, FlxColor.CYAN, 72, FlxPieDialShape.CIRCLE, true, 24);
//			shieldTimer.setGraphicSize(Std.int(shieldTimer.width * 0.5));
//			shieldTimer.cameras = [camHUD];
//			add(shieldTimer);
			FlxTween.tween(shieldIcon, {alpha: 0.75}, 1);
		} else {
			FlxTimer.globalManager.completeAll();
			FlxTween.cancelTweensOf(shieldIcon);
			FlxTween.tween(shieldIcon, {alpha: 0.75}, 1);
		}

//		shieldTimer.amount = 1;
		shieldOn = true;

		new FlxTimer().start(5, function(fuck) {
			shieldOn = false;
			FlxTween.tween(shieldIcon, {alpha: 0}, 1);
		});
		
//		FlxTween.tween(shieldTimer, {amount: 0}, 10, {onComplete: function(twn:FlxTween) {
//			shieldTimer.destroy();
//			shieldOn = false;
//			FlxTween.tween(shieldIcon, {alpha: 0}, 1);
//		}});

		FlxG.sound.play(Paths.sound('shieldNote'), FlxG.random.float(1.2, 1.5));

		if (!note.isSustainNote)
		{
			FlxTween.cancelTweensOf(note);
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (note.noteType == 4) {
				shieldNote(note);
				return;
			} else if (note.noteType == 3) {
				fakeNoteHit(note);
				return;
			} else if (note.noteType == 2) {
				boyfriend.playAnim('hey', true);
				boyfriend.specialAnim = true;
				boyfriend.heyTimer = 0.6;

				gf.playAnim('cheer', true);
				gf.specialAnim = true;
				gf.heyTimer = 0.6;
			} else {
				if (SONG.player1 == 'duo-bfgf' || SONG.player1 == 'duo-viobotgf') {
					if (note.noteType == 1) {
						switch (note.noteData)
						{
							case 0:
								girlfriend.playAnim('singLEFT', true);
								girlfriend.holdTimer = 0;
							case 1:
								girlfriend.playAnim('singDOWN', true);
								girlfriend.holdTimer = 0;
							case 2:
								girlfriend.playAnim('singUP', true);
								girlfriend.holdTimer = 0;
							case 3:
								girlfriend.playAnim('singRIGHT', true);
								girlfriend.holdTimer = 0;
						}
						followWho = girlfriend;
					} else {
						switch (note.noteData)
						{
							case 0:
								boyfriend.playAnim('singLEFT', true);
								girlfriend.holdTimer = 0;
							case 1:
								boyfriend.playAnim('singDOWN', true);
								girlfriend.holdTimer = 0;
							case 2:
								boyfriend.playAnim('singUP', true);
								girlfriend.holdTimer = 0;
							case 3:
								boyfriend.playAnim('singRIGHT', true);
								girlfriend.holdTimer = 0;
						}
						followWho = boyfriend;
					}
				} else {
					var daAlt = '';
					if (note.noteType == 1) daAlt = '-alt';
	
					switch (note.noteData)
					{
						case 0:
							boyfriend.playAnim('singLEFT' + daAlt, true);
						case 1:
							boyfriend.playAnim('singDOWN' + daAlt, true);
						case 2:
							boyfriend.playAnim('singUP' + daAlt, true);
						case 3:
							boyfriend.playAnim('singRIGHT' + daAlt, true);
					}
				}
			}

			if (note.noteType != 3) {
				if (!note.isSustainNote)
				{
					popUpScore(note);
					combo += 1;
				}

				if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004;

				note.wasGoodHit = true;
				vocals.volume = 1;
			}

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playAnim('confirm', true);
				}
			});

			if (!note.isSustainNote)
			{
				FlxTween.cancelTweensOf(note);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
	//	if(!ClientPrefs.lowQuality) halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

	//	boyfriend.playAnim('scared', true);
	//	gf.playAnim('scared', true);

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

		//	if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
		//		FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
		//		FlxTween.tween(camHUD, {zoom: 1}, 0.5);
		//	}
		}

		if(ClientPrefs.flashing) {
			FlxTween.cancelTweensOf(halloweenWhite);
			halloweenWhite.alpha = 0.45;
			FlxTween.tween(halloweenWhite, {alpha: 0.6}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	/*
	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;
				Achievements.henchmenDeath++;

				var achieve:Int = checkForAchievement([9]);
				if(achieve > -1) {
					startAchievement(achieve);
				} else {
					FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
			}
		}
	}
	*/

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && !gf.specialAnim)
		{
			gf.dance();
		}

		if (curSong == 'Supernova') {
			if (curBeat % gfSpeed == 0 && !viobot.stunned && !viobot.specialAnim)
			{
				viobot.dance();
			}
		}


		if(curBeat % 2 == 0) {
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.specialAnim)
			{
				boyfriend.dance();
			}
			if (SONG.player1 == 'duo-bfgf' || SONG.player1 == 'duo-viobotgf') {
				if (!girlfriend.animation.curAnim.name.startsWith("sing") && !girlfriend.stunned)
					girlfriend.dance();
			}
			if (!dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
			if (dad.curCharacter == 'venturers') {
				if (!cardinal.animation.curAnim.name.startsWith("sing") && !cardinal.stunned)
					cardinal.dance();
				if (!pistachio.animation.curAnim.name.startsWith("sing") && !pistachio.stunned)
					pistachio.dance();
				if (!azura.animation.curAnim.name.startsWith("sing") && !azura.stunned)
					azura.dance();
				if (!banana.animation.curAnim.name.startsWith("sing") && !banana.stunned)
					banana.dance();
			}
//			if (curSong == 'Corruption') {
//				if (viobot.heyTimer == 0)
//					viobot.dance();
//			}
		} else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.animation.play('bop', true);
				}

				if(heyTimer <= 0) bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
				
			case 'arena':
				if (!ClientPrefs.lowQuality) {
					if (curSong != 'Psychic') {
						if (curBeat % 2 == 0) {
							crowd.animation.play('bop', true);
							lights.animation.play('flash', true);
							speakers.animation.play('bounce', true);
						}
					}
				}
				if ((curBeat % 4 == 0) && doFloodLights) {
					floodLights.alpha = 1;
				}
			
			case 'temple': {
				if ((curBeat % 16 == 0) && !doFloodLights) {
					if (templeLight.alpha > 0.35) {
						FlxTween.tween(templeLight, { alpha: 0.15 }, 6, { ease: FlxEase.smootherStepInOut });
						//if (doFloodLights)
						//	FlxTween.tween(stageDarkness, { alpha: 1 }, 6, { ease: FlxEase.smootherStepInOut });
					} else {
						FlxTween.tween(templeLight, { alpha: 0.65 }, 6, { ease: FlxEase.smootherStepInOut });
						//if (doFloodLights)
						//	FlxTween.tween(stageDarkness, { alpha: 0.5 }, 6, { ease: FlxEase.smootherStepInOut });
					}
				}
			}
		}

		if (curStage == 'foreverfall' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function DadStrumPlayAnim(id:Int, time:Float) {
		var spr:StrumNote = strumLineNotes.members[id];
		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	var ratingString:String;
	var ratingPercent:Float;
	function RecalculateRating() {
		ratingPercent = songScore / ((songHits + songMisses) * 350);
		if(!Math.isNaN(ratingPercent) && ratingPercent < 0) ratingPercent = 0;

		if(Math.isNaN(ratingPercent)) {
			ratingString = '?';
		} else if(ratingPercent >= 1) {
			ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
		} else {
			for (i in 0...ratingStuff.length-1) {
				if(ratingPercent < ratingStuff[i][1]) {
					ratingString = ratingStuff[i][0];
					break;
				}
			}
		}
	}

	private function checkForAchievement(arrayIDs:Array<Int>):Int {
		for (i in 0...arrayIDs.length) {
			if (!Achievements.achievementsUnlocked[arrayIDs[i]][1]) {
				switch(arrayIDs[i]) {
					case 0:
						if(isStoryMode && storyPlaylist.length <= 1 && storyWeek == 1 && !changedDifficulty && !usedPractice && storyDifficulty == 2) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 1:
						if(isStoryMode && campaignMisses < 1 && songMisses < 1 && storyPlaylist.length <= 1 && storyWeek == 1 && !changedDifficulty && !usedPractice && storyDifficulty == 2) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 2:
						if(SONG.song.toLowerCase() == 'the-ups-and-downs' && !usedPractice && storyDifficulty == 2) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 3:
						if(isStoryMode && storyPlaylist.length <= 1 && storyWeek == 2 && !changedDifficulty && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 4:
						if(isStoryMode && campaignMisses < 1 && songMisses < 1 && storyPlaylist.length <= 1 && storyWeek == 2 && !changedDifficulty && !usedPractice) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
					case 5:
						if(Achievements.starNotesHit >= 100) {
							Achievements.unlockAchievement(arrayIDs[i]);
							return arrayIDs[i];
						}
				}
			}
		}
		return -1;
	}

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}

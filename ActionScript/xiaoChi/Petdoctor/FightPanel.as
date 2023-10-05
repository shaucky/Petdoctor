package xiaoChi.Petdoctor
{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.net.URLRequest;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	import flash.display.LoaderInfo;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.StageQuality;

	public class FightPanel extends Sprite
	{
		private const scene: Sprite = new Sprite();
		private const loaders: Array = new Array(new Loader(), new Loader(), new Loader(), new Loader(), new Loader(), new Loader());
		private var myFightAnime: Sprite = null;
		private var myFightHead: Sprite = null;
		private var otherFightAnime: Sprite = null;
		private var otherFightHead: Sprite = null;
		private var tempFightAnime: Sprite = null;
		private var tempFightHead: Sprite = null;
		private var currFightAnime: Sprite = null;
		private var currFightHead: Sprite = null;
		private const starAngrySkillLoader: Loader = new Loader();
		public var extension: String = "null";
		private var playingAction: String = "attack";
		private const animeControl: AnimeControl = new AnimeControl();
		private var myLoadingTips: LoadingTips;
		private var myLoadingTimer: Timer;
		private var myFileName: String;
		private var otherLoadingTips: LoadingTips;
		private var otherLoadingTimer: Timer;
		private var otherFileName: String;
		private var switchBar: MovieClip;
		private var qualityList: MovieClip;
		private function loader(i: uint): Loader
		{
			return loaders[i - 1];
		}

		public function FightPanel()
		{
			this.addChildAt(scene, 0);
			this.addChild(animeControl);
			switchBar = getChildByName("controlMC").getChildByName("switchMC");
			switchBar.getChildByName("perform").visible = false; //先不用它
			qualityList = switchBar.getChildByName("qualityList");
			qualityList.getChildByName("quality_mc_0").gotoAndStop(2);
			qualityList.getChildByName("quality_mc_1").gotoAndStop(2);
			qualityList.getChildByName("quality_mc_2").gotoAndStop(1);
			myFightHead = getChildByName("myInfoPanel").getChildByName("iconMC");
			while (myFightHead.numChildren)
			{
				myFightHead.removeChildAt(0);
			}
			myFightHead.addChild(loader(4));
			otherFightHead = getChildByName("otherInfoPanel").getChildByName("iconMC")
			while (otherFightHead.numChildren)
			{
				otherFightHead.removeChildAt(0);
			}
			otherFightHead.addChild(loader(5));
			switchBar.getChildByName("quality").addEventListener(MouseEvent.CLICK, changeStageQuality);
			hideSkill.clickIcon.addEventListener(MouseEvent.CLICK, playExtension);
			animeControl.attack.addEventListener(MouseEvent.CLICK, playAttack);
			animeControl.sa.addEventListener(MouseEvent.CLICK, playSa);
			animeControl.cp.addEventListener(MouseEvent.CLICK, playCp);
			animeControl.appear.addEventListener(MouseEvent.CLICK, playAppear);
		}
		public function loadPets(id1: String, id2: String, id3: String = null, useLocal: Boolean = false, localURL: String = null): void
		{
			var i: int = 0;
			var arrayLength: uint = 0;
			const ids: Array = new Array(id1, id2, id3);
			while (scene.numChildren > 0)
			{
				scene.removeChildAt(0);
			}
			myFightAnime = null;
			otherFightAnime = null;
			tempFightAnime = null;
			starAngrySkillLoader.unload();
			for each(var ldr in loaders)
			{
				if (ldr.content)
				{
					ldr.unload();
				}
			}
			i = 0;
			arrayLength = loaders.length;
			while (i < Math.floor(arrayLength * 1 / 2))
			{
				if (ids[i % 3])
				{
					loaders[i].load(new URLRequest(this.getFightAnimeURL(ids[i % 3])));
					loaders[i].contentLoaderInfo.addEventListener(PetdoctorEvent.COMPLETE, animeLoaded);
					loaders[i].contentLoaderInfo.addEventListener(PetdoctorEvent.IO_ERROR, animeLoadFailed);
				}
				i++;
			}
			while (i < Math.floor(arrayLength * 2 / 2))
			{
				if (ids[i % 3])
				{
					loaders[i].load(new URLRequest(this.getFightHeadURL(ids[i % 3])));
					loaders[i].contentLoaderInfo.addEventListener(PetdoctorEvent.IO_ERROR, animeLoadFailed);
				}
				i++;
			}
			myFileName = getFightAnimeURL(id1).match(/\/?[^\/]*?$/)[0].replace("/", "");
			otherFileName = getFightAnimeURL(id2).match(/\/?[^\/]*?$/)[0].replace("/", "");
			if (useLocal)
			{
				loaders[0].unload();
				loaders[0].load(new URLRequest(localURL));
				myFileName = localURL.match(/\/?[^\/]*?$/)[0].replace("/", "");
			}
			if (extension == "sa")
			{
				starAngrySkillLoader.contentLoaderInfo.addEventListener(PetdoctorEvent.IO_ERROR, starAngrySkillLoadFailed);
				starAngrySkillLoader.contentLoaderInfo.addEventListener(PetdoctorEvent.COMPLETE, starAngrySkillLoaded);
				starAngrySkillLoader.load(new URLRequest("https://seer.61.com/resource/fightResource/skill/swf/" + (500000 + Number(id1)) + "1" + ".swf"));
			}
			if (myLoadingTips)
			{
				if (myLoadingTips.parent)
				{
					myLoadingTips.parent.removeChild(myLoadingTips);
				}
				myLoadingTips = null;
			}
			myLoadingTips = new LoadingTips();
			myLoadingTips.x = 180;
			myLoadingTips.y = 260;
			if (otherLoadingTips)
			{
				if (otherLoadingTips.parent)
				{
					otherLoadingTips.parent.removeChild(otherLoadingTips);
				}
				otherLoadingTips = null;
			}
			otherLoadingTips = new LoadingTips();
			otherLoadingTips.x = 780;
			otherLoadingTips.y = 260;
			otherLoadingTips.scaleX = -1;
			(otherLoadingTips.getChildAt(0) as TextField).x = -(otherLoadingTips.getChildAt(0) as TextField).x;
			(otherLoadingTips.getChildAt(0) as TextField).scaleX = -1;
			scene.addChild(myLoadingTips);
			myLoadingTimer = new Timer(200);
			myLoadingTimer.start();
			myLoadingTimer.addEventListener(TimerEvent.TIMER, function (e: TimerEvent)
			{
				if (myLoadingTips)
				{
					if (!myLoadingTips.parent)
					{
						myLoadingTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
						myLoadingTips = null;
					}
					else
					{
						(myLoadingTips.getChildAt(0) as TextField).text = myFileName + "\n" + getBytesNumString(loaders[0].contentLoaderInfo.bytesLoaded) + "/" + getBytesNumString(loaders[0].contentLoaderInfo.bytesTotal);
					}
				}
			});
			otherLoadingTimer = new Timer(200);
			otherLoadingTimer.start();
			otherLoadingTimer.addEventListener(TimerEvent.TIMER, function (e: TimerEvent)
			{
				if (otherLoadingTips)
				{
					if (!otherLoadingTips.parent)
					{
						otherLoadingTimer.removeEventListener(TimerEvent.TIMER, arguments.callee);
						otherLoadingTips = null;
					}
					else
					{
						(otherLoadingTips.getChildAt(0) as TextField).text = otherFileName + "\n" + getBytesNumString(loaders[2].contentLoaderInfo.bytesLoaded) + "/" + getBytesNumString(loaders[1].contentLoaderInfo.bytesTotal);
					}
				}
			});
			scene.addChild(otherLoadingTips);
			function starAngrySkillLoadFailed(e: Event)
			{
				e.target.removeEventListener(PetdoctorEvent.IO_ERROR, starAngrySkillLoadFailed);
				starAngrySkillLoader.load(new URLRequest("https://seer.61.com/resource/fightResource/skill/swf/" + 1900032911 + ".swf"));
			}
			function starAngrySkillLoaded(e: Event)
			{
				e.target.removeEventListener(PetdoctorEvent.IO_ERROR, starAngrySkillLoadFailed);
				e.target.removeEventListener(PetdoctorEvent.COMPLETE, starAngrySkillLoaded);
				output("加载完毕：" + "星皇之怒横条");
			}
		}
		private function animeLoaded(e: Event)
		{
			var domain: ApplicationDomain = (e.target as LoaderInfo).applicationDomain;
			var i: int = 0;
			e.target.removeEventListener(PetdoctorEvent.COMPLETE, animeLoaded);
			e.target.removeEventListener(PetdoctorEvent.IO_ERROR, animeLoadFailed);
			output("加载完毕：" + e.target.url);
			while (i < loaders.length)
			{
				if (loaders[i] == e.target.loader)
				{
					break;
				}
				i++;
			}
			this.addFightAnime(new(domain.getDefinition("pet") as Class)(), i + 1);
		}
		private function animeLoadFailed(e: Event)
		{
			e.target.removeEventListener(PetdoctorEvent.COMPLETE, animeLoaded);
			e.target.removeEventListener(PetdoctorEvent.IO_ERROR, animeLoadFailed);
			output("加载失败：" + e.target.url);
		}
		private function addFightAnime(anime: DisplayObject, id: int)
		{
			if (id == 1)
			{
				this.scene.addChild(anime);
				myFightAnime = anime;
				myFightAnime.scaleX = 1;
				myFightAnime.scaleY = 1;
				myFightAnime.x = 180;
				myFightAnime.y = 260;
				if (myLoadingTips)
				{
					if (myLoadingTips.parent)
					{
						myLoadingTips.parent.removeChild(myLoadingTips);
					}
					myLoadingTips = null;
				}
				currFightAnime = myFightAnime;
			}
			else if (id == 2)
			{
				this.scene.addChild(anime);
				otherFightAnime = anime;
				otherFightAnime.scaleX = -1;
				otherFightAnime.scaleY = 1;
				otherFightAnime.x = 780;
				otherFightAnime.y = 260;
				if (otherLoadingTips)
				{
					if (otherLoadingTips.parent)
					{
						otherLoadingTips.parent.removeChild(otherLoadingTips);
					}
					otherLoadingTips = null;
				}
			}
			else if (id == 3)
			{
				tempFightAnime = anime;
				tempFightAnime.scaleX = 1;
				tempFightAnime.scaleY = 1;
				tempFightAnime.x = 180;
				tempFightAnime.y = 260;
			}
		}
		private function getFightAnimeURL(id: String): String
		{
			const str: String = "https://seer.61.com/resource/fightResource/pet/swf/" + id + ".swf";
			return str;
		}
		private function getFightHeadURL(id: String): String
		{
			const str: String = "https://seer.61.com/resource/pet/head/" + id + ".swf";
			return str;
		}
		private function getBytesNumString(bytes: uint): String
		{
			var str: String;
			if (bytes < 1024)
			{
				str = bytes + "B";
			}
			else if (bytes < 1024 * 1024)
			{
				str = String(Math.floor(bytes / 1024 * 1000) / 1000) + "KB";
			}
			else if (bytes < 1024 * 1024 * 1024)
			{
				str = String(Math.floor(bytes / 1024 / 1024 * 1000) / 1000) + "MB";
			}
			else if (bytes < 1024 * 1024 * 1024 * 1024)
			{
				str = String(Math.floor(bytes / 1024 / 1024 / 1024 * 1000) / 1000) + "GB";
			}
			return str;
		}

		private function changeStageQuality(e: MouseEvent)
		{
			if (stage.quality == StageQuality.HIGH.toUpperCase())
			{
				stage.quality = StageQuality.MEDIUM.toUpperCase();
				qualityList.getChildByName("quality_mc_0").gotoAndStop(2);
				qualityList.getChildByName("quality_mc_1").gotoAndStop(1);
				qualityList.getChildByName("quality_mc_2").gotoAndStop(2);
			}
			else if (stage.quality == StageQuality.MEDIUM.toUpperCase())
			{
				stage.quality = StageQuality.LOW.toUpperCase();
				qualityList.getChildByName("quality_mc_0").gotoAndStop(1);
				qualityList.getChildByName("quality_mc_1").gotoAndStop(2);
				qualityList.getChildByName("quality_mc_2").gotoAndStop(2);
			}
			else if (stage.quality == StageQuality.LOW.toUpperCase())
			{
				stage.quality = StageQuality.HIGH.toUpperCase();
				qualityList.getChildByName("quality_mc_0").gotoAndStop(2);
				qualityList.getChildByName("quality_mc_1").gotoAndStop(2);
				qualityList.getChildByName("quality_mc_2").gotoAndStop(1);
			}
			output("stage品质修改：" + stage.quality);
		}

		private function playExtension(e: MouseEvent)
		{
			switch (extension)
			{
				case "ca":
					clearEventListener(currFightAnime);
					currFightAnime.gotoAndStop("transform");
					playingAction = "transform";
					output("【" + myInfoPanel.name_txt.text + "】使用了" + "形态切换");
					currFightAnime.addEventListener(PetdoctorEvent.EXIT_FRAME, startPlayTransform);
					break;
				case "a1":
					clearEventListener(currFightAnime);
					try
					{
						currFightAnime.gotoAndStop("attack1");
						playingAction = "attack";
						output("【" + myInfoPanel.name_txt.text + "】使用了" + "特殊技能");
					}
					catch (e: Error)
					{
						try
						{
							currFightAnime.gotoAndStop("sa5");
							playingAction = "sa";
							output("【" + myInfoPanel.name_txt.text + "】使用了" + "特殊技能");
						}
						catch (e: Error)
						{
							return;
						}
					}
					currFightAnime.addEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
					break;
			}
		}
		private function playAttack(e: MouseEvent)
		{
			clearEventListener(currFightAnime);
			currFightAnime.gotoAndStop("attack");
			playingAction = "attack";
			output("【" + myInfoPanel.name_txt.text + "】使用了" + "物理攻击");
			currFightAnime.addEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
		}
		private function playSa(e: MouseEvent)
		{
			clearEventListener(currFightAnime);
			currFightAnime.gotoAndStop("sa");
			playingAction = "sa";
			output("【" + myInfoPanel.name_txt.text + "】使用了" + "特殊攻击");
			currFightAnime.addEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
		}
		private function playCp(e: MouseEvent)
		{
			clearEventListener(currFightAnime);
			currFightAnime.gotoAndStop("cp");
			playingAction = "cp";
			output("【" + myInfoPanel.name_txt.text + "】使用了" + "属性攻击");
			currFightAnime.addEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
		}
		private function playAppear(e: MouseEvent)
		{
			clearEventListener(currFightAnime);
			if (currFightAnime.currentLabel != "appear")
			{
				currFightAnime.gotoAndStop("appear");
			}
			else
			{
				currFightAnime.getChildAt(0).gotoAndStop(1);
				try
				{
					currFightAnime.getChildAt(0).getChildAt(0).gotoAndPlay(1);
				}
				catch (e: TypeError)
				{}
			}
			playingAction = "appear";
			output("【" + myInfoPanel.name_txt.text + "】使用了" + "出场动作");
			currFightAnime.addEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
		}
		private function startPlay(e: Event)
		{
			scene.addChild(currFightAnime);
			currFightAnime.removeEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
			currFightAnime.getChildAt(0).gotoAndPlay(1);
			currFightAnime.getChildAt(0).addEventListener(PetdoctorEvent.EXIT_FRAME, onPlaying);
			timeCounter.visible = false;
		}
		private function onPlaying(e: Event)
		{
			if (e.target.parent.parent == scene)
			{
				if (currFightAnime.getChildAt(0).hit == 1 && otherFightAnime.currentLabel != "hited" && currFightAnime.currentLabel != "appear")
				{
					otherFightAnime.gotoAndStop("hited");
				}
				else if (currFightAnime.getChildAt(0).hit == 1 && otherFightAnime.currentLabel == "hited" && currFightAnime.currentLabel != "appear")
				{
					otherFightAnime.getChildAt(0).play();
					output("【" + otherInfoPanel.name_txt.text + "】状态：" + "〖免疫〗");
					otherFightAnime.addEventListener(Event.ENTER_FRAME, onTheOtherHited);
					currFightAnime.getChildAt(0).hit = 0;
				}
				else if (currFightAnime.getChildAt(0).currentFrame == currFightAnime.getChildAt(0).totalFrames - 2 && currFightAnime.currentLabel == "appear")
				{
					currFightAnime.getChildAt(0).removeEventListener(PetdoctorEvent.EXIT_FRAME, onPlaying);
					currFightAnime.getChildAt(0).stop();
					currFightAnime.getChildAt(0).getChildAt(0).stop();
					timeCounter.visible = true;
					timeCounter.getChildAt(1).gotoAndPlay(1);
				}
				else if (currFightAnime.getChildAt(0).currentFrame == currFightAnime.getChildAt(0).totalFrames - 1)
				{
					currFightAnime.getChildAt(0).removeEventListener(PetdoctorEvent.EXIT_FRAME, onPlaying);
					timeCounter.visible = true;
					timeCounter.getChildAt(1).gotoAndPlay(1);
					currFightAnime.getChildAt(0).gotoAndStop(1);
					otherFightAnime.getChildAt(0).gotoAndStop(1);
					currFightAnime.getChildAt(0).hit = 0;
					if (extension == "sa")
					{
						startPlayStarAngry();
					}
				}
			}
		}
		private function onTheOtherHited(e: Event)
		{
			if ((e.target) == otherFightAnime)
			{
				if (otherFightAnime.getChildAt(0).currentFrame == otherFightAnime.getChildAt(0).totalFrames)
				{
					otherFightAnime.getChildAt(0).stop();
					otherFightAnime.removeEventListener(Event.ENTER_FRAME, onTheOtherHited);
				}
			}
		}
		private function startPlayStarAngry()
		{
			var skill: Sprite;
			var domain: ApplicationDomain = starAngrySkillLoader.contentLoaderInfo.applicationDomain;
			timeCounter.visible = false;
			if (!tempFightAnime)
			{
				tempFightAnime = myFightAnime;
			}
			scene.removeChild(myFightAnime);
			scene.addChild(tempFightAnime);
			tempFightAnime.gotoAndStop(playingAction);
			output("【" + myInfoPanel.name_txt.text + "】使用了" + "星皇之怒");
			tempFightAnime.addEventListener("exitFrame", startStarAngry);
			if (starAngrySkillLoader.content)
			{
				skill = new(domain.getDefinition("skill") as Class)();
			}
			skill.addEventListener(Event.EXIT_FRAME, skillExitedFrame);
			scene.addChild(skill);
			function startStarAngry(e: Event)
			{
				tempFightAnime.removeEventListener(PetdoctorEvent.EXIT_FRAME, startStarAngry);
				tempFightAnime.getChildAt(0).gotoAndPlay(1);
				tempFightAnime.getChildAt(0).addEventListener(PetdoctorEvent.EXIT_FRAME, onPlayingStarAngry);
			}
			function skillExitedFrame(e: Event)
			{
				if (e.target.parent == scene)
				{
					if (e.target.currentFrame == e.target.totalFrames)
					{
						e.target.removeEventListener(PetdoctorEvent.EXIT_FRAME, skillExitedFrame);
						e.target.parent.removeChild(e.target);
					}
				}
			}
		}
		private function onPlayingStarAngry(e: Event)
		{
			if (e.target.parent.parent == scene)
			{
				if (tempFightAnime.getChildAt(0).hit == 1 && otherFightAnime.currentLabel != "hited")
				{
					otherFightAnime.gotoAndStop("hited");
				}
				else if (tempFightAnime.getChildAt(0).hit == 1 && otherFightAnime.currentLabel == "hited" && tempFightAnime.currentLabel != "appear")
				{
					otherFightAnime.getChildAt(0).play();
					output("【" + otherInfoPanel.name_txt.text + "】状态：" + "〖免疫〗");
					otherFightAnime.addEventListener(Event.ENTER_FRAME, onTheOtherHited);
					tempFightAnime.getChildAt(0).hit = 0;
				}
				else if (tempFightAnime.getChildAt(0).currentFrame == tempFightAnime.getChildAt(0).totalFrames - 1)
				{
					tempFightAnime.getChildAt(0).removeEventListener(PetdoctorEvent.EXIT_FRAME, onPlayingStarAngry);
					timeCounter.visible = true;
					timeCounter.getChildAt(1).gotoAndPlay(1);
					if (tempFightAnime.currentLabel != "appear")
					{
						tempFightAnime.getChildAt(0).gotoAndStop(1);
						otherFightAnime.getChildAt(0).gotoAndStop(1);
						tempFightAnime.getChildAt(0).hit = 0;
						scene.removeChild(tempFightAnime);
						scene.addChild(myFightAnime);
					}
					else
					{
						currFightAnime.getChildAt(0).gotoAndStop(currFightAnime.getChildAt(0).totalFrames);
					}
					if (tempFightAnime == myFightAnime)
					{
						tempFightAnime = null;
					}
				}
			}
		}
		private function startPlayTransform(e: Event)
		{
			if (tempFightAnime)
			{
				scene.addChild(currFightAnime);
				currFightAnime.removeEventListener(PetdoctorEvent.EXIT_FRAME, startPlayTransform);
				currFightAnime.getChildAt(0).gotoAndPlay(1);
				currFightAnime.getChildAt(0).addEventListener(PetdoctorEvent.EXIT_FRAME, onPlayingTransform);
				timeCounter.visible = false;
			}
		}
		private function onPlayingTransform(e: Event)
		{
			if (currFightAnime.getChildAt(0).currentFrame == currFightAnime.getChildAt(0).totalFrames - 1)
			{
				currFightAnime.getChildAt(0).removeEventListener(PetdoctorEvent.EXIT_FRAME, onPlayingTransform);
				currFightAnime.gotoAndStop("attack");
				scene.removeChild(currFightAnime);
				currFightAnime = (currFightAnime == myFightAnime) ? tempFightAnime : myFightAnime;
				scene.addChild(currFightAnime);
				currFightAnime.getChildAt(0).gotoAndStop(1);
				timeCounter.visible = true;
				timeCounter.getChildAt(1).gotoAndPlay(1);
			}
		}

		private function clearEventListener(target: Sprite)
		{
			target.removeEventListener(PetdoctorEvent.EXIT_FRAME, startPlay);
			target.getChildAt(0).removeEventListener(PetdoctorEvent.EXIT_FRAME, onPlaying);
			target.removeEventListener(PetdoctorEvent.EXIT_FRAME, startPlayTransform);
			target.getChildAt(0).removeEventListener(PetdoctorEvent.EXIT_FRAME, onPlayingTransform);
		}
	}
}
/**
 * 2022年重构的Petdoctor，
 * 是一款基于AIR开发的赛尔号Flash页游对战动画播放器。
 * 由于重构之初并没有发行和开源的打算，
 * 因此目前版本的代码结构较混乱。
 * 代码不支持独立编译，
 * 需要配合Flash资源。
 * 2017 - 2023 @xiaoChi copyright.
 * Licensed under the Boost Software License 1.0.
 */

package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.desktop.NativeApplication;
	import flash.display.Shape;
	import flash.system.System;
	import xiaoChi.Petdoctor.BackgroundPanel;
	import xiaoChi.Petdoctor.FightBackground;
	import xiaoChi.Petdoctor.FightPanel;
	import xiaoChi.Petdoctor.InfoPanel;
	import xiaoChi.Petdoctor.PetdoctorEvent;
	import xiaoChi.Petdoctor.SetPanel;
	import xiaoChi.Petdoctor.TimeLineTester;
	import flash.text.TextField;

	public class Main extends Sprite
	{
		private static const appDescriptor: XML = NativeApplication.nativeApplication.applicationDescriptor;
		private static const desNamespace: Namespace = appDescriptor.namespace();
		private static const appVer: String = appDescriptor.desNamespace::versionLabel;
		private static var _outputField: TextField;
		private const m: Shape = new Shape();
		internal const bg: FightBackground = new FightBackground();
		internal const fightPanel: FightPanel = new FightPanel();
		internal const setPanel: SetPanel = new SetPanel();
		internal const infoPanel: InfoPanel = new InfoPanel();
		internal const backgroundPanel: BackgroundPanel = new BackgroundPanel();
		internal const timeLineTester: TimeLineTester = new TimeLineTester();
		internal var recentlyFrames: int = 0;
		internal const timer: Timer = new Timer(1000);
		public static function get outputField(): TextField
		{
			return _outputField;
		}
		public static function set outputField(value: TextField)
		{
			if (!_outputField)
			{
				_outputField = value;
			}
		}

		//主构造函数，负责程序初始化
		public function Main()
		{
			this.addChild(bg);
			this.addChild(fightPanel);
			this.addChild(setPanel);
			this.addChild(infoPanel);
			this.addChild(backgroundPanel);
			this.parent.addChild(m);
			this.parent.addChild(timeLineTester);
			setPanel.visible = false;
			infoPanel.visible = false;
			backgroundPanel.visible = false;
			backgroundPanel.bgSpr = bg;
			m.graphics.beginFill(0x0f0f0f, 0);
			m.graphics.drawRect(0, 0, 960, 560);
			m.graphics.endFill();
			mask = m;
			fightPanel.versionInfo.text = "Version: Petdoctor " + appVer + "	" + "Runtime: AIR " + NativeApplication.nativeApplication.runtimeVersion;
			fightPanel.controlMC.pet_btn.addEventListener("click", openSetPanel);
			fightPanel.controlMC.item_btn.addEventListener("click", openInfoPanel);
			fightPanel.controlMC.catch_btn.addEventListener("click", openBackgroundPanel);
			fightPanel.controlMC.run_btn.addEventListener("click", exitApp);
			setPanel.addEventListener("set", reloadFightAnime);
			outputField = fightPanel.msgMC.msg_txt as TextField;
			outputField.text = "";
			timeLineTester.addEventListener("exitFrame", countFrames);
			timer.addEventListener("timer", calculateFrames);
			timer.start();
			test();
		}
		private function openSetPanel(e: MouseEvent): void
		{
			this.addChild(setPanel);
			setPanel.visible = true;
		}
		private function openInfoPanel(e: MouseEvent)
		{
			this.addChild(infoPanel);
			infoPanel.open();
		}
		private function openBackgroundPanel(e: MouseEvent): void
		{
			this.addChild(backgroundPanel);
			backgroundPanel.visible = true;
		}
		private function exitApp(e: MouseEvent)
		{
			NativeApplication.nativeApplication.exit();
		}

		//加载对战动画
		internal function reloadFightAnime(e: Event)
		{
			var extID: String = null;
			fightPanel.extension = setPanel.hideSkillAction;
			switch (setPanel.hideSkillAction)
			{
				case "null":
					break;
				case "sa":
					if (Number(setPanel.id1.text) < 10000)
					{
						extID = String(Number(setPanel.id1.text) + 190000000);
					}
					else
					{
						extID = String(Number(setPanel.id1.text) + 500000);
					}
					break;
				case "ca":
					if (Number(setPanel.id1.text) < 10000)
					{
						extID = String(Number(setPanel.id1.text) + 290000000);
					}
					else
					{
						extID = String(Number(setPanel.id1.text) + 1500000);
					}
					break;
			}
			fightPanel.loadPets(setPanel.id1.text, setPanel.id2.text, extID, setPanel.useLocal, setPanel.localFilePath.text);
		}

		//帧率计算工具
		private function countFrames(e: Event)
		{
			recentlyFrames++;
		}
		private function calculateFrames(e: Event)
		{
			//System.gc(); //在Loader加载中调用GC会导致Loader domain出错
			fightPanel.recentlyFrames.text = "Memory：" + Math.round((System.privateMemory / 1024 / 1024 * 100)) / 100 + "MB" + "	" + "Frame Rate：" + recentlyFrames + "FPS";
			recentlyFrames = 0;
		}

		//测试用函数，也是现在的初始化函数部分
		private function test(): void
		{
			fightPanel.loadPets("1", "1");
			output("stage品质：" + stage.quality);
		}
	}
}
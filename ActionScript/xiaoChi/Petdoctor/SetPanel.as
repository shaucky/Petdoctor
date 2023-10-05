package xiaoChi.Petdoctor
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.SharedObject;

	public class SetPanel extends Sprite
	{
		private const localFile: File = File.documentsDirectory;
		private var currentCheckBox: HideSkillCheckBox;
		private var sharedFilePath: SharedObject;
		public var hideSkillAction: String = "null";
		public var useLocal: Boolean = false;

		public function SetPanel()
		{
			var i: uint = 0;
			while (i < this.numChildren)
			{
				if (this.getChildAt(i) is HideSkillCheckBox)
				{
					(this.getChildAt(i) as HideSkillCheckBox).addEventListener(MouseEvent.CLICK, checkBoxClick);
				}
				i++;
			}
			this.cb_useLocal.addEventListener(MouseEvent.CLICK, useLocalCheckBoxClick);
			this.localFilePath.text = localFile.url;
			this.useLocalSelect.visible = false;
			this.checkBoxSelect.visible = false;
			this.closeButton.addEventListener(MouseEvent.CLICK, close);
			this.browseLocalButton.addEventListener(MouseEvent.CLICK, browseLocal);
			this.saveSetButton.addEventListener(MouseEvent.CLICK, dispatchSetting);
			localFile.addEventListener(Event.SELECT, selectedFile);
			sharedFilePath = SharedObject.getLocal("localPetFilePath");
			if (sharedFilePath.data.path)
			{
				localFile.url = sharedFilePath.data.path;
				this.localFilePath.text = localFile.url;
				this.localFilePath.scrollH = this.localFilePath.maxScrollH;
			}
			sharedFilePath = null;
		}
		public function close(e: MouseEvent): void
		{
			this.visible = false;
		}
		private function browseLocal(e: MouseEvent)
		{
			localFile.browseForOpen("选择对战动画SWF文件", new Array(new FileFilter("Shockwave Flash", "*.swf")));
		}
		private function selectedFile(e: Event)
		{
			this.localFilePath.text = localFile.url;
			this.localFilePath.scrollH = this.localFilePath.maxScrollH;
			sharedFilePath = SharedObject.getLocal("localPetFilePath");
			sharedFilePath.data.path = localFile.url;
			sharedFilePath = null;
		}
		private function useLocalCheckBoxClick(e: MouseEvent)
		{
			this.useLocalSelect.visible = !this.useLocalSelect.visible;
			useLocal = this.useLocalSelect.visible;
		}
		public function dispatchSetting(e: MouseEvent): void
		{
			this.dispatchEvent(new PetdoctorEvent(PetdoctorEvent.SET));
		}
		private function checkBoxClick(e: MouseEvent)
		{
			if (e.target == currentCheckBox)
			{
				output("取消第五技能。");
				hideSkillAction = "null";
				currentCheckBox = null;
				this.checkBoxSelect.visible = false;
			}
			else
			{
				switch (e.target)
				{
					case cb_starAngery:
						output("选中星皇之怒。");
						hideSkillAction = "sa";
						break;
					case cb_changeAppear:
						output("选中形态切换。");
						hideSkillAction = "ca";
						break;
					case cb_attack1:
						output("选中特殊技能。");
						hideSkillAction = "a1";
						break;
				}
				currentCheckBox = e.target;
				this.checkBoxSelect.visible = true;
				this.checkBoxSelect.x = e.target.x;
				this.checkBoxSelect.y = e.target.y;
			}
		}
	}
}
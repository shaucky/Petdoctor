package xiaoChi.Petdoctor
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.net.URLRequest;
	import flash.display.BitmapData;
	import flash.display.Bitmap;

	public class BackgroundPanel extends Sprite
	{ //https://seer.61.com/resource/map/1.swf
		private var bgLdr: Loader;
		private const bgShp: Shape = new Shape();
		public var bgSpr: Sprite;

		public function BackgroundPanel()
		{
			bgShp.graphics.beginFill(0x000000, 0.5);
			bgShp.graphics.drawRect(0, 0, 960, 560);
			bgShp.graphics.endFill();
			this.closeButton.addEventListener(MouseEvent.CLICK, close);
			this.saveSetButton.addEventListener(MouseEvent.CLICK, saveSettings);
		}
		public function close(e: MouseEvent)
		{
			this.visible = false;
		}
		private function saveSettings(e: MouseEvent)
		{
			if (!bgLdr)
			{
				bgLdr = new Loader();
				bgLdr.contentLoaderInfo.addEventListener(PetdoctorEvent.COMPLETE, backgroundLoaded);
			}
			bgLdr.load(new URLRequest("https://seer.61.com/resource/map/" + this.mapId.text + ".swf"));
		}
		private function backgroundLoaded(e: Event)
		{
			var bitmap: Bitmap;
			var bitmapData: BitmapData;
			var tempContainer: Sprite;
			e.target.removeEventListener(PetdoctorEvent.COMPLETE, backgroundLoaded);
			while (bgSpr.numChildren)
			{
				bgSpr.removeChildAt(0);
			}
			bitmapData = new BitmapData(960, 560, true, 0x00000000);
			tempContainer = new Sprite();
			tempContainer.addChild(e.target.content);
			tempContainer.addChild(bgShp);
			bitmapData.draw(tempContainer);
			bitmap = new Bitmap(bitmapData);
			while (tempContainer.numChildren)
			{
				tempContainer.removeChildAt(0);
			}
			tempContainer = null;
			bgSpr.addChild(bitmap);
			bgLdr = null;
		}
	}

}
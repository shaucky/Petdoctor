package xiaoChi.Petdoctor {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.StageWebView;
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.display.NativeWindow;
	import flash.events.LocationChangeEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	public class InfoPanel extends Sprite {
		private var html: String;
		private const webView: StageWebView = new StageWebView();
		private var fileStream: FileStream = new FileStream();
		private var file: File = new File();

		public function InfoPanel() {
			file = File.applicationDirectory.resolvePath("resource/About_Petdoctor_2023.html");
			fileStream.addEventListener(PetdoctorEvent.COMPLETE, fileOpened);
			fileStream.openAsync(file, FileMode.READ);
			this.closeButton.addEventListener(MouseEvent.CLICK, close);
		}
		private function fileOpened(e: Event) {
			fileStream.removeEventListener(PetdoctorEvent.COMPLETE, fileOpened);
			html = fileStream.readMultiByte(fileStream.bytesAvailable, "utf-8");
			fileStream.close();
			file = null;
			fileStream = null;
			webView.loadString(html);
		}
		internal function open() {
			visible = true;
			show();
		}
		internal function close(e: MouseEvent): void {
			this.visible = false;
			hide();
		}
		private function show() {
			var scale: Number = 0;
			var spacing: Number = 0;
			webView.stage = stage;
			if (NativeWindow.isSupported) { //桌面版
				stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, stageResize);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, whenLocationChanging);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, whenLocationChange);
				stageResize(new NativeWindowBoundsEvent("resize"));
			} else { //移动版
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, whenLocationChanging);
				webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, whenLocationChange);
				if (stage.stageWidth / stage.stageHeight > 960 / 560) {
					scale = stage.stageHeight / 560;
					spacing = (stage.stageWidth - scale * 960) / 2;
					webView.viewPort = new Rectangle(210 * scale + spacing, 180 * scale, 536 * scale, 228 * scale);
				} else if (stage.stageWidth / stage.stageHeight <= 960 / 560) {
					scale = stage.stageWidth / 960;
					spacing = (stage.stageHeight - scale * 560) / 2;
					webView.viewPort = new Rectangle(210 * scale, 180 * scale + spacing, 536 * scale, 228 * scale);
				}
			}
		}
		private function hide() {
			stage.nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, stageResize);
			webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, whenLocationChanging);
			webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, whenLocationChange);
			webView.stage = null;
		}
		private function stageResize(e: NativeWindowBoundsEvent) {
			var scale: Number = 0;
			var spacing: Number = 0;
			if (stage.stageWidth / stage.stageHeight > 960 / 560) {
				scale = stage.stageHeight / 560;
				spacing = (stage.stageWidth - scale * 960) / 2;
				webView.viewPort = new Rectangle(210 * scale + spacing, 180 * scale, 536 * scale, 228 * scale);
			} else if (stage.stageWidth / stage.stageHeight <= 960 / 560) {
				scale = stage.stageWidth / 960;
				spacing = (stage.stageHeight - scale * 560) / 2;
				webView.viewPort = new Rectangle(210 * scale, 180 * scale + spacing, 536 * scale, 228 * scale);
			}
		}
		private function whenLocationChange(e: LocationChangeEvent) {
			if (html) {
				webView.loadString(html);
			}
		}
		private function whenLocationChanging(e: LocationChangeEvent) {
			e.preventDefault();
			trace(e.location);
			if (e.location == AppURL.CHECK_VERSION) {
				trace("开始检查版本…");
			} else {
				navigateToURL(new URLRequest(e.location));
			}
		}
	}

}
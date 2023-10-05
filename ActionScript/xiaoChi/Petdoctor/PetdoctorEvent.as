package xiaoChi.Petdoctor
{
	import flash.events.Event;

	public class PetdoctorEvent extends Event
	{
		public static const COMPLETE: String = "complete";
		public static const ENTER_FRAME: String = "enterFrame";
		public static const EXIT_FRAME: String = "exitFrame";
		public static const IO_ERROR: String = "ioError";
		public static const SET: String = "set";

		public function PetdoctorEvent(type: String, bubbles: Boolean = false, cancelable: Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}

}
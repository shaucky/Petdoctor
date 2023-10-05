package
{
	public function output(...arguments)
	{
		Main.outputField.appendText(arguments.toString() + "\n");
		Main.outputField.scrollV = Main.outputField.numLines;
		trace(arguments);
	}
}
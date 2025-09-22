package;

import sys.thread.Thread;
import lime.app.Application;
import lime.ui.WindowAttributes;
import lime.ui.Window;
import snake.http.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.server.*;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;
import Date;


// --- State Machine Enum ---
enum AppState {
	MainMenu(selected:Int);
	FileList(selected:Int, files:Array<String>);
	ViewLyrics(file:String, page:Int);
}

class Main extends Application
{
	private static final DEFAULT_PROTOCOL = "HTTP/1.0";
	private static final DEFAULT_ADDRESS = "127.0.0.1";
	private static final DEFAULT_PORT = 8000;
	private var httpServer:FootNoteHTTPServer;

	public static var state:AppState = AppState.MainMenu(0);

	public function new()
	{
		super();

		var address:String = DEFAULT_ADDRESS;
		var port:Int = DEFAULT_PORT;
		var directory:String = null;
		var protocol:String = DEFAULT_PROTOCOL;
		var corsEnabled:Bool = false;
		var cacheEnabled:Bool = true;
		//var argHandler:ArgHandler = null;
		var silent:Bool = false;
		var openBrowser:Bool = false;

		BaseHTTPRequestHandler.protocolVersion = protocol;
		FootNoteHTTPRequestHandler.corsEnabled = corsEnabled;
		FootNoteHTTPRequestHandler.cacheEnabled = cacheEnabled;
		FootNoteHTTPRequestHandler.silent = silent;
		httpServer = new FootNoteHTTPServer(new Host(address), port, FootNoteHTTPRequestHandler, true, directory);
		httpServer.threading = protocol >= "HTTP/1.1";

		FootNoteHTTPRequestHandler.onStateChange = function() {
			//if we wanted to send out realtime updates via WebSocket here's where it would happen
		};

		if (openBrowser) {
			var url = 'http://${address}:${port}';
			switch (Sys.systemName()) {
				case "Windows":
					Sys.command("start", ["", url]);
				case "Mac":
					Sys.command("/usr/bin/open", [url]);
				case "Linux":
					Sys.command("/usr/bin/xdg-open", [url]);
				default:
					Sys.println('Failed to open web browser. Unknown system: "${Sys.systemName()}"');
			}
		}	

		// Thread.create(() -> {
		// 	httpServer.serveForever(0.1);
		// });
	}

	public static function main() {
		var app:Main = new Main();
		app.exec();
	}

	public override function update(deltaTime:Int):Void
	{
		httpServer.serve(0);
	}

	public override function onGamepadConnect(gamepad:Gamepad):Void
	{
		trace("Gamepad connected: " + gamepad.id);
	}

	public override function onGamepadButtonDown(gamepad:Gamepad, button:GamepadButton):Void
	{
		switch(button) {
			case GamepadButton.BACK:
				Sys.exit(0);
			case GamepadButton.DPAD_DOWN:
				// Example: Cycle through states for demonstration
				state = switch(state) {
					case MainMenu(selected): 
						AppState.MainMenu((selected + 1) % 2); // Assume 2 menu items
					case FileList(selected, files):
						if (files.length > 0) AppState.FileList((selected + 1) % files.length, files) else AppState.MainMenu(0);
					case ViewLyrics(file, page): AppState.MainMenu(0);
						AppState.ViewLyrics(file, (page + 1) % Std.int(Math.max(1, FootNoteHTTPRequestHandler.getPageCount(file))));
				};
			case GamepadButton.A:

				// Example: Cycle through states for demonstration
				state = switch(state) {
					case MainMenu(selected): 
						if (selected == 0) {
							var files = FootNoteHTTPRequestHandler.getLyricFiles();
							if (files.length > 0) AppState.FileList(0, files) else AppState.MainMenu(0);
						} else {
							// Handle "Copy Files From USB" action
							// For now, just stay in the main menu
							AppState.MainMenu(selected);
						}	
					case FileList(_, files): if (files.length > 0) AppState.ViewLyrics(files[0], 0) else AppState.MainMenu(0);
					case ViewLyrics(_, _): AppState.MainMenu(0);
				};
				//FootNoteHTTPRequestHandler.broadcastState();
			default:
				// Handle other buttons if needed
		}
		trace("Gamepad button down: " + button);
	}

	override public function createWindow(attributes:WindowAttributes): Window {
		trace("Hello Headless World");
		return null;
	}
}





package;

import lime.app.Application;
import lime.ui.WindowAttributes;
import lime.ui.Window;
import snake.http.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.server.*;
import FootNoteHxWebSocketServer;

class Main extends Application
{
	private static final DEFAULT_PROTOCOL = "HTTP/1.0";
	private static final DEFAULT_ADDRESS = "127.0.0.1";
	private static final DEFAULT_PORT = 8000;

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
		var httpServer = new FootNoteHTTPServer(new Host(address), port, FootNoteHTTPRequestHandler, true, directory);
		httpServer.threading = protocol >= "HTTP/1.1";

		// Start WebSocket server on port 8001
		var wsServer = new FootNoteHxWebSocketServer(8001);

		FootNoteHTTPRequestHandler.onStateChange = function() {
			wsServer.broadcastState();
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

		httpServer.serveForever();
	}

	public static function main() {
		var app:Main = new Main();
	}

	override public function createWindow(attributes:WindowAttributes): Window {
		trace("Hello Headless World");
		return null;
	}
}





package;

import lime.app.Application;
import lime.ui.WindowAttributes;
import lime.ui.Window;
import snake.http.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.server.*;

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
		// HTTP/1.1 basically requires threads due to keeping the connection
		// open after response, so we have no choice but to enable threading.
		// ideally, it would be threaded for HTTP/1.0 too, but for reasons that
		// are currently unclear, socket errors are causing crashes when
		// threaded. better to prefer stability until it can be resolved.
		httpServer.threading = protocol >= "HTTP/1.1";

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





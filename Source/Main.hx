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
		RunHTTPRequestHandler.corsEnabled = corsEnabled;
		RunHTTPRequestHandler.cacheEnabled = cacheEnabled;
		RunHTTPRequestHandler.silent = silent;
		var httpServer = new RunHTTPServer(new Host(address), port, RunHTTPRequestHandler, true, directory);
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

private class RunHTTPRequestHandler extends SimpleHTTPRequestHandler {
	public static var corsEnabled = false;
	public static var cacheEnabled = true;
	public static var silent = false;

	override private function setup():Void {
		super.setup();
		serverVersion = 'SnakeServer/1.2.0';
	}

	override public function endHeaders() {
		if (corsEnabled) {
			sendHeader('Access-Control-Allow-Origin', '*');
		}
		if (!cacheEnabled) {
			sendHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
		}
		super.endHeaders();
	}

	override private function logRequest(?code:Any, ?size:Any):Void {
		if (silent) {
			return;
		}
		super.logRequest(code, size);
	}
}

private class RunHTTPServer extends HTTPServer {
	private var directory:String;

	public function new(serverHost:Host, serverPort:Int, requestHandlerClass:Class<BaseRequestHandler>, bindAndActivate:Bool = true, ?directory:String) {
		this.directory = directory;
		super(serverHost, serverPort, requestHandlerClass, bindAndActivate);
		Sys.print('Serving HTTP on ${serverAddress.host} port ${serverAddress.port} (http://${serverAddress.host}:${serverAddress.port})\n');
	}

	override private function finishRequest(request:Socket, clientAddress:{host:Host, port:Int}):Void {
		Type.createInstance(requestHandlerClass, [request, clientAddress, this, directory]);
	}
}



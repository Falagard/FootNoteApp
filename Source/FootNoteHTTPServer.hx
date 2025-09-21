package;

import snake.server.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.http.*;

class FootNoteHTTPServer extends HTTPServer {
	private var directory:String;
	private static var instance:FootNoteHTTPServer = null;

	public function new(serverHost:Host, serverPort:Int, requestHandlerClass:Class<BaseRequestHandler>, bindAndActivate:Bool = true, ?directory:String) {
		this.directory = directory;
		super(serverHost, serverPort, requestHandlerClass, bindAndActivate);
		Sys.print('Serving HTTP on ${serverAddress.host} port ${serverAddress.port} (http://${serverAddress.host}:${serverAddress.port})\n');
		FootNoteHTTPServer.instance = this;
	}

	public static function getInstance():FootNoteHTTPServer {
		return instance;
	}

	override private function finishRequest(request:Socket, clientAddress:{host:Host, port:Int}):Void {
		Type.createInstance(requestHandlerClass, [request, clientAddress, this, directory]);
	}
}
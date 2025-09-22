package;

import snake.server.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.http.*;

class FootNoteHTTPServer extends HTTPServer {
	
	private var directory:String;
	private static var instance:FootNoteHTTPServer = null; //singleton 

	public function new(serverHost:Host, serverPort:Int, requestHandlerClass:Class<BaseRequestHandler>, bindAndActivate:Bool = true, ?directory:String) {
		this.directory = directory;
		super(serverHost, serverPort, requestHandlerClass, bindAndActivate);
		Sys.print('Serving HTTP on ${serverAddress.host} port ${serverAddress.port} (http://${serverAddress.host}:${serverAddress.port})\n');
		FootNoteHTTPServer.instance = this;
	}

	override function serviceActions() {
		super.serviceActions();
		
		//if we wanted to update a WebSocket server each tick, this is where it would happen
	}

    //singleton 
	public static function getInstance():FootNoteHTTPServer {
		return instance;
	}

	override private function finishRequest(request:Socket, clientAddress:{host:Host, port:Int}):Void {
		Type.createInstance(requestHandlerClass, [request, clientAddress, this, directory]);
	}

	public function serve(pollInterval:Float = 0.5):Void {
		__isShutDown.acquire();
		try {
			if (!__shutdownRequest) {
				var ready = Socket.select([socket], null, null, pollInterval);
				if (__shutdownRequest) {
					// bpo-35017: shutdown() called during select(), exit immediately.
				}
				if (ready.read.length == 1) {
					handleRequestNoBlock();
				}
				serviceActions();
			}
		} catch (e:Dynamic) {
			__isShutDown.release();
			throw e;
		}
		__isShutDown.release();
	}
}
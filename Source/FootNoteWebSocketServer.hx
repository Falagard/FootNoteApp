package;

import haxe.net.WebSocketServer;
import haxe.net.WebSocket;
import sys.net.Host;
import FootNoteHTTPRequestHandler;

class FootNoteWebSocketServer {
    public var wss:WebSocketServer;
    public var clients:Array<WebSocket> = [];

    public function new(port:Int) {

        var port = 8000;
		var server = WebSocketServer.create('0.0.0.0', port, 1, true, true);
		var handlers = [];

		trace('listening on port $port');

		while (true) {
			try{
			
				var websocket = server.accept();
				if (websocket != null) {
					handlers.push(new FootNoteWebSocketHandler(websocket));
				}
				
				var toRemove = [];
				for (handler in handlers) {
					if (!handler.update()) {
						toRemove.push(handler);
					}
				}
				
				while (toRemove.length > 0)
					handlers.remove(toRemove.pop());
					
				Sys.sleep(0.1);
			}
			catch (e:Dynamic) {
				trace('Error', e);
				//trace(CallStack.exceptionStack());
			}
		}
    }

    public function broadcastState() {
        var state = FootNoteHTTPRequestHandler.getState();
        var json = haxe.Json.stringify(state);
        for (client in clients) {
            client.sendString(json);
        }
    }
}

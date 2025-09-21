package;

import haxe.net.WebSocketServer;
import haxe.net.WebSocket;
import sys.net.Host;
import FootNoteHTTPRequestHandler;

class FootNoteWebSocketServer {
    public static var wsServer:FootNoteWebSocketServer = null;
    public var wss:WebSocketServer;
    public var clients:Array<WebSocket> = [];
    var handlers = [];
    var server:WebSocketServer;
    var port = 8000;

    public function new(port:Int) {
        this.port = port;
        server = WebSocketServer.create('0.0.0.0', port, 1, false, true);
        FootNoteWebSocketServer.wsServer = this;
        trace('listening on port $port');
    }

    public function update() {
        
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
    }   

    public function broadcastState() {
        var state = FootNoteHTTPRequestHandler.getState();
        var json = haxe.Json.stringify(state);
        for (handler in handlers) {
            handler.sendString(json);
        }
    }
}

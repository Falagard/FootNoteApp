package;

import haxe.net.WebSocket;
import hx.ws.Log;
import hx.ws.WebSocketServer;
import sys.net.Host;
import FootNoteHTTPRequestHandler;

class FootNoteWebSocketServer {
    public static var wsServer:FootNoteWebSocketServer = null;
    var port = 8000;

    var server:WebSocketServer<FootNoteWebSocketHandler>;

    public function new(port:Int) {
        this.port = port;
        server = new WebSocketServer<FootNoteWebSocketHandler>("localhost", 5000, 10);
        server.start();

        FootNoteWebSocketServer.wsServer = this;
    }

    public function update() {
        
    }

    public function broadcastState() {
        var state = FootNoteHTTPRequestHandler.getState();
        var json = haxe.Json.stringify(state);
        // for (handler in handlers) {
        //     handler.sendString(json);
        // }
    }
}

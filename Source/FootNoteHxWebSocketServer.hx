package;

import hx.ws.WebSocketServer;
import hx.ws.WebSocketHandler;
import hx.ws.SocketImpl;
import haxe.Json;
import FootNoteHTTPRequestHandler;

class FootNoteHxWebSocketServer {
    public var server:WebSocketServer<FootNoteWsHandler>;
    public static var handlers:Array<FootNoteWsHandler> = [];

    public function new(port:Int) {
        server = new WebSocketServer<FootNoteWsHandler>("0.0.0.0", port, 100);
        server.start();
    }

    public function broadcastState() {
        var state = FootNoteHTTPRequestHandler.getState();
        var json = Json.stringify(state);
        for (handler in handlers) {
            handler.send(json);
        }
    }
}

class FootNoteWsHandler extends WebSocketHandler {
    public function new(s:SocketImpl) {
        super(s);
        onopen = function() {
            trace(id + ". OPEN");
        };
        onclose = function() {
            trace(id + ". CLOSE");
            FootNoteHxWebSocketServer.handlers.remove(this);
        };
        onmessage = function(message) {
            switch (message) {
                case BytesMessage(content):
                    var str = "echo: " + content.readAllAvailableBytes();
                    trace(str);
                    send(str);
                case StrMessage(content):
                    var str = "echo: " + content;
                    trace(str);
                    send(str);
            }
        };
        onerror = function(error) {
            trace(id + ". ERROR: " + error);
        };
    }
}

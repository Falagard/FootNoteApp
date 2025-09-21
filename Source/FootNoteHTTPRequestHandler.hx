package;

import snake.server.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.http.*;

class FootNoteHTTPRequestHandler extends SimpleHTTPRequestHandler {
	public static var corsEnabled = false;
	public static var cacheEnabled = true;
	public static var silent = false;

	override private function setup():Void {
        super.setup();
        
		serverVersion = 'FootNote/0.0.1';

        commandHandlers.set("POST", do_POST);
	}

    override private function do_GET():Void {
		
	}

    override private function do_HEAD():Void {
		
	}

    private function do_POST():Void {
		
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
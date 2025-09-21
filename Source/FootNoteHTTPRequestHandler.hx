package;

import snake.server.*;
import snake.socket.*;
import sys.net.Host;
import sys.net.Socket;
import snake.http.*;

	// --- State Machine Enum ---
// --- State Machine Enum ---
enum AppState {
	MainMenu(selected:Int);
	FileList(selected:Int, files:Array<String>);
	ViewLyrics(file:String, page:Int);
}

class FootNoteHTTPRequestHandler extends SimpleHTTPRequestHandler {

	public static var corsEnabled = false;
	public static var cacheEnabled = true;
	public static var silent = false;

	// --- Application State Machine ---
	public static var lyricFiles:Array<String> = getLyricFiles();
	public static var lyricsPerPage:Int = 10;


	public static var state:AppState = AppState.MainMenu(0);

	public static function getLyricFiles():Array<String> {
		// TODO: Replace with actual file listing logic
		// For now, return a static list for demonstration
		return ["song1.txt", "song2.txt", "song3.txt"];
	}

	public static function getLyrics(file:String):Array<String> {
		// TODO: Replace with actual file reading logic
		// For now, return dummy lines
		var lines = [];
		for (i in 0...35) lines.push('Line ' + (i+1));
		return lines;
	}

	public static function getPageCount(file:String):Int {
		var lines = getLyrics(file);
		return Std.int(Math.ceil(lines.length / lyricsPerPage));
	}

	public static function getPage(file:String, page:Int):Array<String> {
		var lines = getLyrics(file);
		var start = page * lyricsPerPage;
		var end = start + lyricsPerPage;
		return lines.slice(start, end);
	}

	public static function toJsonState():Dynamic {
		return switch (state) {
			case AppState.MainMenu(selected): {
				type: "MainMenu",
				selected: selected
			};
			case AppState.FileList(selected, files): {
				type: "FileList",
				selected: selected,
				files: files
			};
			case AppState.ViewLyrics(file, page): {
				type: "ViewLyrics",
				file: file,
				page: page,
				pageCount: getPageCount(file),
				lines: getPage(file, page)
			};
		}
	}

	// --- REST API Setup ---
	override private function setup():Void {
		super.setup();
		serverVersion = 'FootNote/0.0.1';
		commandHandlers.set("POST", do_POST);
	}

	override private function do_GET():Void {
		var url = this.path;
		if (url == "/api/state") {
			sendJson(snake.http.HTTPStatus.OK, toJsonState());
			return;
		} else if (url == "/api/files") {
			sendJson(snake.http.HTTPStatus.OK, { files: lyricFiles });
			return;
		}
		// Not found
		sendJson(snake.http.HTTPStatus.NOT_FOUND, { error: "Not found" });
	}

	override private function do_HEAD():Void {
		// For simplicity, just call do_GET (no body)
		do_GET();
	}

	private function do_POST():Void {
		var url = this.path;
		if (StringTools.startsWith(url, "/api/select/")) {
			var idxStr = url.substr("/api/select/".length);
			var idx = Std.parseInt(idxStr);
			if (idx != null && idx >= 0 && idx < lyricFiles.length) {
				var file = lyricFiles[idx];
				state = AppState.ViewLyrics(file, 0);
				broadcastState();
				sendJson(snake.http.HTTPStatus.OK, toJsonState());
			} else {
				sendJson(snake.http.HTTPStatus.BAD_REQUEST, { error: "Invalid index" });
			}
			return;
		} else if (url == "/api/page/next") {
			switch (state) {
				case AppState.ViewLyrics(file, page):
					var pageCount = getPageCount(file);
					if (page < pageCount - 1) {
						state = AppState.ViewLyrics(file, page + 1);
						broadcastState();
					}
					sendJson(snake.http.HTTPStatus.OK, toJsonState());
				default:
					sendJson(snake.http.HTTPStatus.BAD_REQUEST, { error: "Not viewing lyrics" });
			}
			return;
		} else if (url == "/api/page/prev") {
			switch (state) {
				case AppState.ViewLyrics(file, page):
					if (page > 0) {
						state = AppState.ViewLyrics(file, page - 1);
						broadcastState();
					}
					sendJson(snake.http.HTTPStatus.OK, toJsonState());
				default:
					sendJson(snake.http.HTTPStatus.BAD_REQUEST, { error: "Not viewing lyrics" });
			}
			return;
		} else if (url == "/api/menu") {
			state = AppState.MainMenu(0);
			broadcastState();
			sendJson(snake.http.HTTPStatus.OK, toJsonState());
			return;
		}
		sendJson(snake.http.HTTPStatus.NOT_FOUND, { error: "Not found" });
	}

	// --- Utility: Send JSON ---
	private function sendJson(code:snake.http.HTTPStatus, obj:Dynamic) {
		var json = haxe.format.JsonPrinter.print(obj);

        sendResponse(code);
        sendHeader('Content-Type', 'application/json');
        endHeaders();

		wfile.writeString(json);
	}

	// --- WebSocket Broadcast (to be called from main server) ---
	public static var onStateChange:Void->Void = function() {};
	public static function broadcastState() {
		onStateChange(); // This will be set up in the main server file to broadcast via WebSocket
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
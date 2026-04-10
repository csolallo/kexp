import 'dart:js_interop';

@JS()
extension type ElectronAPI(JSObject _) implements JSObject {
    external void setCounter(int counter);
}

@JS('electronAPI')
external ElectronAPI? get electronAPI;

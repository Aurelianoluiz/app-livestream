class ObsAdapter {
  bool connected=false;
  Future<void> connect({String host='localhost', int port=4455, String? password}) async { connected=false; }
  Future<void> disconnect() async { connected=false; }
}

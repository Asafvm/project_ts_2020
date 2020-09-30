enum MessegeType { info, warning, error }

class Applogger {
  static final Applogger _instance = Applogger._internal();
  factory Applogger() {
    return _instance;
  }
  Applogger._internal();

  static void consoleLog(MessegeType mType, String msg) {
    String type = "";
    switch (mType) {
      case MessegeType.info:
        type = "Info";
        break;
      case MessegeType.warning:
        type = "Warning";
        break;
      case MessegeType.error:
        type = "Error";
        break;
      default:
        type = "Applogger:";
        break;
    }

    print("Log $type: $msg");
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasInternetConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
}

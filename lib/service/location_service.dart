//import 'package:geolocator/geolocator.dart';
//
//class LocationService {
//  static Future<Position> getLocation() async {
//    final bool locationActivated =
//        await Geolocator().isLocationServiceEnabled();
//    if (!locationActivated) {
//      throw Exception(
//          "location_not_enabled"); //TODO let user choose location when no GPS active or no permission
//    }
//    final Position position = await Geolocator()
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest)
//        .then((Position position) {
//      return position;
//    });
//
//    return position;
//  }
//}

import 'package:google_maps_webservice/places.dart';
import 'package:finder/config/Config.dart';
import 'package:finder/model/TouristLocationsData.dart';
import 'package:finder/model/MyLocationData.dart';

class TouristLocationApi {
  static TouristLocationApi _instance;
  static TouristLocationApi getInstance() => _instance ??= TouristLocationApi();

  Future<TouristLocationsData> getCoffeeShops(MyLocationData location) async {
    final googlePlaces =
        GoogleMapsPlaces(apiKey: 'AIzaSyBIY-rHvMmLObBw_cjs5bVxRU_1bn9Z0HA');
    final response = await googlePlaces.searchNearbyWithRadius(
        Location(location.lat, location.lon), 20000,
        type: 'tourist_attraction', keyword: 'tourist');
    return TouristLocationsData.convertToShops(response.results);
  }
}

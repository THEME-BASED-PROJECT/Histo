import 'package:google_maps_webservice/places.dart';

class TouristLocationsData {

  List<LocationSpot> shopList;

  TouristLocationsData(this.shopList);

  static convertToShops(List<PlacesSearchResult> googlePlaces) {

    List<LocationSpot> shops = [];

    googlePlaces.forEach((shop) {
      if(shop.photos != null)
        shops.add(LocationSpot.shopDetails(shop));
    });
    return TouristLocationsData(shops);
  }
}

class LocationSpot {

  final String id;
  final String name;
  final double lat;
  final double lon;
  final String photoRef;

  LocationSpot(this.id, this.name, this.lat, this.lon, this.photoRef);

  static shopDetails(PlacesSearchResult places) {
    String id = places.id;
    String name = places.name;
    double lat = places.geometry.location.lat;
    double lon = places.geometry.location.lng;
    String photoRef = places.photos[0].photoReference;

    return LocationSpot(id, name, lat, lon, photoRef);
  }
}


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:finder/api/MyLocationApi.dart';
import 'package:finder/model/MyLocationData.dart';
import 'package:finder/model/TouristLocationsData.dart';
import 'package:finder/api/TouristLocationApi.dart';
import 'package:finder/locationCard.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController mapController;
  MyLocationData _myLocationData;
  TouristLocationsData _locations;
  Marker _selectedMarker;
  String _locationName;
  String _locationImage;

  void _updateSelectedMarker(MarkerOptions changes) {
    mapController.updateMarker(_selectedMarker, changes);
  }

  void _onMarkerTapped(Marker marker) {
    if (_selectedMarker != null) {
      _updateSelectedMarker(MarkerOptions(
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
    setState(() {
      _selectedMarker = marker;
    });
    var selectedShop = _locations.shopList.singleWhere(
        (shop) => shop.name == marker.options.infoWindowText.title,
        orElse: () => null);
    _locationName = selectedShop.name;
    _locationImage = selectedShop.photoRef;
    _updateSelectedMarker(MarkerOptions(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindowText: InfoWindowText(_locationName, ''),
    ));
  }

  _addMarkers(TouristLocationsData places) {
    places.shopList.forEach((shop) {
      mapController.addMarker(
        MarkerOptions(
          position: LatLng(shop.lat, shop.lon),
          infoWindowText: InfoWindowText(shop.name, ''),
        ),
      );
    });
  }

  Future<TouristLocationsData> _getCoffeeShops() async {
    final shopsApi = TouristLocationApi.getInstance();
    return await shopsApi.getCoffeeShops(this._myLocationData);
  }

  Future<MyLocationData> _getLocation() async {
    final locationApi = MyLocationApi.getInstance();
    return await locationApi.getLocation();
  }

  @override
  void initState() {
    super.initState();

    _getLocation().then((location) {
      setState(() {
        _myLocationData = location;
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    _locations = await _getCoffeeShops();
    setState(() {
      mapController = controller;
      _addMarkers(_locations);
      mapController.onMarkerTapped.add(_onMarkerTapped);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Histo"),
      ),
      body: Stack(
        children: <Widget>[
          new Center(
            child: _myLocationData != null
                ? SizedBox(
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      options: GoogleMapOptions(
                        cameraPosition: CameraPosition(
                          target: LatLng(
                            _myLocationData.lat,
                            _myLocationData.lon,
                          ),
                          zoom: 14.0,
                        ),
                      ),
                    ),
                  )
                : CircularProgressIndicator(
                    strokeWidth: 4.0,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
          ),
          Align(
            child: _selectedMarker != null
                ? LocationCard(
                    locationsImage: _locationImage,
                    locationsName: _locationName,
                  )
                : Container(),
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}

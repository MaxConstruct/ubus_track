class CarPosition {
  final double lat;
  final double lon;
  final double heading;
  final String label;

  CarPosition({this.lat=13.0, this.lon=100.0, this.heading = 0, this.label="Unknown"});

  @override
  String toString() {
    return 'Lat:$lat Lon:$lon Label:$label';
  }

}
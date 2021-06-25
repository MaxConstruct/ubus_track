class StationPosition {

  final String name;
  final double lat;
  final double lon;
  final String desc;
  final double radius;
  final int order;

  StationPosition({this.name, this.lat=13.0, this.lon=100.0, this.desc, this.order, this.radius});

  // CarPosition({this.lat=13.0, this.lon=100.0, this.heading = 0, this.label="Unknown"});

  @override
  String toString() {
    return 'Lat:$lat Lon:$lon Label:$name';
  }

}
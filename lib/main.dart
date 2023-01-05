import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _selectedDate = '';
  String startDate = '';
  String endDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  List<df> planets = [];
  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyAS-2yUzgcjC48OhRWL6iACbt_12pIQB8k";

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  LatLng startLocation = LatLng(6.789278, 79.998678);
  LatLng endLocation = LatLng(6.789278, 79.998678);
  var dio = Dio();
  late StreamSubscription periodicSub;
 // String planets="";
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
        // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
        startDate='${DateFormat('yyyy-MM-dd').format(args.value.startDate)}';
        endDate=' ${DateFormat('yyyy-MM-dd').format(args.value.endDate ?? args.value.startDate)}';

      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }
  @override
  void initState() {
    periodicSub = new Stream.periodic(const Duration(milliseconds: 1000))
        .take(999999999999999999)
        .listen((_) => gett());
    // markers.add(Marker( //add start location marker
    //   markerId: MarkerId(startLocation.toString()),
    //   position: startLocation, //position of marker
    //   infoWindow: InfoWindow( //popup info
    //     title: 'Starting Point ',
    //     snippet: 'Start Marker',
    //   ),
    //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    // ));

    // markers.add(Marker( //add distination location marker
    //   markerId: MarkerId(endLocation.toString()),
    //   position: endLocation, //position of marker
    //   infoWindow: InfoWindow( //popup info
    //     title: 'Destination Point ',
    //     snippet: 'Destination Marker',
    //   ),
    //   icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    // ));

    getDirections(); //fetch direction polylines from Google API

    super.initState();
  }
  List<df> PlanetFromJson1(String str) =>
      List<df>.from(json.decode(str).map((x) => df.fromJson(x)));
  Future<List<df>> getloc(String? uid, String? mid) async {
    //List<userdet> itemsList = null as List<userdet>;
    try{
    var url = Uri.parse('https://www.tunelk.com/mobile/getrel2.php');
    var formData = FormData.fromMap({'uid': uid, 'mid': mid});
    Response response = await dio.post(url.toString(), data: formData);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');
    if (response.statusCode.toString() == '200') {

      var  rt=PlanetFromJson1(response.data);
      return rt;
    } else {
      var  rt=PlanetFromJson1(response.data);
      return rt;
    }
  }
  catch (e) {
    var  rt=PlanetFromJson1("[{\"id\":\"24440\",\"msg\":\"6.789362:79.998725\",\"rdate\":\"2022-05-08 11:09:46\"}]");
    return rt;
  }
  }
  Future<List<df>> getreal() async {
    //List<userdet> itemsList = null as List<userdet>;
    try{
      var url = Uri.parse('https://www.tunelk.com/mobile/getreal.php');
      var formData = FormData.fromMap({});
      Response response = await dio.post(url.toString(), data: formData);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');
      if (response.statusCode.toString() == '200') {

        var  rt=PlanetFromJson1(response.data);
        return rt;
      } else {
        var  rt=PlanetFromJson1(response.data);
        return rt;
      }
    }
    catch (e) {
      var  rt=PlanetFromJson1("[{\"id\":\"24440\",\"msg\":\"6.789362:79.998725\",\"rdate\":\"2022-05-08 11:09:46\"}]");
      return rt;
    }
  }
  getDirections() async {
    List<LatLng> polylineCoordinates = [];
    List<String> lanlist=[];
    // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    //   googleAPiKey,
    //   PointLatLng(startLocation.latitude, startLocation.longitude),
    //   PointLatLng(endLocation.latitude, endLocation.longitude),
    //   travelMode: TravelMode.driving,
    // );

    if (planets.isNotEmpty) {
      planets.forEach((df point) {
        if(point.msg!=null){
          String rt=point.msg.toString();
           lanlist=rt.split(':');
           double latr=double.parse(lanlist[0]) ;
          double lonr=double.parse(lanlist[1]) ;
          polylineCoordinates.add(LatLng(latr,lonr));
        }


      });
    } else {
      print("");
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  gett(){
    getreal().then((data) {
      setState(() {
        //planets = data;
       // planets=  data;
        if (data.isNotEmpty) {
          data.forEach((df point) {
            if(point.msg!=null){
              String rt=point.msg.toString();
              List<String> lanlist=[];
              lanlist=rt.split(':');
              double latr=double.parse(lanlist[0]) ;
              double lonr=double.parse(lanlist[1]) ;
              startLocation=LatLng(latr,lonr);
              var dateFormat = DateFormat("yyyy-MM-dd hh:mm:ss"); // you can change the format here
              var utcDate = dateFormat.format(DateTime.parse(point.rdate.toString()));

              var localDate = dateFormat.parse(utcDate, true).toLocal().toString();
              String createdDate = dateFormat.format(DateTime.parse(utcDate));
              String utcDate1 =  dateFormat.format( DateTime.parse(utcDate).add(new Duration(minutes: 30)));// pass the UTC time here
              // var newPosition = CameraPosition(
              //     target: LatLng(latr,lonr),
              //     zoom: 16);
              //
              // CameraUpdate update =CameraUpdate.newCameraPosition(newPosition);
              // CameraUpdate zoom = CameraUpdate.zoomTo(16);
              //
              // mapController?.moveCamera(update);

markers.clear();
              markers.add(Marker( //add distination location marker
                markerId: MarkerId(LatLng(latr,lonr).toString()),
                position: LatLng(latr,lonr), //position of marker
                infoWindow: InfoWindow( //popup info
                  title: 'Destination Point ',
                  snippet: utcDate1,
                ),
                icon: BitmapDescriptor.defaultMarker, //Icon for Marker
              ));
            }


          });
        } else {
          print("");
        }



      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Pulsar 135-BEC 4821"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body:
      Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 30,
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Text('Selected date: $_selectedDate'),
                // Text('Selected date count: $_dateCount'),
                Text('Selected range: $_range'),
                //Text('Selected ranges count: $_rangeCount')
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 30,
            right: 0,
            height: 40,

            child:
            ElevatedButton(
              onPressed: () {
    showDialog(
    //barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
           return     AlertDialog(
                    elevation: 24,
                    title: Text('Filter'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))
                    ),
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {


                          return    Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,

                            child:
                            SingleChildScrollView(child:
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                ListTile(
                                  title:
                                  Text('Date',style: TextStyle(color: Colors.blue),),
                                  subtitle: SfDateRangePicker(
                                    onSelectionChanged: _onSelectionChanged,
                                    selectionMode: DateRangePickerSelectionMode.range,
                                    initialSelectedRange: PickerDateRange(
                                        DateTime.now().subtract(const Duration(days: 4)),
                                        DateTime.now().add(const Duration(days: 3))),
                                  ),
                                ),



                              ],
                            ),
                            ),

                          );
                        }),

                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                       child: Text('OK'),
                      ),
                    ]

      );},
    );
              },
              child:Text('Date')





            ),
         ),
          Positioned(
            left: 0,
            right: 0,
            top: 80,
            height: 40,
            child:
            ElevatedButton(
              onPressed: () {
                
                getloc(startDate,endDate).then((data) {
                  setState(() {
                    //planets = data;
                    planets=  data;
                    getDirections();
                  });
                });
                
              },
              child: Text('OK'),
            ),
          ),
          Positioned(
            left: 0,
            top: 120,
            right: 0,
            bottom: 0,
            child:   GoogleMap( //Map widget from google_maps_flutter package
            zoomGesturesEnabled: true, //enable Zoom in, out on map
            initialCameraPosition: CameraPosition( //innital position in map
              target: startLocation, //initial position
              zoom: 16.0, //initial zoom level
            ),
            markers: markers, //markers to show on map
            polylines: Set<Polyline>.of(polylines.values), //polylines
            mapType: MapType.normal, //map type
            onMapCreated: (controller) { //method called when map is created
              setState(() {
                mapController = controller;
              });
            },
          ), ),
        ],
      ),



    );
  }
}
class df {
  String? id;
  String? msg;
  String? rdate;

  df({this.id, this.msg, this.rdate});

  df.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    msg = json['msg'];
    rdate = json['rdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['msg'] = this.msg;
    data['rdate'] = this.rdate;
    return data;
  }
}
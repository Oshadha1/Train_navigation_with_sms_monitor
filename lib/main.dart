import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:smsretrieverptk/smsretrieverptk.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:collection/collection.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: { //Routes for two pages


        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (BuildContext context) => MyHomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/signup': (BuildContext context) => SecondScreen(),
      },
     // home: MyHomePage(title: 'Elephant Tracker'),
    );
  }
}
/////////////////////////////////////////////

////////////////////////////////////////////////

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/////////////////////////////////////////////////////
///////////////////////////////////////
class SecondScreen extends StatefulWidget { //The second screen

  SecondScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SecondScreenState createState() => _SecondScreenState();


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text("ADD Camera Locations"),
  //     ),

  //   );
  // }
}
//

class _SecondScreenState extends State<SecondScreen> {

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(7.2604126,80.5869903),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
        //title: Text(widget.title),
        centerTitle: true,
        title: Text(' Elephant Tracker Add CAM')
    ),

        body: Column(
            children: [
              SizedBox( //Map for the second Screen

                //width: MediaQuery.of(context).size.width,
                //height: MediaQuery.of(context).size.height,
                width: 400, // or use fixed size like 200
                height: 470,
                child: GoogleMap(
                    mapType: MapType.hybrid,
                    zoomGesturesEnabled: true,
                   initialCameraPosition: initialLocation,
                   onMapCreated: (GoogleMapController controller) {
                   _controller = controller;
                 },
                ),
              //
              //
              ),
              Row(
                children: [
                  Container( //TO STORE ADD MARKER BUTTON - ADD


                    // alignment: Alignment.topRight,
                    width: 100, // or use fixed size like 200
                    height: 100,
                    decoration: const BoxDecoration(
                        color: Colors.tealAccent
                    ),


                    child: IconButton(
                      // label: Text(''),
                      icon: Icon(Icons.maps_ugc_outlined),
                      color: Colors.black,
                      onPressed: () {
                        // Navigate to the second screen using a named route.
                        Navigator.pop(context);
                      },
                    ),


                  ),

                  Container( //TO STORE ADD MARKER BUTTON -Remove


                    // alignment: Alignment.topRight,
                    width: 100, // or use fixed size like 200
                    height: 100,
                    decoration: const BoxDecoration(
                        color: Colors.tealAccent
                    ),


                    child: IconButton(
                      // label: Text(''),
                      icon: Icon(Icons.delete),
                      color: Colors.black,
                      onPressed: () {
                        // Navigate to the second screen using a named route.
                        Navigator.pop(context);
                      },
                    ),


                  )

//////////////////////////

                ],
              ),



              SizedBox( //THE BOX USED For Go Back
                width: 400, // or use fixed size like 200
                height: 40,

                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to the first screen by popping the current route
                      // off the stack.
                      Navigator.pop(context);
                    },
                    child: Text('Go back!'),
                  ),

              ),

            ])




    );

  }

}
//////////////////////////////////////////////////

class _MyHomePageState extends State<MyHomePage> {


  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;
  //Cam locations


  //For the sms
  String _smsCode = "";
  String _voltage = "";
  String _cameraID = "";
  String _elephent = "";
  String _dtime = "";
  String _cameralink= "";
  bool isListening = false;
  String eleph ="";
  String cam = "";
  String distance="";
  String dtime="";
  String formattedDate="-";
  double distpercent=0;
  Color progressbar = Colors.green;

  //For the gps
  LatLng camlocation;
  double distanceInMeters;
  //static AudioCache player = AudioCache();
  AudioCache cache = new AudioCache();
  AudioPlayer player;
  //////////
  //Creating the array for gps coordinates
  // ignore: deprecated_member_use
  // var camlist = List.generate(10, (i) => List(2), growable: false);
  // camlist[0][1]="7.257682";
  // 80.590556




  @override
  void initState() {
    super.initState();
    _setPolylines();

    _addcam('2', 7.257682, 80.590556); //ADD CAMERA 1
    _addcam('3', 7.258360, 80.592622); //ADD CAMERA 2
    _addcam('4', 7.258893, 80.594064); //ADD CAMERA 3

  }

  ////////// UPDATES THE APP ON SMS RECEIVE
  void didChangeDependencies()async {
    while(true){
      String smsCode = await SmsRetrieverPtk.startListening();

      _smsCode = getCode(smsCode);

      if (_smsCode != null) {

         _voltage = _smsCode.substring(0, 4);
         _cameraID = _smsCode.substring(4, 7);
         _elephent = _smsCode.substring(7, 8);
         _cameralink= _smsCode.substring(8, 9);

         _voltage =  _voltage.substring(0, 2) +"." +_voltage.substring(2, 4)+"V";

         if(_elephent =='1'){
              eleph="Yes";
         }else{
             eleph="No";
         }

         if(_cameralink =='1'){
           cam="Yes";
         }else{
           cam="No";
         }

      }


      setState(() {

   if( eleph=="Yes") {

     DateTime now = DateTime.now();
     formattedDate = DateFormat('kk:mm:ss').format(now);


     if (_cameraID == '002') {
       camlocation = LatLng(7.257682, 80.590556);
       _onMarkerTapped(MarkerId(_cameraID.substring(2, 3)));


     }
     else if (_cameraID == '003') {
       camlocation = LatLng(7.258360, 80.592622);
       _onMarkerTapped(MarkerId('3'));

     }
     else if (_cameraID == '004') {
       camlocation = LatLng(7.258893, 80.594064);
       _onMarkerTapped(MarkerId('4'));
       //distance ="50m";

     }
   }else{ //Reverts the icon back to camera after elephant clears



     _stopFile(); //STOPS THE PLAYING AUDIO FILE
     _markerset(MarkerId(_cameraID.substring(2, 3)));


     formattedDate ="-"; //Keeping Detect Time N/A
     distance=""; //clears the distance
     //camlocation=LatLng(latitude, longitude);
     distpercent=0;


   }


      });
      SmsRetrieverPtk.stopListening();
    }
  }

  getCode(String sms) {
    if (sms != null) {
      final intRegex = RegExp(r'\d+', multiLine: true);
      final code = intRegex.allMatches(sms).first.group(0);
      return code;
    }
    return "NO SMS";
  }

  /////////
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Set<Polyline> _polylines = <Polyline>{};

  ////////
  MarkerId selectedMarker;
  BitmapDescriptor customIcon;
/////////////////// THIS CHANGE THE COLOR OF THE MARKER///////////
  void _onMarkerTapped(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];

    setState(() {
      if (markers.containsKey(selectedMarker)) {
        final Marker resetOld = markers[selectedMarker]
            .copyWith(iconParam: BitmapDescriptor.fromAsset("assets/car_icon2.png")); //CHANGES TO THE PREVIOUS ICON ONCE ANOTHER ICON IS CLICKED
        markers[selectedMarker] = resetOld;
      }
      selectedMarker = markerId;
      final Marker newMarker = tappedMarker.copyWith(

          iconParam: BitmapDescriptor.fromAsset("assets/elephant.png")); //flips to another icon

      markers[markerId] = newMarker;
      playLocalAsset();
    });

  }
  ////VOID FOR REVERT ICON TO CAMERA
  void _markerset(MarkerId markerId) {
    final Marker tappedMarker = markers[markerId];

    setState(() {

      selectedMarker = markerId;
      final Marker newMarker = tappedMarker.copyWith(

          iconParam: BitmapDescriptor.fromAsset("assets/car_icon2.png")); //flips to another icon

      markers[markerId] = newMarker;
    });

  }
/////////////////////////// Common code for the adding the camera markers
  void _addcam(x,y,z) {

    //String markerIdVal = x;
    MarkerId markerId = MarkerId(x);

    Marker marker = Marker(
        markerId: markerId,
        position: LatLng(y, z),
        onTap: () {
          _onMarkerTapped(markerId); ///ADD THIS TO THE COMPARISON
        },
        icon: BitmapDescriptor.fromAsset("assets/car_icon2.png"));

    setState(() {
      markers[markerId] = marker;

    //  player.play('alarm.mp3'); //Plays the audio file
    });

  }
// AUDIO -START PLAYER

  void playLocalAsset() async {
    //AudioCache cache = new AudioCache();
    player = await cache.loop("alarm.mp3");

  }

//AUDIO- STOP PLAYER
  void _stopFile() {
    player?.stop(); // stop the file like this
  }


////////////  CREATING THE ROUTE
  void _setPolylines() {
    List<LatLng> polylineLatLongs = List<LatLng>();
    // polylineLatLongs.add(LatLng(7.2578496,80.5913433));
    polylineLatLongs.add(LatLng(7.257426, 80.590112));
    polylineLatLongs.add(LatLng(7.257682, 80.590556));
    polylineLatLongs.add(LatLng(7.257815, 80.590895));
    polylineLatLongs.add(LatLng(7.257955, 80.591151));
    polylineLatLongs.add(LatLng(7.258170, 80.591898));
    polylineLatLongs.add(LatLng(7.258216, 80.592257));
    polylineLatLongs.add(LatLng(7.258248, 80.592361));
    polylineLatLongs.add(LatLng(7.258360, 80.592622));
    polylineLatLongs.add(LatLng(7.258520, 80.592932));
    polylineLatLongs.add(LatLng(7.258609, 80.593273));
    polylineLatLongs.add(LatLng(7.258726, 80.593543));
    polylineLatLongs.add(LatLng(7.258893, 80.594064));

    _polylines.add(
      Polyline(
        polylineId: PolylineId("0"),
        points: polylineLatLongs,
        color: Colors.blue,
        width: 4,
      ),
    );
  }

  /////////////////CALCULATE THE DISTANCE TO THE CAMERA



  ////////////////////////////////////////////


  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(7.2604126,80.5869903),
    zoom: 14.4746,
  );


  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }
  /////////////////////////////////////////////////
  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    //latlngglobal =latlng;


    this.setState(() {



      marker = Marker(
          markerId: MarkerId("1"),
          position: latlng,
          rotation: newLocalData.heading+180,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      markers[MarkerId("1")] = marker;
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
//calculating distance
      if( eleph=="Yes"){

            distanceInMeters = Geolocator.distanceBetween(newLocalData.latitude, newLocalData.longitude, camlocation.latitude, camlocation.longitude);
            distanceInMeters= double.parse(distanceInMeters.toStringAsFixed(1));
            distpercent=(2000-distanceInMeters)/2000;
            distanceInMeters<200 ? progressbar=Colors.red : progressbar=Colors.green;  //If else shorthand
            distance= distanceInMeters.toString()+"m";
      }else{

        distance= "";
      }
      ////
    });


  }

  void getCurrentLocation() async {
    try {

      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData); //updated

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }


      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0,
              zoom: 18.00
               )));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }


  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }
///APP LAYOUT////
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        //title: Text(widget.title),
          centerTitle: true,
          title: Text(' Elephant Tracker')


      ),

      body: Column(
            children: [
              //////////TOP LEFT SIDE
              Row(
                children:[ Container(
                  width: 150, // or use fixed size like 200
                  height: 100,
                  //alignment: Alignment.topLeft,
                  //width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                      color: Colors.red
                  ),

                  child:SizedBox(

                    child: FutureBuilder(
                      builder: (context, data) {
                        return Text(
                          'SIGNATURE: ${data.data} \n SMS CODE: $_smsCode',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 15,
                            color: Colors.white,
                            height: 2,
                          ),
                          textAlign: TextAlign.center,
                        );


                      },
                      future: SmsRetrieverPtk.getAppSignature(),
                    ),


                  ),
                ),
          ////////TOP RIGHT SIDE
                  Container(

                   // alignment: Alignment.topRight,
                    width: 201, // or use fixed size like 200
                    height: 100,
                    decoration: const BoxDecoration(
                        color: Colors.green
                    ),

                    child:SizedBox(

                      child: FutureBuilder(
                        builder: (context, data) {
                          return Text(
                            '\n Voltage                : $_voltage \n '
                                'Camera ID           :  $_cameraID\n'
                                ' Camera Link        : $cam\n'
                                ' Elephent Detect  : $eleph \n'

                                ,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 15,
                              color: Colors.white,
                              height: 1,
                            ),
                            textAlign: TextAlign.left,
                          );


                        },
                        future: SmsRetrieverPtk.getAppSignature(),
                      ),



                    ),
                  ),


                  Container( //CONTAINER FOR SCREEN JUMP

                    // alignment: Alignment.topRight,
                    width: 40, // or use fixed size like 200
                    height: 100,
                    decoration: const BoxDecoration(
                        color: Colors.tealAccent
                    ),


                      child: IconButton(
                       // label: Text(''),
                        icon: Icon(Icons.maps_ugc_outlined),
                        color: Colors.black,
                        onPressed: () {
                          // Navigate to the second screen using a named route.
                          Navigator.pushNamed(context, '/signup');
                        },
                      ),
                    ),

                ],

              ),

              SizedBox( //THE BOX USED FOR TIMER
                width: 400, // or use fixed size like 200
                height: 20,

                child: FutureBuilder(
                  builder: (context, data) {
                    return Text(
                      ' Time of Detect  : $formattedDate \n',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        color: Colors.blue,
                        height: 1.3,

                      ),
                      textAlign: TextAlign.center,
                    );

                  },




                ),

              ),
              SizedBox( //THE BOX USED Progress bar
                width: 400,
                height: 60,

                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: new LinearPercentIndicator(
                          width: 200.0,
                          animation: true,
                          animationDuration: 1000,
                          lineHeight: 30.0,
                          leading: new Text("                   "),
                          trailing: new Text("Distance Left"),
                          percent: distpercent,
                          center: Text(distance),
                          linearStrokeCap: LinearStrokeCap.butt,
                          progressColor: progressbar,
                        ),
                      ),


                    ]
                )

              ),
              SizedBox(
                  //width: MediaQuery.of(context).size.width,
                  //height: MediaQuery.of(context).size.height,
                  width: 400, // or use fixed size like 200
                  height: 470,
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: initialLocation,
                    markers: Set<Marker>.of(markers.values),//this calls for a newly mapped variable "Markers"
                    circles: Set.of((circle != null) ? [circle] : []),
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;

                    },
                  ),


              ),


            ]) ,



      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.location_searching),
          onPressed: () {
            getCurrentLocation();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );

  }


}

/////

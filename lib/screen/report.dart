import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
class Report extends StatefulWidget{
  @override
  _ReportState createState() => _ReportState();
}
class _ReportState extends State<Report>{
  bool isLocationLoading=true;
  var pos;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _title= TextEditingController();
  TextEditingController _about=TextEditingController();
  final _formKey= GlobalKey<FormState>();
  var imageurl;
  bool isLoading=true;

  
  bool isHome=true;
  /* Gps of users */
   Future location() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
     _checkGps();
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {  
        return showAlertDialog(context,permission);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
       return showAlertDialog(context,permission);
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      pos = position;
      isLocationLoading=false;
    });
  }

  Future _checkGps() async {
    loc.Location location = loc.Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return SystemNavigator.pop();
      }
    }
  }


@override 
void initState(){
  location();
  super.initState();
}

  @override
  Widget build(BuildContext context){
     return isHome?home():formBox();
  }
Widget formBox(){
   return Scaffold(
      appBar: AppBar(
        elevation:0,
        backgroundColor:Colors.white,
        centerTitle:true,
        title: Text('Reporter',
        style:TextStyle(
          color:Colors.black,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold
        )
        ),
        leading: IconButton(
          onPressed:(){
            setState(() {
              isHome=true;
            });
          },
          icon:Icon(Icons.cancel_outlined,
          color: Colors.black,
          size: 20,
          )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10,40,10,0),
          child: Form(
            key: _formKey,
            child:Column(
              children: [
                TextFormField(
                  validator: (val){
                    if (val!.isEmpty){
                      return 'Empty Field';
                    }
                    return null;
                  },
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                controller: _title,
                decoration: InputDecoration(
                  hintText: 'Title'
                ),
                ),
                SizedBox(
                  height:20
                ),
                TextFormField(
                  validator:(val){
                    if(val!.isEmpty){
                      return 'Empty Field';
                    }
                    return null;
                  } ,
                  maxLines:null,
                  minLines: 6,
                  keyboardType: TextInputType.multiline,
                  controller: _about,
                  decoration: InputDecoration(
                    hintText: 'Report info'
                  ),
                ),
                 
               SizedBox(
                  height:20
                ),
               TextButton(
                 style:ButtonStyle(
                   padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(12)),
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFF73859)) ,
                     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        // side: BorderSide(color: Colors.white),
                      )
                    )
                 ),
                 onPressed: ()  async{
                   if (_formKey.currentState!.validate()){
                     try{
                      await _firestore.collection('Report').doc().set( 
                        {
                        'Title':_title.text,
                        'About':_about.text,
                        'longitude': pos.longitude,
                        'latitude': pos.latitude,
                        },SetOptions(merge: true)
                      ).then((value) => {
                         setState((){
                            isHome=true;
                            isLoading=false;
                         })
                      });
                     } catch(e){
                         print(e);
                     }
                   }
                 }, 
                 child: Text('Report',
                 style: TextStyle(
                   fontFamily: 'Poppins',
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
                 ),
                 )
              ],
            )
            ),
        ),
      ),
   );
}
Widget home(){
 return Scaffold(
        appBar:AppBar(        
           title: Text('Society News',
           style:TextStyle(
             fontFamily:'Poppins',
             color:Colors.white,
            fontWeight:FontWeight.bold,
           ),
          ),
          centerTitle:true,
          elevation:0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed:(){
            setState((){
                isHome=false;
            });
          } ,
          child: Icon(
          Icons.add,
          color: Colors.white,
          ),
          ),
        body:isLocationLoading?Align(
          alignment:Alignment.topCenter,
          child:CircularProgressIndicator(color: Colors.black,)):
          StreamBuilder<QuerySnapshot>(
            stream:_firestore.collection('Report').snapshots(),
            builder:(context, AsyncSnapshot<QuerySnapshot> snap){
              switch(snap.connectionState){
                case ConnectionState.waiting:
                   return Align(
                     alignment:Alignment.topCenter,
                     child:LinearProgressIndicator(),
                   );
              default:
                if (!snap.hasData){
                  return Center(child: Text('An error occured'));
                }
                else {
                  return OrientationBuilder(
                   builder:(context, index){
                     return ListView.builder(
                       itemCount:snap.data!.docs.length,
                       itemBuilder:(context,index){
                         DocumentSnapshot snapshot= snap.data!.docs[index];
                         if (!snapshot.exists){
                          return Text('No data');
                         }
                         double lat=snapshot['latitude'].hashCode.toDouble();
                         double long=snapshot['longitude'].hashCode.toDouble();
                         double distanceInMeters = Geolocator.distanceBetween(lat,long, pos.latitude, pos.longitude); 
                         double miles=distanceInMeters /1609.344;
                         var hasData= snap.data!.docs.length>0;
                        return hasData?Padding(
                             padding:EdgeInsets.fromLTRB(10, 0, 10, 0),
                             child: Card(
                               shape:RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               elevation: 2,
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   Text(
                                     snapshot['Title'],
                                     style: TextStyle(
                                       fontFamily: 'Montserrat',
                                       fontWeight: FontWeight.bold,
                                       fontSize: 16,
                                     ),
                                   ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                       snapshot['About'],
                                       style: TextStyle(
                                         fontFamily: 'Montserrat',
                                        //  fontWeight: FontWeight.bold,
                                         fontSize: 16,
                                       ),
                                       
                                   ),
                                    ),
                                   Divider(
                                     color: Colors.grey
                                   ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.my_location_sharp,
                                      color: Color(0xFFF73859),
                                      size: 13,
                                    ),
                                    Text(
                                      '${miles.round().toString()}miles away',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.grey.withOpacity(0.5)),
                                    ),
                                  ],
                                )],
                               ),
                             ),
                         ):Padding(
                           padding: EdgeInsets.all(20),
                           child:Text('No News yet')
                           
                         );
                       }
                     );
                   }
                  );
                }
              }
            }
          ),
        );
}
showAlertDialog(BuildContext context,permission) {
  // set up the buttons
  // ignore: deprecated_member_use
  Widget cancelButton = FlatButton(
    child: Text("Cancel",
    style:TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
    )
    ),
    onPressed:  () {
        SystemNavigator.pop();
    },
  );
  // ignore: deprecated_member_use
  Widget continueButton = FlatButton(
    child: Text("Continue",
    style:TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
    )
    ),
    onPressed:  () async{
       Navigator.of(context, rootNavigator: true).pop(true);
      await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
         SystemNavigator.pop();
      }
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Warning",
    style:TextStyle(
      fontFamily:'Poppins'
    )
    ),
    content: Text("We require your location to show news close to you. However, you can exit the app if not pleased. ",
    style: TextStyle(
      fontFamily:'Poppins',
      // fontWeight: FontWeight.bold,
      // color: Colors.black,
    ),
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child:alert,
      );
    },
  );
 }
}
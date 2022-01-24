import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' as loc;
import 'package:report/screen/report.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   _checkGps();
   runApp(MyApp()); 
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
 MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value,  swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:ThemeData(
          primarySwatch: createMaterialColor(Color(0xFFF73859))
      ),
      title: 'Society Report',
      debugShowCheckedModeBanner: false,   
      routes: {
         '/': (context) =>Report(),
      }, 
    );
  }
}

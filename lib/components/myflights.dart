import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Flights App',
      home: MyFlights(),
    );
  }
}

class MyFlights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Flights'),
      ),
      body: AeroDataBoxData(),
    );
  }
}

class AeroDataBoxData extends StatefulWidget {
  @override
  _AeroDataBoxDataState createState() => _AeroDataBoxDataState();
}

class _AeroDataBoxDataState extends State<AeroDataBoxData> {
  final String apiKey = 'cf075a1eb1msh613e2d1d02ed1abp1229f3jsn173c3f1f2a3e';
  //arama dinamik olmalı
  final TextEditingController _searchController = TextEditingController();
  final String apiUrl = 'https://aerodatabox.p.rapidapi.com/airports/search/term?q=';
  //searchable list view
  List<dynamic> airlines = [];
  MapController _mapController = MapController();


  @override
  void initState() {
    super.initState();
  }

  //dio ile değiştir
  Future<void> fetchData() async {
    final dio = Dio();  // Create a Dio instance
    final searchQuery = _searchController.text;

    try {
      final Response<String> response  = await dio.get(
        apiUrl + searchQuery,
        options: Options(
          headers: {
            'X-RapidAPI-Key': apiKey,
            'X-RapidAPI-Host': 'aerodatabox.p.rapidapi.com',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('success');
        setState(() {
          Map<String, dynamic> airline = jsonDecode(response.data.toString());
          airlines = airline['items'];
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _filterAirlines(String query) {
    setState(() {
      airlines = airlines.where((airline) {
        return airline['shortName'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              _filterAirlines(value);
            },
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: 'Search for airlines...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Fetch data when the search button is pressed
            fetchData();
          },
          child: Text('Search'),
        ),
        //changed version
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: airlines.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(airlines[index]['shortName']),
                subtitle: Text(airlines[index]['icao']),
                onTap: () {
            
                  setState(() {
                    double lat = airlines[index]['location']['lat'];
                    double long=airlines[index]['location']['lon'];
                     _mapController.move(LatLng(lat, long), 10);

                  });
                  print(airlines[index]['shortName']);
                  
                },
              );
            },
          ),
        ),
        Expanded(
          flex: 4,
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 10,
            ),
            nonRotatedChildren: [
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
             mapController: _mapController,
            children: [
              TileLayer(

                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
 
            ],
            
          ),
        ),
      ],
    );
  }
}

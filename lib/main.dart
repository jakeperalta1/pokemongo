import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Card App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set the SplashScreen as the home
      routes: {
        '/home': (context) => PokemonListScreen(), // Your main app screen
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after a delay of 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/pokemon.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late Future<List<PokemonCard>> futurePokemonCards;
  String? selectedImageUrl;

  @override
  void initState() {
    super.initState();
    futurePokemonCards = fetchPokemonCards();
  }

  void _showImagePopup(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800], // Grey background for the popup
          content: Image.network(imageUrl),
          actions: [
            Container(
              margin: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.grey[600], // Text color of the button
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the popup
                },
                child: Text('Back to List'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark grey background
      appBar: AppBar(title: Text('Pokémon Cards')),
      body: FutureBuilder<List<PokemonCard>>(
        future: futurePokemonCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final card = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    _showImagePopup(card.largeImageUrl);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 100, // Adjust width as needed
                          height: 100, // Adjust height as needed
                          child: Image.network(
                            card.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            card.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Text color for contrast
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Define your PokemonCard and fetchPokemonCards function here
class PokemonCard {
  final String name;
  final String imageUrl;
  final String largeImageUrl;

  PokemonCard({required this.name, required this.imageUrl, required this.largeImageUrl});

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      name: json['name'],
      imageUrl: json['images']['small'],
      largeImageUrl: json['images']['large'],
    );
  }
}

Future<List<PokemonCard>> fetchPokemonCards() async {
  final response = await http.get(Uri.parse('https://api.pokemontcg.io/v2/cards'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body)['data'];
    return jsonData.map((json) => PokemonCard.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load Pokémon cards');
  }
}

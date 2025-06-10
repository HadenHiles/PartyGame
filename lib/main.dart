import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

enum AppMode { join, lobby, master }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fill in the Blanks Party Game',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      home: const ModeSelector(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Party Game Lobby'), backgroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinLobbyScreen())),
              child: const Text('Join Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MasterDeviceScreen())),
              child: const Text('Master Device (TV)'),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinLobbyScreen extends StatefulWidget {
  const JoinLobbyScreen({super.key});
  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lobbyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join black Lobby'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white,),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: _lobbyController,
              decoration: const InputDecoration(labelText: 'Lobby Code'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () {
                if (_nameController.text.isNotEmpty && _lobbyController.text.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LobbyScreen(
                        name: _nameController.text,
                        lobbyCode: _lobbyController.text,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Enter Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}

class LobbyScreen extends StatefulWidget {
  final String name;
  final String lobbyCode;
  const LobbyScreen({super.key, required this.name, required this.lobbyCode});
  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _cardController = TextEditingController();

  late CollectionReference lobbyRef;
  late CollectionReference cardsRef;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lobbyRef = FirebaseFirestore.instance.collection('lobbies');
    cardsRef = lobbyRef.doc(widget.lobbyCode).collection('cards');
    // Create lobby doc if it doesn't exist
    lobbyRef.doc(widget.lobbyCode).set({'created': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  void addCard(String card) {
    cardsRef.add({
      'player': widget.name,
      'card': card,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _cardController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.lobbyCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Welcome, ${widget.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Text('Add a card (single word):', style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cardController,
                    decoration: const InputDecoration(hintText: 'Enter word'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  onPressed: () {
                    if (_cardController.text.isNotEmpty) {
                      addCard(_cardController.text.trim());
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text('All Cards:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('lobbies')
                    .doc(widget.lobbyCode)
                    .collection('cards')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No cards yet.'));
                  }
                  return ListView(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['card'] ?? ''),
                        subtitle: Text(data['player'] ?? ''),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MasterDeviceScreen extends StatelessWidget {
  MasterDeviceScreen({super.key});
  final String lobbyCode = _generateLobbyCode();
  final String joinUrl = "https://yourgame.com/join/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Device'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    lobbyCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lobby Code:', style: Theme.of(context).textTheme.headlineSmall),
            Text(lobbyCode, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            QrImageView(
              data: '$joinUrl$lobbyCode',
              size: 200,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text('Scan to join the game', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

String _generateLobbyCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rand = Random();
  return String.fromCharCodes(Iterable.generate(5, (_) => chars.codeUnitAt(rand.nextInt(chars.length))));
}

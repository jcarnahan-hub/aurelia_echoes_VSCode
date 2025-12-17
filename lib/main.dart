import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database.dart';
import 'import_screen.dart';
import 'library_screen.dart';
import 'series_screen.dart';
import 'wishlist_screen.dart';
import 'search_logic.dart'; // <--- The Search Logic Import

void main() {
  runApp(
    Provider<AppDatabase>(
      create: (context) => AppDatabase(),
      dispose: (context, db) => db.close(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurelia Echoes',
      debugShowCheckedModeBanner: false,
      
      // Forces Dark Mode
      themeMode: ThemeMode.dark, 
      
      // The Dark Theme Definition
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1F1F1F),
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.grey,
        ),
        
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amberAccent,
          surface: Color(0xFF1E1E1E),
        ),
        
        useMaterial3: true,
      ),
      
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    LibraryScreen(),
    WishlistScreen(),
    SeriesScreen(),
    ImportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AURELIA ECHOES'),
        actions: [
          // --- SEARCH BUTTON LOGIC ---
          IconButton(
            icon: const Icon(Icons.search), 
            onPressed: () async {
              // 1. Get the database
              final db = Provider.of<AppDatabase>(context, listen: false);
              
              // 2. Fetch ALL books
              final books = await db.getAllBooks();
              
              // 3. Launch the Search Bar
              if (context.mounted) {
                showSearch(
                  context: context, 
                  delegate: BookSearchDelegate(
                    allBooks: books,
                    onBookUpdate: (book) {}, 
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: const Color(0xFF1A1A1A),
        indicatorColor: Colors.deepPurpleAccent.withOpacity(0.4),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.shelves), 
            label: 'Series',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Manage',
          ),
        ],
      ),
    );
  }
}
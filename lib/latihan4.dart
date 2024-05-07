import 'package:flutter/material.dart'; // Import library Flutter untuk membuat UI
import 'package:http/http.dart' as http; // Import library http untuk mengirim permintaan HTTP
import 'dart:convert'; // Import library untuk mengonversi data JSON
import 'package:provider/provider.dart'; // Import library provider untuk state management

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UniversityProvider(), // Membungkus MyApp dengan Provider untuk state management
      child: const MyApp(),
    ),
  );
}

class University {
  final String name; // Variabel untuk menyimpan nama universitas
  final String website; // Variabel untuk menyimpan situs web universitas

  University({required this.name, required this.website}); // Konstruktor untuk inisialisasi objek University

  factory University.fromJson(Map<String, dynamic> json) {
    // Factory method untuk membuat objek University dari data JSON
    return University(
      name: json['name'], // Mengambil nama universitas dari data JSON
      website: json['web_pages'][0], // Mengambil situs web pertama universitas dari data JSON
    );
  }
}

class UniversityProvider with ChangeNotifier {
  List<University> universities = []; // List universitas

  Future<void> fetchUniversities(String country) async {
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?country=$country'),
    ); // Mengirim permintaan HTTP untuk mendapatkan data universitas dari API

    if (response.statusCode == 200) {
      // Jika permintaan berhasil
      List<dynamic> data = jsonDecode(response.body); // Mendekode data JSON
      universities = data.map((json) => University.fromJson(json)).toList(); // Mengonversi data JSON menjadi daftar objek University
    } else {
      throw Exception('Failed to load universities'); // Jika permintaan gagal, lempar exception
    }
    notifyListeners(); // Memberi tahu listener bahwa data telah berubah
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueGrey, // Warna primer aplikasi
        dividerColor: Colors.grey, // Warna garis pemisah
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Universities in ASEAN', // Judul aplikasi
            style: TextStyle(fontWeight: FontWeight.bold), // Judul teks bold
          ),
          centerTitle: true, // Memusatkan judul
        ),
        body: Center(
          child: Column(
            children: [
              CountryDropdown(), // Menambahkan combobox untuk negara
              Expanded(
                child: UniversityList(), // Menampilkan daftar universitas
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountryDropdown extends StatefulWidget {
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String _selectedCountry = 'Indonesia'; // Default negara

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedCountry,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCountry = newValue!; // Mengatur negara yang dipilih saat perubahan dilakukan
          Provider.of<UniversityProvider>(context, listen: false)
              .fetchUniversities(_selectedCountry); // Memanggil fetchUniversities saat negara dipilih
        });
      },
      items: <String>['Indonesia', 'Singapore', 'Malaysia', 'Thailand', 'Filipina', 'Brunei Darussalam', 'Vietnam', 'Laos', 'Myanmar', 'Kamboja'] // Menambahkan negara ASEAN lainnya
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value), // Menampilkan nama negara pada combobox
        );
      }).toList(),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UniversityProvider>(
      builder: (context, universityProvider, _) {
        if (universityProvider.universities.isEmpty) {
          return Center(
            child: CircularProgressIndicator(), // Menampilkan indikator loading saat data masih dimuat
          );
        }
        return ListView.builder(
          itemCount: universityProvider.universities.length, // Jumlah item dalam ListView
          itemBuilder: (context, index) {
            return Card(
              elevation: 3, // Efek bayangan kartu
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margin kartu
              child: ListTile(
                title: Text(
                  universityProvider.universities[index].name, // Menampilkan nama universitas
                  style: TextStyle(fontWeight: FontWeight.bold), // Teks nama universitas bold
                ),
                subtitle: Text(universityProvider.universities[index].website), // Menampilkan situs web universitas
                onTap: () {
                  // Aksi ketika ListTile diklik
                  // Misalnya, buka situs web universitas
                  // Bisa tambahkan fungsi navigasi atau fungsi lainnya di sini
                },
              ),
            );
          },
        );
      },
    );
  }
}

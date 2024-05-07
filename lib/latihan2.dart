import 'package:flutter/material.dart'; // Import library Flutter untuk membuat UI
import 'package:http/http.dart' as http; // Import library http untuk mengirim permintaan HTTP
import 'dart:convert'; // Import library untuk mengonversi data JSON
import 'package:flutter_bloc/flutter_bloc.dart'; // Import library flutter_bloc untuk menggunakan Bloc

void main() {
  runApp(MyApp()); // Fungsi utama untuk menjalankan aplikasi Flutter
}

class University { // Class untuk merepresentasikan data universitas
  final String name; // Variabel untuk menyimpan nama universitas
  final String website; // Variabel untuk menyimpan situs web universitas

  University({required this.name, required this.website}); // Konstruktor untuk inisialisasi objek University

  factory University.fromJson(Map<String, dynamic> json) { // Factory method untuk membuat objek University dari data JSON
    return University(
      name: json['name'], // Ambil nama universitas dari data JSON
      website: json['web_pages'][0], // Ambil situs web pertama universitas dari data JSON
    );
  }
}

class UniversityBloc extends Cubit<String> { // Bloc untuk mengelola negara yang dipilih
  UniversityBloc() : super(''); // Inisialisasi Bloc dengan negara kosong sebagai nilai awal

  void changeCountry(String country) { // Method untuk mengubah negara yang dipilih
    emit(country); // Mengeluarkan perubahan negara yang dipilih
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueGrey, // Warna primer aplikasi
        dividerColor: Colors.grey, // Warna garis pemisah
      ),
      home: BlocProvider( // Membungkus aplikasi dengan BlocProvider untuk menyediakan UniversityBloc ke seluruh aplikasi
        create: (_) => UniversityBloc(), // Membuat instance dari UniversityBloc dan menyediakannya kepada child widget
        child: UniversityPage(), // Widget utama aplikasi
      ),
    );
  }
}

class UniversityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UniversityBloc universityBloc = BlocProvider.of<UniversityBloc>(context); // Mendapatkan instance UniversityBloc dari BlocProvider

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Universities in ASEAN', // Judul aplikasi
          style: TextStyle(fontWeight: FontWeight.bold), // Judul teks bold
        ),
        centerTitle: true, // Pusatkan judul
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityBloc, String>(
            builder: (context, country) {
              return DropdownButton<String>(
                value: country, // Nilai yang dipilih pada combobox
                onChanged: (String? newValue) { // Fungsi ketika nilai combobox berubah
                  universityBloc.changeCountry(newValue!); // Memanggil method changeCountry pada UniversityBloc
                },
                items: <String>[ // Daftar negara ASEAN yang ditampilkan di combobox
                  '',
                  'Indonesia',
                  'Malaysia',
                  'Singapore',
                  'Thailand',
                  'Filipina',
                  'Brunei Darussalam',
                  'Vietnam',
                  'Laos',
                  'Myanmar',
                  'Kamboja'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Teks yang ditampilkan untuk setiap item di combobox
                  );
                }).toList(),
              );
            },
          ),
          Expanded(
            child: UniversityList(), // Widget untuk menampilkan daftar universitas
          ),
        ],
      ),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UniversityBloc universityBloc = BlocProvider.of<UniversityBloc>(context); // Mendapatkan instance UniversityBloc dari BlocProvider

    return BlocBuilder<UniversityBloc, String>(
      builder: (context, country) {
        return FutureBuilder<List<University>>(
          future: fetchUniversities(country), // Memanggil method fetchUniversities untuk mendapatkan data universitas
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) { // Saat data masih dimuat
              return Center(
                child: CircularProgressIndicator(), // Tampilkan indikator loading
              );
            } else if (snapshot.hasError) { // Jika terjadi kesalahan
              return Center(
                child: Text('Error: ${snapshot.error}'), // Tampilkan pesan kesalahan
              );
            } else { // Jika data sudah tersedia
              return ListView.builder( // Widget untuk menampilkan daftar universitas dalam ListView
                itemCount: snapshot.data!.length, // Jumlah item dalam ListView
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3, // Efek bayangan kartu
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margin kartu
                    child: ListTile(
                      title: Text(
                        snapshot.data![index].name, // Tampilkan nama universitas
                        style: TextStyle(fontWeight: FontWeight.bold), // Teks nama universitas bold
                      ),
                      subtitle: Text(snapshot.data![index].website), // Tampilkan situs web universitas
                      onTap: () {
                      },
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Future<List<University>> fetchUniversities(String country) async { // Method untuk mendapatkan data universitas dari API berdasarkan negara yang dipilih
    if (country.isEmpty) {
      return []; // Jika negara kosong, kembalikan daftar kosong
    }

    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Mengirim permintaan HTTP untuk mendapatkan data universitas dari API

    if (response.statusCode == 200) { // Jika permintaan berhasil
      List<dynamic> data = jsonDecode(response.body); // Mendekode data JSON
      return data.map((json) => University.fromJson(json)).toList(); // Mengonversi data JSON menjadi daftar objek University
    } else {
      throw Exception('Failed to load universities'); // Jika permintaan gagal, lempar exception
    }
  }
}

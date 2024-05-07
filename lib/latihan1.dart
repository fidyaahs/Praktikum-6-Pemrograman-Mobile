import 'package:flutter/material.dart'; // Import library Flutter untuk membuat UI
import 'package:http/http.dart' as http; // Import library http untuk mengirim permintaan HTTP
import 'dart:convert'; // Import library untuk mengonversi data JSON
import 'package:flutter_bloc/flutter_bloc.dart'; // Import library Bloc

void main() {
  runApp(MyApp());
}

class University {
  final String name; // Variabel untuk menyimpan nama universitas
  final String website; // Variabel untuk menyimpan situs web universitas

  University({required this.name, required this.website}); // Konstruktor untuk inisialisasi objek University

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Mengambil nama universitas dari data JSON
      website: json['web_pages'][0], // Mengambil situs web pertama universitas dari data JSON
    );
  }
}

class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]);

  Future<void> fetchUniversities(String country) async {
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?country=$country'), // Mengirim permintaan HTTP untuk mendapatkan data universitas dari API
    );

    if (response.statusCode == 200) { // Jika permintaan berhasil
      List<dynamic> data = jsonDecode(response.body); // Mendekode data JSON
      emit(data.map((json) => University.fromJson(json)).toList()); // Emit daftar universitas yang diperoleh dari respons API
    } else {
      throw Exception('Failed to load universities'); // Jika permintaan gagal, lempar exception
    }
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
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Universities in ASEAN', // Judul aplikasi
            style: TextStyle(fontWeight: FontWeight.bold), // Judul teks bold
          ),
          centerTitle: true, // Pusatkan judul
        ),
        body: BlocProvider(
          create: (context) => UniversityCubit(), // Membuat instance dari UniversityCubit dan memberikannya ke BlocProvider
          child: UniversityPage(), // Menampilkan UniversityPage di dalam BlocProvider
        ),
      ),
    );
  }
}

class UniversityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UniversityCubit universityCubit = BlocProvider.of<UniversityCubit>(context); // Mendapatkan instance dari UniversityCubit dari BlocProvider

    return Column(
      children: [
        CountryDropdown(), // Menampilkan dropdown untuk memilih negara
        Expanded(
          child: BlocBuilder<UniversityCubit, List<University>>( // Mendengarkan perubahan state UniversityCubit dan membangun UI sesuai dengan state yang diperbarui
            builder: (context, state) {
              if (state.isEmpty) { // Jika daftar universitas kosong, tampilkan indikator loading
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder( // Jika ada data universitas, tampilkan dalam ListView
                itemCount: state.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3, // Efek bayangan kartu
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Margin kartu
                    child: ListTile(
                      title: Text(
                        state[index].name, // Menampilkan nama universitas
                        style: TextStyle(fontWeight: FontWeight.bold), // Teks nama universitas bold
                      ),
                      subtitle: Text(state[index].website), // Menampilkan situs web universitas
                      onTap: () {}, // Aksi ketika ListTile diklik
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CountryDropdown extends StatefulWidget {
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  late String _selectedCountry = 'Indonesia'; // Default negara

  @override
  Widget build(BuildContext context) {
    final UniversityCubit universityCubit = BlocProvider.of<UniversityCubit>(context); // Mendapatkan instance dari UniversityCubit dari BlocProvider

    return DropdownButton<String>(
      value: _selectedCountry,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCountry = newValue!; // Set nilai negara yang dipilih
          universityCubit.fetchUniversities(_selectedCountry); // Memanggil metode fetchUniversities saat negara dipilih
        });
      },
      items: <String>['Indonesia', 'Singapore', 'Malaysia', 'Thailand', 'Filipina', 'Brunei Darussalam', 'Vietnam', 'Laos', 'Myanmar', 'Kamboja'] // Opsi negara ASEAN
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

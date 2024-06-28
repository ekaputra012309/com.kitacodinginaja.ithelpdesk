import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../constans.dart';

class RequestCreate extends StatefulWidget {
  final VoidCallback? onRequestAdded;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const RequestCreate({super.key, this.onRequestAdded, required this.scaffoldMessengerKey});

  @override
  State<RequestCreate> createState() => _RequestCreateState();
}

class _RequestCreateState extends State<RequestCreate> {
  final ApiService _apiService = ApiService();

  final List<String> _kategori = ['Hardware', 'Software', 'Jaringan', 'Other'];
  final List<String> _tingkat = ['Mudah', 'Sedang', 'Sulit'];

  final FormGroup form = FormGroup({
    'pelapor': FormControl<String>(validators: [Validators.required]),
    'lantai': FormControl<String>(validators: [Validators.required]),
    'lokasi': FormControl<String>(validators: [Validators.required]),
    'tingkat': FormControl<String>(validators: [Validators.required]),
    'kategori': FormControl<String>(validators: [Validators.required]),
    'kategori2': FormControl<String>(validators: [Validators.required]),
    'kendala': FormControl<String>(validators: [Validators.required]),
  });

  List<Map<String, dynamic>> kategoriItems = [];
  List<Map<String, dynamic>> lantaiItems = [];
  List<Map<String, dynamic>> lokasiItems = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    fetchInitialKategori();
  }

  Future<void> fetchInitialData() async {
    try {
      lantaiItems = await fetchLantai();
      setState(() {}); // Refresh the UI
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }

    form.control('lantai').valueChanges.listen((lantaiId) {
      if (lantaiId != null) {
        fetchLokasi(lantaiId).then((items) {
          setState(() {
            lokasiItems = items;
          });
        }).catchError((error) {
          setState(() {
            errorMessage = error.toString();
          });
        });
      } else {
        setState(() {
          lokasiItems = [];
        });
      }
    });
  }

  Future<void> fetchInitialKategori() async {
    form.control('kategori').valueChanges.listen((kategoriId) {
      if (kategoriId != null) {
        fetchKategori(kategoriId).then((items) {
          setState(() {
            kategoriItems = items;
          });
        }).catchError((error) {
          setState(() {
            errorMessage = error.toString();
          });
        });
      } else {
        setState(() {
          kategoriItems = [];
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchKategori(String kategoriId) async {
    return _fetchData('/kategori?kategoriId=$kategoriId');
  }

  Future<List<Map<String, dynamic>>> fetchLantai() async {
    return _fetchData('/lantai');
  }

  Future<List<Map<String, dynamic>>> fetchLokasi(String lantaiId) async {
    return _fetchData('/lokasi?lantaiId=$lantaiId');
  }

  Future<List<Map<String, dynamic>>> _fetchData(String endpoint) async {
    try {
      final response = await _apiService.getRequest(endpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to load data: Invalid response format');
      }
    } catch (e) {
      throw Exception('Error during fetch data: $e');
    }
  }

  Future<void> _save() async {
    if (form.valid) {
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final token = userDataProvider.getToken();
      final userId = userDataProvider.getId();

      if (token == null || userId == null) {
        debugPrint('Error, no token or user id');
        return;
      }

      try {
        final data = {
          'pelapor': form.control('pelapor').value,
          'lokasi_id': form.control('lokasi').value,
          'tingkat': form.control('tingkat').value,
          'kategori_id': form.control('kategori2').value,
          'kendala': form.control('kendala').value,
          'user_id': userId,
        };

        final response = await _apiService.postRequest('/permintaan', data);

        final String message = response.data['message'];
        final isSuccess = response.statusCode == 201;

        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );

        if (isSuccess && widget.onRequestAdded != null) {
          widget.onRequestAdded!();
          if (!mounted) return;
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error during add request: $e');
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Request'),
        backgroundColor: CustomColors.second,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: errorMessage != null
            ? Center(child: Text(errorMessage!))
            : SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 32.0, // Adjust the padding and constraints as per your need
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: CustomColors.putih
                    ),
                    child: ReactiveForm(
                      formGroup: form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text('Pelapor'),
                          const SizedBox(height: 16),
                          ReactiveTextField<String>(
                            formControlName: 'pelapor',
                            decoration: const InputDecoration(
                              hintText: 'Pelapor',
                              border: OutlineInputBorder(),
                            ),
                            validationMessages: {
                              'required': (error) => 'Please enter some text',
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Pilih Lantai'),                        
                          const SizedBox(height: 16),
                          ReactiveDropdownField<String>(
                            formControlName: 'lantai',
                            decoration: const InputDecoration(
                              hintText: 'Lantai',
                              border: OutlineInputBorder(),
                            ),
                            validationMessages: {
                              'required': (error) => 'Please select a lantai',
                            },
                            items: lantaiItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(item['floorname']),
                              );
                            }).toList(),
                            onChanged: (control) {
                              setState(() {
                                lokasiItems = [];
                              });                          
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Pilih Lokasi'),
                          const SizedBox(height: 16),
                          ReactiveDropdownField<String>(
                            formControlName: 'lokasi',
                            decoration: const InputDecoration(
                              hintText: 'Lokasi',
                              border: OutlineInputBorder(),
                            ),
                            validationMessages: {
                              'required': (error) => 'Please select a lokasi',
                            },
                            items: lokasiItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(item['locationname']),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Text('Pilih Tingkat Kesulitan'),
                          const SizedBox(height: 16),
                          ReactiveDropdownField<String>(
                            formControlName: 'tingkat',
                            decoration: const InputDecoration(
                              hintText: 'Tingkat Kesulitan',
                              border: OutlineInputBorder(),
                            ),
                            items: _tingkat.map((tingkat) {
                              return DropdownMenuItem<String>(
                                value: tingkat,
                                child: Text(tingkat),
                              );
                            }).toList(),
                            validationMessages: {
                              'required': (error) => 'Please select a tingkat',
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Pilih Kategori 1'),
                          const SizedBox(height: 16),
                          ReactiveDropdownField<String>(
                            formControlName: 'kategori',
                            decoration: const InputDecoration(
                              hintText: 'Kategori 1',
                              border: OutlineInputBorder(),
                            ),
                            items: _kategori.map((kategori) {
                              return DropdownMenuItem<String>(
                                value: kategori,
                                child: Text(kategori),
                              );
                            }).toList(),
                            onChanged: (control) {
                              setState(() {
                                kategoriItems = [];
                              });                          
                            },
                            validationMessages: {
                              'required': (error) => 'Please select a kategori',
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Pilih Kategori 2'),
                          const SizedBox(height: 16),
                          ReactiveDropdownField<String>(
                            formControlName: 'kategori2',
                            decoration: const InputDecoration(
                              hintText: 'Kategori 2',
                              border: OutlineInputBorder(),
                            ),
                            items: kategoriItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['id'].toString(),
                                child: Text(item['hashtag']),
                              );
                            }).toList(),
                            validationMessages: {
                              'required': (error) => 'Please select a kategori',
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Kendala'),
                          const SizedBox(height: 16),
                          ReactiveTextField<String>(
                            formControlName: 'kendala',
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Kendala',
                              border: OutlineInputBorder(),
                            ),
                            validationMessages: {
                              'required': (error) => 'Please enter some text',
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.second,
                              foregroundColor: CustomColors.putih,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),
                            onPressed: _save,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 8),
                                Text('Simpan Data'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32), // Add extra space at the bottom
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }


}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../constans.dart';
import 'widget/request_model.dart';

class RequestEdit extends StatefulWidget {
  final DataItem item;
  final VoidCallback? onRequestUpdated;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const RequestEdit({
    super.key,
    required this.item,
    this.onRequestUpdated,
    required this.scaffoldMessengerKey,
  });

  @override
  State<RequestEdit> createState() => _RequestEditState();
}

class _RequestEditState extends State<RequestEdit> {
  final ApiService _apiService = ApiService();

  final List<String> _tingkat = ['Mudah', 'Sedang', 'Sulit'];

  final FormGroup form = FormGroup({
    'pelapor': FormControl<String>(validators: [Validators.required]),
    'lokasi': FormControl<String>(validators: [Validators.required]),
    'tingkat': FormControl<String>(validators: [Validators.required]),
    'kategori2': FormControl<String>(validators: [Validators.required]),
    'kendala': FormControl<String>(validators: [Validators.required]),
  });

  List<Map<String, dynamic>> lokasiItems = [];
  List<Map<String, dynamic>> kategori2Items = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeForm();
    fetchInitialData();
  }

  void initializeForm() {
    form.control('pelapor').value = widget.item.pelapor;
    form.control('lokasi').value = widget.item.lokasiId.toString();
    form.control('tingkat').value = widget.item.tingkat;
    form.control('kategori2').value = widget.item.kategoriId.toString();
    form.control('kendala').value = widget.item.kendala;
  }

  Future<void> fetchInitialData() async {
    try {
      await fetchLokasi(); // Fetch all lokasi options
      await fetchKategori2();
      setState(() {}); // Refresh the UI
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }
  }

  Future<void> fetchLokasi() async {
    try {
      final response = await _apiService.getRequest('/lokasi');
      if (response.statusCode == 200 && response.data['success'] == true) {
        lokasiItems = List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to load lokasi data');
      }
    } catch (e) {
      throw Exception('Error during fetch lokasi data: $e');
    }
  }

  Future<void> fetchKategori2() async {
    try {
      final response = await _apiService.getRequest('/kategori');
      if (response.statusCode == 200 && response.data['success'] == true) {
        kategori2Items = List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to load kategori data');
      }
    } catch (e) {
      throw Exception('Error during fetch kategori data: $e');
    }
  }

  Future<void> _update() async {
    if (form.valid) {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
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

        final response = await _apiService.putRequest(
            '/permintaan/${widget.item.id}', data);

        final String message = response.data['message'];
        final isSuccess = response.statusCode == 200;

        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );

        if (isSuccess && widget.onRequestUpdated != null) {
          widget.onRequestUpdated!();
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint('Error during update request: $e');
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
        title: const Text('Edit Request'),
        backgroundColor: CustomColors.second,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pop();
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
                    minHeight: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        32.0, // Adjust the padding and constraints as per your need
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      color: CustomColors.putih,
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
                          const Text('Pilih Kategori 2'),
                          const SizedBox(height: 16),
                          ReactiveDropdownField<String>(
                            formControlName: 'kategori2',
                            decoration: const InputDecoration(
                              hintText: 'Kategori 2',
                              border: OutlineInputBorder(),
                            ),
                            items: kategori2Items.map((item) {
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
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            onPressed: _update,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save),
                                SizedBox(width: 8),
                                Text('Update Data'),
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

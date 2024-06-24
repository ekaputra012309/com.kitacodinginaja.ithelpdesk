import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class KategoriCreate extends StatefulWidget {
  final VoidCallback? onKategoriAdded;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const KategoriCreate(
      {super.key, this.onKategoriAdded, required this.scaffoldMessengerKey});

  @override
  State<KategoriCreate> createState() => _KategoriCreateState();
}

class _KategoriCreateState extends State<KategoriCreate> {
  final ApiService _apiService = ApiService();

  final List<String> _kategori = ['Hardware', 'Software', 'Jaringan', 'Other'];

  final FormGroup form = FormGroup({
    'hashtag': FormControl<String>(
      validators: [Validators.required],
    ),
    'selectedKategori': FormControl<String>(
      validators: [Validators.required],
    ),
  });

  Future<void> _save() async {
    if (form.valid) {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final token = userDataProvider.getToken();
      final userid = userDataProvider.getId();

      if (token == null || userid == null) {
        debugPrint('Error, no token or user id');
        return;
      }

      try {
        Map<String, dynamic> data = {
          'hashtag': form.control('hashtag').value,
          'categoryname': form.control('selectedKategori').value,
          'user_id': userid,
        };

        Response response = await _apiService.postRequest('/kategori', data);

        if (response.statusCode == 201) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          if (widget.onKategoriAdded != null) {
            widget.onKategoriAdded!();
          }
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          final String message = response.data['message'];
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error during add kategori: $e');
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
        title: const Text('Add Kategori'),
        backgroundColor: CustomColors.second,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            children: <Widget>[
              ReactiveTextField<String>(
                formControlName: 'hashtag',
                decoration: const InputDecoration(
                  labelText: '(#) Hashtag',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.keyboard),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter some text',
                },
              ),
              const SizedBox(height: 16),
              ReactiveDropdownField<String>(
                formControlName: 'selectedKategori',
                decoration: const InputDecoration(
                  labelText: 'Pilih Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list),
                ),
                items: _kategori
                    .map((kategori) => DropdownMenuItem<String>(
                          value: kategori,
                          child: Text(kategori),
                        ))
                    .toList(),
                validationMessages: {
                  'required': (error) => 'Please select a kategori',
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(
                              width:
                                  8), // Add some spacing between the icon and text
                          Text(
                            'Simpan Data',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

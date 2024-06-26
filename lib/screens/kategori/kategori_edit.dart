import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class KategoriEdit extends StatefulWidget {
  final VoidCallback? onKategoriEdited;
  final Map<String, dynamic> data;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const KategoriEdit(
      {super.key,
      this.onKategoriEdited,
      required this.data,
      required this.scaffoldMessengerKey});

  @override
  State<KategoriEdit> createState() => _KategoriEditState();
}

class _KategoriEditState extends State<KategoriEdit> {
  final ApiService _apiService = ApiService();

  final List<String> _kategori = ['Hardware', 'Software', 'Jaringan', 'Other'];

  late final FormGroup form = FormGroup({
    'hashtag': FormControl<String>(
      value: widget.data['hashtag'],
      validators: [Validators.required],
    ),
    'selectedKategori': FormControl<String>(
      value: widget.data['categoryname'],
      validators: [Validators.required],
    ),
  });

  Future<void> _update() async {
    if (form.valid) {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      final userid = userDataProvider.getId();

      try {
        Map<String, dynamic> data = {
          'hashtag': form.control('hashtag').value,
          'categoryname': form.control('selectedKategori').value,
          'user_id': userid,
        };
        Response response = await _apiService.putRequest(
            '/kategori/${widget.data['id']}', data);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          if (widget.onKategoriEdited != null) {
            widget.onKategoriEdited!();
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
        debugPrint('Error during edit kategori: $e');
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
        title: const Text('Edit Kategori'),
        backgroundColor: CustomColors.second,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('(#) Hashtag'),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'hashtag',
                decoration: const InputDecoration(
                  hintText: '(#) Hashtag',
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter some text',
                },
              ),
              const SizedBox(height: 16),
              const Text('Pilih Kategori'),
              const SizedBox(height: 16),
              ReactiveDropdownField<String>(
                formControlName: 'selectedKategori',
                decoration: const InputDecoration(
                  hintText: 'Pilih Kategori',
                  border: OutlineInputBorder(),
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
                    onPressed: _update,
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
                            'Update Data',
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

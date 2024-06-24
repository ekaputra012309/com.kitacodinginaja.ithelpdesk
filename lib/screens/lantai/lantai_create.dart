import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class LantaiCreate extends StatefulWidget {
  final VoidCallback? onLantaiAdded;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const LantaiCreate({
    super.key,
    this.onLantaiAdded,
    required this.scaffoldMessengerKey,
  });

  @override
  State<LantaiCreate> createState() => _LantaiCreateState();
}

class _LantaiCreateState extends State<LantaiCreate> {
  final ApiService _apiService = ApiService();

  final FormGroup form = FormGroup({
    'floorname': FormControl<String>(
      validators: [Validators.required],
    ),
  });

  Future<void> _save() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final userid = userDataProvider.getId();

    if (form.valid) {
      final String floorname = form.control('floorname').value;

      try {
        Map<String, dynamic> data = {
          'floorname': floorname,
          'user_id': userid,
        };
        Response response = await _apiService.postRequest('/lantai', data);

        if (response.statusCode == 201) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];

          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          if (widget.onLantaiAdded != null) {
            widget.onLantaiAdded!();
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
        debugPrint('Error during add lantai: $e');
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
        title: const Text('Add Lantai'),
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
                formControlName: 'floorname',
                decoration: const InputDecoration(
                  labelText: 'Nama Lantai',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list_rounded),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter some text',
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
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
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

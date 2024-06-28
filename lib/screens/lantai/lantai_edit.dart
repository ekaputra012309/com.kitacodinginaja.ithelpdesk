import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class LantaiEdit extends StatefulWidget {
  final VoidCallback? onLantaiEdited;
  final Map<String, dynamic> data;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const LantaiEdit({
    super.key,
    this.onLantaiEdited,
    required this.data,
    required this.scaffoldMessengerKey,
  });

  @override
  State<LantaiEdit> createState() => _LantaiEditState();
}

class _LantaiEditState extends State<LantaiEdit> {
  final ApiService _apiService = ApiService();

  late String _floorNameValue;
  late int _idValue;

  final FormGroup form = FormGroup({
    'floorname': FormControl<String>(
      validators: [Validators.required],
    ),
  });

  @override
  void initState() {
    super.initState();
    _floorNameValue = widget.data['floorname'] ?? '';
    _idValue = widget.data['id'] ?? 0;
    form.control('floorname').value = _floorNameValue;
  }

  Future<void> _update() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final token = userDataProvider.getToken();
    final userid = userDataProvider.getId();

    if (token == null || userid == null) {
      debugPrint('Error, no token or user id');
      return;
    }

    if (form.valid) {
      final String floorname = form.control('floorname').value;
      final int id = _idValue;

      try {
        Map<String, dynamic> data = {
          'floorname': floorname,
          'user_id': userid,
        };
        Response response = await _apiService.putRequest('/lantai/$id', data);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];

          if (widget.onLantaiEdited != null) {
            widget.onLantaiEdited!();
          }
          if (!mounted) return;
          Navigator.pop(context);
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
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
        debugPrint('Error during update lantai: $e');
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
        title: const Text('Edit Lantai'),
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
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('Nama Lantai'),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'floorname',
                decoration: const InputDecoration(
                  hintText: 'Nama Lantai',
                  border: OutlineInputBorder(),
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
                    onPressed: _update,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text(
                          'Update Data',
                        ),
                      ],
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

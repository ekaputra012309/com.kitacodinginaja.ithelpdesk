import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../constans.dart';

class Profile extends StatefulWidget {
  final VoidCallback? onUserEdited;
  final int id;
  final String nama;
  final String email;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const Profile(
      {super.key,
      this.onUserEdited,
      required this.id,
      required this.nama,
      required this.email,
      required this.scaffoldMessengerKey});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ApiService _apiService = ApiService();

  late final FormGroup form = FormGroup({
    'name': FormControl<String>(
      value: widget.nama,
      validators: [Validators.required],
    ),
    'email': FormControl<String>(
      value: widget.email,
      validators: [Validators.required, Validators.email],
    ),
  });

  Future<void> _update() async {
    if (form.valid) {
      try {
        Map<String, dynamic> data = {
          'name': form.control('name').value,
          'email': form.control('email').value,
          'user_id': widget.id,
        };
        Response response =
            await _apiService.putRequest('/user/${widget.id}', data);

        if (response.statusCode == 200) {
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Profile updated'),
            ),
          );
          if (widget.onUserEdited != null) {
            widget.onUserEdited!();
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
        debugPrint('Error during edit user: $e');
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
        title: const Text('Edit Profile'),
        backgroundColor: CustomColors.first,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            children: <Widget>[
              ReactiveTextField<String>(
                formControlName: 'name',
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.keyboard),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter some text',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'email',
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter some text',
                  'email': (error) => 'The email value must be a valid email',
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.first,
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
                            'Update Profile',
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

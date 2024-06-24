import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../constans.dart';

class Changepassword extends StatefulWidget {
  final VoidCallback? onUserEdited;
  final int id;
  final String nama;
  final String email;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const Changepassword(
      {super.key,
      this.onUserEdited,
      required this.id,
      required this.nama,
      required this.email,
      required this.scaffoldMessengerKey});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final ApiService _apiService = ApiService();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final FormGroup form = FormGroup({
    'old_password': FormControl<String>(
      validators: [Validators.required],
    ),
    'password': FormControl<String>(
      validators: [Validators.required],
    ),
    'confirm_password': FormControl<String>(),
  }, validators: [
    Validators.mustMatch('password', 'confirm_password'),
  ]);

  Future<void> _update() async {
    if (form.valid) {
      try {
        Map<String, dynamic> data = {
          'name': widget.nama,
          'email': widget.email,
          'password': form.control('password').value,
          'user_id': widget.id,
        };
        Response response =
            await _apiService.putRequest('/user/${widget.id}', data);

        if (response.statusCode == 200) {
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Password updated'),
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
        title: const Text('Change Password'),
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
                formControlName: 'old_password',
                obscureText: _obscureOldPassword,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.keyboard),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOldPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter your old password',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'password',
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.keyboard),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter a new password',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField<String>(
                formControlName: 'confirm_password',
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.keyboard),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validationMessages: {
                  'required': (error) => 'Please confirm your new password',
                  'mustMatch': (error) => 'Passwords do not match',
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
                            'Save Changes',
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

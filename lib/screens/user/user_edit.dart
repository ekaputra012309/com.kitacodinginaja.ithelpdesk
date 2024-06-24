import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class UserEdit extends StatefulWidget {
  final VoidCallback? onUserEdited;
  final Map<String, dynamic> data;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const UserEdit(
      {super.key,
      this.onUserEdited,
      required this.data,
      required this.scaffoldMessengerKey});

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  final ApiService _apiService = ApiService();
  bool passwordVisible = false;
  final List<String> _role = ['Admin', 'IT', 'User'];

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

  late final FormGroup form = FormGroup({
    'name': FormControl<String>(
      value: widget.data['name'],
      validators: [Validators.required],
    ),
    'email': FormControl<String>(
      value: widget.data['email'],
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      value: widget.data['password'],
    ),
    'selectedRole': FormControl<String>(
      value: widget.data['role'],
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
          'name': form.control('name').value,
          'email': form.control('email').value,
          'password': form.control('password').value,
          'role': form.control('selectedRole').value,
          'user_id': userid,
        };
        Response response =
            await _apiService.putRequest('/user/${widget.data['id']}', data);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
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
        title: const Text('Edit User'),
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
              ReactiveTextField<String>(
                formControlName: 'password',
                obscureText: passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                    icon: Icon(passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                ),
                validationMessages: {
                  'required': (error) => 'Please enter some text',
                  'minLength': (error) =>
                      'The password must have at least 8 characters',
                },
              ),
              const SizedBox(height: 16),
              ReactiveDropdownField<String>(
                formControlName: 'selectedRole',
                decoration: const InputDecoration(
                  labelText: 'Pilih Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list),
                ),
                items: _role
                    .map((role) => DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                validationMessages: {
                  'required': (error) => 'Please select a role',
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

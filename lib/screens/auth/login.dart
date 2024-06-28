import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../constans.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService _apiService = ApiService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    var box = await Hive.openBox('userData');
    final String? savedEmail = box.get('savedEmail');
    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final String password = _passwordController.text;
      try {
        Map<String, dynamic> data = {
          'email': email,
          'password': password,
        };
        Response response = await _apiService.postRequest('/login', data);
        debugPrint('Response status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseBody = response.data;
          final bool success = responseBody['success'];
          final String? message = responseBody['message'];
          if (success) {
            final Map<String, dynamic> data = responseBody['data'];

            final String? accessToken = data['token'];
            final String? name = data['name'];
            final String? userEmail = data['email'];
            final String? role = data['role'];
            final int? id = data['id'];

            if (accessToken != null &&
                name != null &&
                userEmail != null &&
                role != null &&
                id != null) {
              debugPrint('Message: $message');
              var box = await Hive.openBox('userData');
              box.put('accessToken', accessToken);
              box.put('name', name);
              box.put('email', userEmail);
              box.put('role', role);
              box.put('id', id);

              // Save email
              box.put('savedEmail', email);

              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(message ?? 'Login successful'),
                ),
              );
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/dash');
            } else {
              debugPrint('Login response missing required fields');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('Login response missing required fields'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            debugPrint('Login failed: $message');
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text(message ?? 'Login failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          final Map<String, dynamic> responseBody = response.data;
          final String? message = responseBody['message'];

          debugPrint('Login failed: $message');
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on DioException catch (e) {
        // Handle Dio errors
        debugPrint('Dio error: ${e.message}');

        if (e.response != null) {
          // Dio has received a response, handle the error
          final Map<String, dynamic> responseBody = e.response!.data;
          final String? message = responseBody['message'];

          debugPrint('Login failed: $message');
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Dio sent the request but no response was received
          debugPrint('No response received');
          _scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('No response received'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle other unexpected errors
        debugPrint('Error during login: $e');
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error during login: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          body: Container(
            color: CustomColors.putih,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'IT HELP DESK',
                        style: TextStyle(
                            fontSize: 32.0, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Sign in to start your session',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: !_obscureText,
                                onChanged: (bool? value) {
                                  _togglePasswordVisibility();
                                },
                              ),
                              const Text('Show Password'),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CustomColors.second,
                              foregroundColor: CustomColors.putih,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Sign In',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

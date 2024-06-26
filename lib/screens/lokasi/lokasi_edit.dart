import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class LokasiEdit extends StatefulWidget {
  final VoidCallback? onLokasiEdited;
  final Map<String, dynamic> data;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const LokasiEdit(
      {super.key,
      this.onLokasiEdited,
      required this.data,
      required this.scaffoldMessengerKey});

  @override
  State<LokasiEdit> createState() => _LokasiEditState();
}

class _LokasiEditState extends State<LokasiEdit> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationname = TextEditingController();
  late String _locationnameValue;
  late int _idValue;
  late int _flooridValue;
  int? _selectedFloorId;
  List<Map<String, dynamic>> _floors = [];

  @override
  void initState() {
    super.initState();
    _fetchFloors();
    _locationnameValue = widget.data['locationname'] ?? '';
    _idValue = widget.data['id'] ?? 0;
    _flooridValue = widget.data['floor_id'] ?? '';
    _locationname.text = _locationnameValue;
    _selectedFloorId = _flooridValue;
  }

  void _onlocationnameChanged(String value) {
    setState(() {
      _locationnameValue = value;
    });
  }

  Future<void> _fetchFloors() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final token = userDataProvider.getToken();

    if (token == null) {
      debugPrint('Error, no token');
      return;
    }

    try {
      Response response = await _apiService.getRequest('/lantai');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true &&
            responseData.containsKey('data')) {
          final List<dynamic> floors = responseData['data'];
          setState(() {
            _floors = floors.cast<Map<String, dynamic>>();
          });
        } else {
          throw Exception('Failed to load floors: Invalid response format');
        }
      } else {
        throw Exception('Failed to load floors. Please try again later.');
      }
    } catch (e) {
      debugPrint('Error during fetchFloors: $e');
      throw Exception('Error during fetchFloors: $e');
    }
  }

  Future<void> _update() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final userid = userDataProvider.getId();

    if (_formKey.currentState!.validate()) {
      final String locationname = _locationnameValue;
      final int id = _idValue;

      try {
        Map<String, dynamic> data = {
          'locationname': locationname,
          'floor_id': _selectedFloorId,
          'user_id': userid,
        };
        Response response = await _apiService.putRequest('/lokasi/$id', data);

        debugPrint('Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];

          if (widget.onLokasiEdited != null) {
            widget.onLokasiEdited!();
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
        debugPrint('Error during update lokasi: $e');
        widget.scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lokasi'),
        backgroundColor: CustomColors.second,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text('Nama Lokasi'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationname,
                    onChanged: _onlocationnameChanged,
                    decoration: const InputDecoration(
                      hintText: 'Nama Lokasi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Lantai'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      hintText: 'Pilih lantai',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedFloorId,
                    onChanged: (value) {
                      setState(() {
                        _selectedFloorId = value;
                      });
                    },
                    items: _floors.map<DropdownMenuItem<int>>((floor) {
                      return DropdownMenuItem<int>(
                        value: int.parse(floor['id']
                            .toString()), // Ensure id is parsed to int
                        child: Text(floor['floorname'] as String),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a floor';
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}

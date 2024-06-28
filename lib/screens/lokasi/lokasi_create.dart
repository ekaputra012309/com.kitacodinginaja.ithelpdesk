import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../constans.dart';

class LokasiCreate extends StatefulWidget {
  final VoidCallback? onLokasiAdded;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const LokasiCreate(
      {super.key, this.onLokasiAdded, required this.scaffoldMessengerKey});

  @override
  State<LokasiCreate> createState() => _LokasiCreateState();
}

class _LokasiCreateState extends State<LokasiCreate> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _locationname = TextEditingController();

  int? _selectedFloorId;
  List<Map<String, dynamic>> _floors = [];

  @override
  void initState() {
    super.initState();
    _fetchFloors();
  }

  Future<void> _fetchFloors() async {
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

  Future<void> _save() async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final userid = userDataProvider.getId();

    if (_formKey.currentState!.validate()) {
      final String locationname = _locationname.text;

      try {
        Map<String, dynamic> data = {
          'locationname': locationname,
          'floor_id': _selectedFloorId,
          'user_id': userid,
        };
        Response response = await _apiService.postRequest('/lokasi', data);

        if (response.statusCode == 201) {
          final Map<String, dynamic> data = response.data;
          final String message = data['message'];
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
          if (widget.onLokasiAdded != null) {
            widget.onLokasiAdded!();
          }
          // Navigate back to the lokasi list
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          final String message = response.data['message'];

          // Show error message in Snackbar
          widget.scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error during add lokasi: $e');
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
        title: const Text('Add lokasi'),
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
                    decoration: const InputDecoration(
                      hintText: 'Nama lokasi',
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
            const SizedBox(
                height: 16), // Add some spacing between the form and the button
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
                  child: const Row(
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
          ],
        ),
      ),
    );
  }
}

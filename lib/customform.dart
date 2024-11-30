import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(CustomForm());
}

class CustomForm extends StatelessWidget {
  const CustomForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Custom Form'),
        ),
        body: CustomForm34(),
      ),
    );
  }
}

class CustomForm34 extends StatefulWidget {
  const CustomForm34({super.key});

  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm34> {
  String _selectedOption = 'TextField';
  final TextEditingController _textController = TextEditingController();
  late String _filePath;
  late String _dropdownValue;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  bool _checkboxValue = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'TextField',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('TextField'),
                Radio<String>(
                  value: 'File',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('File'),
                Radio<String>(
                  value: 'Dropdown',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('Dropdown'),
                Radio<String>(
                  value: 'Checkbox',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('Checkbox'),
                Radio<String>(
                  value: 'DatePicker',
                  groupValue: _selectedOption,
                  onChanged: (value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('DatePicker'),
              ],
            ),
            if (_selectedOption == 'TextField') _buildTextField(),
            if (_selectedOption == 'File') _buildFileUpload(),
            if (_selectedOption == 'Dropdown') _buildDropdown(),
            if (_selectedOption == 'Checkbox') _buildCheckbox(),
            if (_selectedOption == 'DatePicker') _buildDatePicker(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _textController,
      decoration: const InputDecoration(
        labelText: 'Enter text',
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget _buildFileUpload() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          child: const Text('Upload File'),
        ),
        Text('Selected file: $_filePath'),
      ],
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _dropdownValue,
      items: ['Option 1', 'Option 2', 'Option 3']
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _dropdownValue = value!;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Select an option',
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }

  Widget _buildCheckbox() {
    return CheckboxListTile(
      title: const Text('Accept Terms and Conditions'),
      value: _checkboxValue,
      onChanged: (value) {
        setState(() {
          _checkboxValue = value!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Text(_selectedDate == null
            ? 'No date selected'
            : DateFormat.yMd().format(_selectedDate)),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _pickDate,
          child: const Text('Select Date'),
        ),
      ],
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedOption == 'TextField') {
        print('Submitted text: ${_textController.text}');
      } else if (_selectedOption == 'File') {
        print('Submitted file path: $_filePath');
      } else if (_selectedOption == 'Dropdown') {
        print('Selected option: $_dropdownValue');
      } else if (_selectedOption == 'Checkbox') {
        print('Checkbox value: $_checkboxValue');
      } else if (_selectedOption == 'DatePicker') {
        print('Selected date: ${DateFormat.yMd().format(_selectedDate)}');
      }
    }
  }
}

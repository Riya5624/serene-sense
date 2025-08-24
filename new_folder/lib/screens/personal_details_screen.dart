// lib/screens/personal_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serene_sense/providers/user_data_provider.dart';
import 'package:serene_sense/screens/home_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isAnonymous = false;
  String? _selectedGender;
  String? _selectedEducation;
  String? _selectedMaritalStatus;

  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  final List<String> _educationOptions = ['High School', 'Associate Degree', "Bachelor's Degree", "Master's Degree", 'PhD', 'Other'];
  final List<String> _maritalStatusOptions = ['Single', 'Married', 'In a relationship', 'Divorced', 'Widowed'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<UserDataProvider>(context, listen: false).updateUserDetails(
        name: _isAnonymous ? 'Anonymous' : _nameController.text.trim(),
        age: _ageController.text.trim(),
        gender: _selectedGender!,
        education: _selectedEducation!,
        maritalStatus: _selectedMaritalStatus!,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tell Us About Yourself', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionTitle("Let's Get Acquainted"),
                    const SizedBox(height: 16),
                    _buildNameField(),
                    _buildAnonymousSwitch(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Personal Details"),
                    Text(
                      "This helps us personalize your experience.",
                      style: GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    _buildAgeField(),
                    const SizedBox(height: 20),
                    _buildGenderChips(),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      label: 'Highest Education',
                      value: _selectedEducation,
                      items: _educationOptions,
                      onChanged: (value) => setState(() => _selectedEducation = value),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown(
                      label: 'Marital Status',
                      value: _selectedMaritalStatus,
                      items: _maritalStatusOptions,
                      onChanged: (value) => setState(() => _selectedMaritalStatus = value),
                    ),
                    const SizedBox(height: 20),
                  ]
                  // --- THIS IS THE FIX ---
                  // The .animate() call is now on the list of children, not the Column.
                  .animate(interval: 80.ms)
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2),
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.teal.shade700));
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      enabled: !_isAnonymous,
      decoration: _inputDecoration(labelText: 'Name', filled: _isAnonymous),
      validator: (value) {
        if (!_isAnonymous && (value == null || value.trim().isEmpty)) {
          return 'Please enter your name, or select anonymous';
        }
        return null;
      },
    );
  }

  Widget _buildAnonymousSwitch() {
    return SwitchListTile(
      title: Text('Remain Anonymous', style: GoogleFonts.lato()),
      value: _isAnonymous,
      onChanged: (bool value) {
        setState(() {
          _isAnonymous = value;
          if (_isAnonymous) _nameController.clear();
        });
      },
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      controller: _ageController,
      decoration: _inputDecoration(labelText: 'Age'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your age';
        final age = int.tryParse(value);
        if (age == null) return 'Please enter a valid number';
        if (age < 13) return 'You must be at least 13 years old';
        return null;
      },
    );
  }
  
  Widget _buildGenderChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: GoogleFonts.lato(color: Colors.grey.shade700, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _genderOptions.map((gender) {
            final isSelected = _selectedGender == gender;
            return ChoiceChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (selected) => setState(() {
                if(selected) _selectedGender = gender;
              }),
              selectedColor: Colors.teal.withOpacity(0.2),
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.teal.shade800 : Colors.black87,
              ),
            );
          }).toList(),
        ),
        if (_selectedGender == null)
          FormField(
            builder: (FormFieldState<String> state) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(state.errorText ?? '', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              );
            },
            validator: (_) => _selectedGender == null ? 'Please select a gender option.' : null,
          ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(labelText: label),
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Continue', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _inputDecoration({required String labelText, bool filled = false}) {
    return InputDecoration(
      labelText: labelText,
      filled: filled,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
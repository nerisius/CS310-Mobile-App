import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_spacing.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _selectedGender;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dobController.text = "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        title: const Text(
          "Sign Up",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 20),
                Image.asset(
                  'lib/utils/circular_logo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),

                Text(
                  'Create your account and start your journey with us! 🪶',
                  textAlign: TextAlign.center,
                ),

                AppSpacing.fieldSpacing,

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Username is required" : null,
                ),

                AppSpacing.fieldSpacing,

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Email is required" : null,
                ),

                AppSpacing.fieldSpacing,

                // Date of Birth
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
                  onTap: _selectDate,
                  validator: (value) =>
                  value == null || value.isEmpty ? "Date of birth required" : null,
                ),

                AppSpacing.fieldSpacing,

                // Gender dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "male", child: Text("Male")),
                    DropdownMenuItem(value: "female", child: Text("Female")),
                    DropdownMenuItem(value: "other", child: Text("Other")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Please select a gender" : null,
                ),

                AppSpacing.fieldSpacing,

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textFieldBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? "Password is required" : null,
                ),

                AppSpacing.buttonSpacing,

                // Sign Up button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                                "Please fill in all required fields correctly."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: const Text("Create Account", style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

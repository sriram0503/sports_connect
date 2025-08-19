import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class SignUP extends StatelessWidget {
  const SignUP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _sportsList = [
    "Football",
    "Cricket",
    "Hockey",
    "Basketball",
    "Tennis",
    "Badminton",
    "Volleyball",
    "Running",
    "Swimming",
  ];
  final List<String> _selectedSports = [];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!passwordConfirmed()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userId = userCredential.user?.uid;

      if (userId != null) {
        await addUserDetails(
          userId,
          firstNameController.text.trim(),
          lastNameController.text.trim(),
          int.parse(ageController.text.trim()),
          int.parse(heightController.text.trim()),
          int.parse(weightController.text.trim()),
          addressController.text.trim(),
          int.parse(phoneController.text.trim()),
          emailController.text.trim(),
          aboutController.text.trim(),
          _selectedGender!,
          _selectedSports,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful')),
        );

        // Clear form after successful submission
        _formKey.currentState!.reset();
        _selectedSports.clear();
        setState(() {
          _selectedGender = 'Male';
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during sign up';
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addUserDetails(
      String userId,
      String firstName,
      String lastName,
      int age,
      int height,
      int weight,
      String address,
      int phoneNumber,
      String email,
      String bio,
      String gender,
      List<String> sportsInterests,
      ) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(userId).set({
        'first name': firstName,
        'last name': lastName,
        'age': age,
        'height': height,
        'weight': weight,
        'address': address,
        'phone number': phoneNumber,
        'email': email,
        'bio': bio,
        'gender': gender,
        'sports_interests': sportsInterests,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding user details: $e');
      rethrow;
    }
  }

  bool passwordConfirmed() {
    return passwordController.text.trim() == confirmPasswordController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sports Connect - Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            shadowColor: Colors.blueAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Firebase Status Indicator
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('user').snapshots(),
                      builder: (context, snapshot) {
                        String status = "Firestore: Connecting...";
                        Color statusColor = Colors.orange;

                        if (snapshot.hasError) {
                          status = "Firestore: Error";
                          statusColor = Colors.red;
                        } else if (snapshot.connectionState == ConnectionState.waiting) {
                          status = "Firestore: Connecting...";
                          statusColor = Colors.orange;
                        } else if (snapshot.hasData) {
                          status = "Firestore: Connected (${snapshot.data!.docs.length} users)";
                          statusColor = Colors.green;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud, color: statusColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "First Name",
                            icon: Icons.person_outline,
                            controller: firstNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter first name';
                              } else if (value.length < 3) {
                                return 'Min 3 characters';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: "Last Name",
                            icon: Icons.person_outline,
                            controller: lastNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter last name';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    /// Email
                    _buildTextField(
                      label: "Email",
                      icon: Icons.email_outlined,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        return value == null || !emailRegex.hasMatch(value)
                            ? 'Enter a valid email'
                            : null;
                      },
                    ),
                    const SizedBox(height: 15),

                    /// Phone
                    _buildTextField(
                      label: "Phone Number",
                      icon: Icons.phone_android_outlined,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        final phoneRegex = RegExp(r'^\d{10}$');
                        return value == null || !phoneRegex.hasMatch(value)
                            ? 'Enter valid 10-digit number'
                            : null;
                      },
                    ),
                    const SizedBox(height: 15),

                    /// Gender + Age Row
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            items: ['Male', 'Female', 'Other']
                                .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedGender = value),
                            decoration: _inputDecoration("Gender", Icons.person),
                            validator: (value) =>
                            value == null ? 'Select gender' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: "Age",
                            icon: Icons.calendar_today,
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter age';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 1 || age > 120) {
                                return 'Enter valid age';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    /// Height + Weight Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Height (cm)",
                            icon: Icons.height,
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter height';
                              }
                              final height = int.tryParse(value);
                              if (height == null || height < 50 || height > 250) {
                                return 'Enter valid height';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: "Weight (kg)",
                            icon: Icons.monitor_weight,
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter weight';
                              }
                              final weight = int.tryParse(value);
                              if (weight == null || weight < 5 || weight > 300) {
                                return 'Enter valid weight';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    /// Address
                    TextFormField(
                      controller: addressController,
                      decoration: _inputDecoration("Address", Icons.location_on_outlined),
                      maxLines: 3,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter address' : null,
                    ),
                    const SizedBox(height: 15),

                    /// About Yourself
                    TextFormField(
                      controller: aboutController,
                      decoration: _inputDecoration("Tell about yourself", Icons.info_outline),
                      maxLines: 4,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter details' : null,
                    ),
                    const SizedBox(height: 15),

                    /// Sports Interest Chips
                    const Text(
                      "Sports Interests",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _sportsList.map((sport) {
                        final isSelected = _selectedSports.contains(sport);
                        return FilterChip(
                          label: Text(sport),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSports.add(sport);
                              } else {
                                _selectedSports.remove(sport);
                              }
                            });
                          },
                          selectedColor: Colors.blue.shade200,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    /// Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration("Password", Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        final regex = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*()_+{}|:<>?~]).{8,}$');
                        return value == null || !regex.hasMatch(value)
                            ? 'Password must be 8+ chars, include caps, number & special char'
                            : null;
                      },
                    ),
                    const SizedBox(height: 15),

                    /// Confirm Password
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: _inputDecoration("Confirm Password", Icons.lock_outline)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 25),

                    /// Sign Up Button
                    ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.person_add_alt_1, size: 22),
                      label: _isLoading
                          ? const Text('Creating Account...')
                          : const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                      ),
                    ),
                    const SizedBox(height: 15),

                    /// Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ",
                            style: TextStyle(fontSize: 15)),
                        TextButton(
                          onPressed: () {
                            // Navigate to Login Page
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[700]),
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }
}
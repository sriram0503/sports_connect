import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sports_c/user/search/location.dart';
import 'package:sports_c/Reusable/color.dart';

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

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
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
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();

  // Player-specific controllers
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // Coach-specific controllers
  final TextEditingController minFeeController = TextEditingController();
  final TextEditingController maxFeeController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  LatLng? _selectedLocation;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender = 'Male';
  String? _selectedRole = 'Player';
  bool _isLoading = false;

  // Coach-specific state variables
  List<String> _selectedAvailability = [];
  List<String> _selectedTimeSlots = [];

  // Player-specific state variables
  String? _selectedSport;
  String? _selectedPosition;

  // Sports lists for players
  final List<String> _playerSportsList = [
    "Cricket",
    "Volleyball",
    "Basketball",
    "Athletics"
  ];

  // Position options for each sport
  final Map<String, List<String>> _sportPositions = {
    "Cricket": ["Batsman", "Bowler", "All-rounder", "Wicket-keeper"],
    "Volleyball": ["Middle Blocker", "Outside Hitter", "Opposite Hitter", "Setter", "Libero"],
    "Basketball": ["Point Guard", "Shooting Guard", "Small Forward", "Power Forward", "Center"],
    "Athletics": ["Sprinter", "Long Distance", "Jumper", "Thrower"],
  };

  // Availability options for coaches
  final List<String> _availabilityOptions = [
    'Weekdays',
    'Weekends',
  ];

  // Time slot options for coaches
  final List<String> _timeSlotOptions = [
    'Morning',
    'Afternoon',
    'Evening',
  ];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    aboutController.dispose();
    locationCtrl.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    minFeeController.dispose();
    maxFeeController.dispose();
    experienceController.dispose();
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
          userId: userId,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          phoneNumber: int.parse(phoneController.text.trim()),
          email: emailController.text.trim(),
          bio: aboutController.text.trim(),
          gender: _selectedGender!,
          role: _selectedRole!,
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
          locationAddress: locationCtrl.text.trim(),
          // Player-specific data
          age: _selectedRole == 'Player' ? int.tryParse(ageController.text.trim()) : null,
          height: _selectedRole == 'Player' ? int.tryParse(heightController.text.trim()) : null,
          weight: _selectedRole == 'Player' ? int.tryParse(weightController.text.trim()) : null,
          sport: _selectedRole == 'Player' ? _selectedSport : null,
          position: _selectedRole == 'Player' ? _selectedPosition : null,
          // Coach-specific data
          minFee: _selectedRole == 'Coach' ? int.tryParse(minFeeController.text.trim()) : null,
          maxFee: _selectedRole == 'Coach' ? int.tryParse(maxFeeController.text.trim()) : null,
          availability: _selectedRole == 'Coach' ? _selectedAvailability : null,
          timeSlots: _selectedRole == 'Coach' ? _selectedTimeSlots : null,
          experience: _selectedRole == 'Coach' ? int.tryParse(experienceController.text.trim()) : null,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign Up Successful')),
        );

        // Clear form after successful submission
        _formKey.currentState!.reset();
        _selectedAvailability.clear();
        _selectedTimeSlots.clear();
        setState(() {
          _selectedGender = 'Male';
          _selectedRole = 'Player';
          _selectedSport = null;
          _selectedPosition = null;
          _selectedLocation = null;
          locationCtrl.clear();
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

  Future<void> addUserDetails({
    required String userId,
    required String firstName,
    required String lastName,
    required int phoneNumber,
    required String email,
    required String bio,
    required String gender,
    required String role,
    double? latitude,
    double? longitude,
    String? locationAddress,
    // Player-specific parameters
    int? age,
    int? height,
    int? weight,
    String? sport,
    String? position,
    // Coach-specific parameters
    int? minFee,
    int? maxFee,
    List<String>? availability,
    List<String>? timeSlots,
    int? experience,
  }) async {
    try {
      Map<String, dynamic> userData = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phoneNumber.toString(),
        'email': email,
        'bio': bio,
        'gender': gender,
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      };

      // Add location data if available - FIXED THIS PART
      if (latitude != null && longitude != null) {
        userData.addAll({
          'location': GeoPoint(latitude, longitude),
        });
      }

      // Add location address if available
      if (locationAddress != null && locationAddress.isNotEmpty) {
        userData['location_address'] = locationAddress;
      }

      // Add player-specific data if role is Player
      if (role == 'Player') {
        userData.addAll({
          'age': age,
          'height': height,
          'weight': weight,
          'sport': sport,
          'position': position,
        });
      }

      // Add coach-specific data if role is Coach
      if (role == 'Coach') {
        userData.addAll({
          'min_fee': minFee,
          'max_fee': maxFee,
          'availability': availability,
          'time_slots': timeSlots,
          'experience': experience,
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).set(userData);
    } catch (e) {
      print('Error adding user details: $e');
      rethrow;
    }
  }

  bool passwordConfirmed() {
    return passwordController.text.trim() == confirmPasswordController.text.trim();
  }

  // Build coach-specific fields
  Widget _buildCoachFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text(
          "Coach Information",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Fee Range
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: "Minimum Fee (\$)",
                icon: Icons.attach_money,
                controller: minFeeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedRole == 'Coach' && (value == null || value.isEmpty)) {
                    return 'Enter minimum fee';
                  }
                  final fee = int.tryParse(value ?? '');
                  if (_selectedRole == 'Coach' && (fee == null || fee < 0)) {
                    return 'Enter valid fee';
                  }
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                label: "Maximum Fee (\$)",
                icon: Icons.attach_money,
                controller: maxFeeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedRole == 'Coach' && (value == null || value.isEmpty)) {
                    return 'Enter maximum fee';
                  }
                  final fee = int.tryParse(value ?? '');
                  final minFee = int.tryParse(minFeeController.text);
                  if (_selectedRole == 'Coach' && (fee == null || fee < 0)) {
                    return 'Enter valid fee';
                  }
                  if (_selectedRole == 'Coach' && minFee != null && fee != null && fee < minFee) {
                    return 'Max fee must be >= min fee';
                  }
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Years of Experience
        _buildTextField(
          label: "Years of Experience",
          icon: Icons.work_outline,
          controller: experienceController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_selectedRole == 'Coach' && (value == null || value.isEmpty)) {
              return 'Enter years of experience';
            }
            final exp = int.tryParse(value ?? '');
            if (_selectedRole == 'Coach' && (exp == null || exp < 0 || exp > 50)) {
              return 'Enter valid experience (0-50)';
            }
            return null;
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 15),

        // Availability
        const Text(
          "Availability",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availabilityOptions.map((option) {
            final isSelected = _selectedAvailability.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAvailability.add(option);
                  } else {
                    _selectedAvailability.remove(option);
                  }
                });
              },
              selectedColor: Colors.blue.shade200,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 15),

        // Time Slots
        const Text(
          "Preferred Time Slots",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _timeSlotOptions.map((slot) {
            final isSelected = _selectedTimeSlots.contains(slot);
            return FilterChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTimeSlots.add(slot);
                  } else {
                    _selectedTimeSlots.remove(slot);
                  }
                });
              },
              selectedColor: Colors.blue.shade200,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build player-specific fields
  Widget _buildPlayerFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text(
          "Player Information",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Age, Height, Weight Row
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: "Age",
                icon: Icons.calendar_today,
                controller: ageController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedRole == 'Player' && (value == null || value.isEmpty)) {
                    return 'Enter age';
                  }
                  final age = int.tryParse(value ?? '');
                  if (_selectedRole == 'Player' && (age == null || age < 1 || age > 120)) {
                    return 'Enter valid age (1-120)';
                  }
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                label: "Height (cm)",
                icon: Icons.height,
                controller: heightController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedRole == 'Player' && (value == null || value.isEmpty)) {
                    return 'Enter height';
                  }
                  final height = int.tryParse(value ?? '');
                  if (_selectedRole == 'Player' && (height == null || height < 50 || height > 250)) {
                    return 'Enter valid height (50-250)';
                  }
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  if (_selectedRole == 'Player' && (value == null || value.isEmpty)) {
                    return 'Enter weight';
                  }
                  final weight = int.tryParse(value ?? '');
                  if (_selectedRole == 'Player' && (weight == null || weight < 5 || weight > 300)) {
                    return 'Enter valid weight (5-300)';
                  }
                  return null;
                },
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Sport selection
        DropdownButtonFormField<String>(
          value: _selectedSport,
          decoration: _inputDecoration("Select Sport", Icons.sports),
          items: _playerSportsList
              .map((sport) => DropdownMenuItem(
            value: sport,
            child: Text(sport),
          ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedSport = value;
              _selectedPosition = null; // Reset position when sport changes
            });
          },
          validator: (value) {
            if (_selectedRole == 'Player' && (value == null || value.isEmpty)) {
              return 'Please select a sport';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),

        // Position selection
        if (_selectedSport != null && _sportPositions.containsKey(_selectedSport))
          DropdownButtonFormField<String>(
            value: _selectedPosition,
            decoration: _inputDecoration("Select Position", Icons.emoji_events),
            items: _sportPositions[_selectedSport]!
                .map((position) => DropdownMenuItem(
              value: position,
              child: Text(position),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedPosition = value;
              });
            },
            validator: (value) {
              if (_selectedRole == 'Player' && (value == null || value.isEmpty)) {
                return 'Please select a position';
              }
              return null;
            },
          ),
      ],
    );
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

                    /// Gender (for both players and coaches)
                    DropdownButtonFormField<String>(
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
                    const SizedBox(height: 15),

                    /// Role Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: ['Player', 'Coach', 'General']
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          _selectedSport = null;
                          _selectedPosition = null;
                        });
                      },
                      decoration: _inputDecoration("Role", Icons.group),
                      validator: (value) =>
                      value == null ? 'Select role' : null,
                    ),
                    const SizedBox(height: 15),

                    // Show coach-specific fields if Coach role is selected
                    if (_selectedRole == 'Coach') _buildCoachFields(),

                    // Show player-specific fields if Player role is selected
                    if (_selectedRole == 'Player') _buildPlayerFields(),
                    const SizedBox(height: 15),

                    /// Location
                    TextFormField(
                      controller: locationCtrl,
                      readOnly: true,
                      decoration: _inputDecoration('Location',Icons.location_on).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.location_on, color: appSecondaryColor),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LocationPickerScreen(),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                locationCtrl.text = result['address'];
                                _selectedLocation = result['location'];
                              });
                            }
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationPickerScreen(),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            locationCtrl.text = result['address'];
                            _selectedLocation = result['location'];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 15),

                    /// About Yourself (for both players and coaches)
                    TextFormField(
                      controller: aboutController,
                      decoration: _inputDecoration(
                          "Tell about yourself", Icons.info_outline),
                      maxLines: 4,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter details' : null,
                    ),
                    const SizedBox(height: 20),

                    /// Password
                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration("Password", Icons.lock_outline)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
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
                      decoration: _inputDecoration(
                          "Confirm Password", Icons.lock_outline)
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                            Navigator.pop(context);
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
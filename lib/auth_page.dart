import 'package:flutter/material.dart';
import 'package:grocer/class/api_credentials.dart';
import 'package:grocer/grocer_app.dart';

class GrocerAuthPage extends StatefulWidget {
  final ApiCredentials apiCredentials;
  const GrocerAuthPage({super.key, required this.apiCredentials});

  @override
  State<GrocerAuthPage> createState() => _GrocerAuthPageState();
}

class _GrocerAuthPageState extends State<GrocerAuthPage> {
  bool isLogin = true;

  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isLogin ? "Welcome Back!" : "Create Account",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: isLogin
            ? LoginView(
                apiCredentials: widget.apiCredentials,
                onToggle: toggleView,
              )
            : SignUpView(
                apiCredentials: widget.apiCredentials,
                onToggle: toggleView,
              ),
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  final ApiCredentials apiCredentials;
  final VoidCallback onToggle;
  const LoginView({
    super.key,
    required this.apiCredentials,
    required this.onToggle,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String phone = '';
  String password = '';

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              GroceryScreen(credentials: widget.apiCredentials),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputContainer(
                label: 'Phone Number',
                hint: '+923... (required)',
                icon: Icons.phone_android_outlined,
                onSaved: (value) => phone = value ?? '',
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Phone is required' : null,
              ),
              const SizedBox(height: 20),
              _buildInputContainer(
                label: 'Password',
                hint: '******',
                icon: Icons.lock_outline,
                onSaved: (value) => password = value ?? '',
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 30),

              _buildActionButton(
                label: 'Login',
                onPressed: _handleLogin,
                isPrimary: true,
              ),
              const SizedBox(height: 20),

              _buildToggleButton(
                label: "Don't have an account? Sign Up",
                onPressed: widget.onToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpView extends StatefulWidget {
  final ApiCredentials apiCredentials;
  final VoidCallback onToggle;
  const SignUpView({
    super.key,
    required this.apiCredentials,
    required this.onToggle,
  });

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _email = '';
  String _street = '';
  String _street2 = '';
  String _city = '';
  int _stateId = 0;
  String _zip = '';
  int _countryId = 0;

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userData = {
        "name": _name,
        "phone": _phone,
        "email": _email,
        "street": _street,
        "street2": _street2,
        "city": _city,
        "state_id": _stateId,
        "zip": _zip,
        "country_id": _countryId,
      };

      debugPrint("Signup Data: $userData");
      widget.onToggle();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created! Please log in',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputContainer(
                label: 'Full Name',
                hint: 'John Doe',
                icon: Icons.person_outline,
                onSaved: (value) => _name = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                label: 'Phone (Primary)',
                hint: '+92...',
                icon: Icons.phone_android_outlined,
                onSaved: (value) => _phone = value ?? '',
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Phone is vital' : null,
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                label: 'Email',
                hint: 'john@example.com',
                icon: Icons.email_outlined,
                onSaved: (value) => _email = value ?? '',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 30),

              const Text(
                'Delivery Address Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),

              _buildInputContainer(
                label: 'Street Line 1',
                hint: '123 Main Street',
                icon: Icons.home_outlined,
                onSaved: (value) => _street = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Street 1 is required' : null,
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                label: 'Street Line 2 (Optional)',
                hint: 'Apartment 4B',
                icon: Icons.apartment_outlined,
                onSaved: (value) => _street2 = value ?? '',
                isOptional: true,
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                label: 'City',
                hint: 'Lahore',
                icon: Icons.location_city_outlined,
                onSaved: (value) => _city = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildInputContainer(
                      label: 'Zip Code',
                      hint: '54000',
                      icon: Icons.pin_drop_outlined,
                      onSaved: (value) => _zip = value ?? '',
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Zip is required' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildInputContainer(
                      label: 'State ID',
                      hint: '5',
                      icon: Icons.numbers,
                      onSaved: (value) =>
                          _stateId = int.tryParse(value ?? '0') ?? 0,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'State ID is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildInputContainer(
                label: 'Country ID',
                hint: '1',
                icon: Icons.flag_outlined,
                onSaved: (value) =>
                    _countryId = int.tryParse(value ?? '0') ?? 0,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Country ID is required' : null,
              ),

              const SizedBox(height: 30),

              _buildActionButton(
                label: 'Create Account',
                onPressed: _handleSignup,
                isPrimary: true,
              ),
              const SizedBox(height: 20),

              _buildToggleButton(
                label: "Already have an account? Log In",
                onPressed: widget.onToggle,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInputContainer({
  required String label,
  required String hint,
  required IconData icon,
  required FormFieldSetter<String> onSaved,
  FormFieldValidator<String>? validator,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  bool isOptional = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        onSaved: onSaved,
        validator: isOptional ? null : validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.amber),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.amber, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
      ),
    ],
  );
}

Widget _buildActionButton({
  required String label,
  required VoidCallback onPressed,
  required bool isPrimary,
}) {
  return SizedBox(
    height: 55,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? Colors.amber
            : Colors.amber.withValues(alpha: 0.1),
        elevation: isPrimary ? 3 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: Colors.amber, width: 1.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isPrimary ? Colors.black87 : Colors.amber,
        ),
      ),
    ),
  );
}

Widget _buildToggleButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return TextButton(
    onPressed: onPressed,
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
    ),
  );
}

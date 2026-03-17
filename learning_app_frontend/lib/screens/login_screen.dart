import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.loading,
  });

  final Future<void> Function(String username, String password) onLogin;
  final Future<void> Function(String username, String email, String password) onRegister;
  final bool loading;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_registerMode) {
      await widget.onRegister(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      return;
    }

    await widget.onLogin(
      _usernameController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6E7CB), Color(0xFFE6F0EB), Color(0xFFD5E4F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Learning Tasks',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF203A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _registerMode
                              ? 'Create an account, then explore the API-driven task flow.'
                              : 'Sign in and watch Flutter talk to Django through JSON APIs.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? 'Enter a username' : null,
                        ),
                        const SizedBox(height: 16),
                        if (_registerMode) ...[
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a password';
                            }
                            if (_registerMode && value.length < 6) {
                              return 'Use at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: widget.loading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(widget.loading
                                ? 'Please wait...'
                                : _registerMode
                                    ? 'Create Account'
                                    : 'Login'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: widget.loading
                              ? null
                              : () {
                                  setState(() {
                                    _registerMode = !_registerMode;
                                  });
                                },
                          child: Text(
                            _registerMode
                                ? 'Already have an account? Login'
                                : 'Need an account? Register',
                          ),
                        ),
                      ],
                    ),
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

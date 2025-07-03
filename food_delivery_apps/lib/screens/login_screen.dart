import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService()
          .login(_emailController.text, _passwordController.text);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = 'Login gagal';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/Logo.png"),
                          fit: BoxFit.contain)),
                ),
                SizedBox(height: 32),
                Text('Masuk',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gmail",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: "Masukkan Email",
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF9038FF))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey))),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                          hintText: "Masukkan Password",
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF9038FF))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey)),
                          suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              color: Colors.grey,
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              })),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun?"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF9038FF),
                          color: Color(0xFF9038FF),
                        ),
                      ),
                    )
                  ],
                ),
                Spacer(),
                if (_error != null) ...[
                  SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Colors.red)),
                ],
                SizedBox(height: 16),
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF9038FF),
                            foregroundColor: Colors.white,
                            minimumSize: Size(200, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
              ],
            ))
          ],
        ),
      ),
    ));
  }
}

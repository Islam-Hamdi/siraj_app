import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../services/auth_service.dart';

class AuthShell extends ConsumerStatefulWidget {
  const AuthShell({super.key});

  @override
  ConsumerState<AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends ConsumerState<AuthShell>
    with TickerProviderStateMixin {
  late final TabController _tab;
  final _loginKey = GlobalKey<FormState>();
  final _signupKey = GlobalKey<FormState>();

  // Login
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  // Sign-up
  final _name = TextEditingController();
  final _signupEmail = TextEditingController();
  final _password = TextEditingController();
  final _confirmPass = TextEditingController();

  bool _busy = false; // one global flag is enough for both forms

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _name.dispose();
    _signupEmail.dispose();
    _password.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────── UI

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SirajColors.beige50,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.lightbulb_outline,
                    color: SirajColors.accentGold, size: 80),
                const SizedBox(height: 16),
                Text('مرحباً بك في سراج',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: SirajColors.sirajBrown900,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Your spiritual journey begins here',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: SirajColors.sirajBrown700)),
                const SizedBox(height: 40),
                _buildTabs(context),
                const SizedBox(height: 24),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [_loginForm(), _signupForm()],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ───────────────────────────────────────── Tabs

  Widget _buildTabs(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: SirajColors.beige100,
            borderRadius: BorderRadius.circular(12)),
        child: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: SirajColors.sirajBrown700,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
              color: SirajColors.accentGold,
              borderRadius: BorderRadius.circular(12)),
          tabs: const [
            Tab(text: 'تسجيل الدخول'),
            Tab(text: 'إنشاء حساب'),
          ],
        ),
      );

  // ───────────────────────────────────────── Login

  Widget _loginForm() => Form(
        key: _loginKey,
        child: Column(
          children: [
            _field(_loginEmail,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _field(_loginPassword,
                label: 'كلمة المرور', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 24),
            _button('تسجيل الدخول', _handleLogin),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () {},
                child: const Text('نسيت كلمة المرور؟',
                    style: TextStyle(color: SirajColors.sirajBrown700))),
          ],
        ),
      );

  // ───────────────────────────────────────── Sign-up

  Widget _signupForm() => Form(
        key: _signupKey,
        child: Column(
          children: [
            _field(_name, label: 'الاسم الكامل', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _field(_signupEmail,
                label: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _field(_password,
                label: 'كلمة المرور', icon: Icons.lock_outline, obscure: true),
            const SizedBox(height: 16),
            _field(_confirmPass,
                label: 'تأكيد كلمة المرور',
                icon: Icons.lock_outline,
                obscure: true),
            const SizedBox(height: 24),
            _button('إنشاء حساب', _handleSignup),
          ],
        ),
      );

  // ───────────────────────────────────────── Widgets

  Widget _field(TextEditingController c,
          {required String label,
          required IconData icon,
          bool obscure = false,
          TextInputType? keyboard}) =>
      TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        style: const TextStyle(color: SirajColors.sirajBrown900),
        cursorColor: SirajColors.accentGold,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: SirajColors.sirajBrown700),
          prefixIcon: Icon(icon, color: SirajColors.sirajBrown700),
          filled: true,
          fillColor: SirajColors.beige100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: SirajColors.accentGold, width: 2)),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
      );

  Widget _button(String text, Future<void> Function() onTap) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _busy ? null : () => onTap(),
          style: ElevatedButton.styleFrom(
              backgroundColor: SirajColors.sirajBrown700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
          child: _busy
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2)
              : Text(text,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );

  // ───────────────────────────────────────── Logic

  Future<void> _handleLogin() async {
    if (!_loginKey.currentState!.validate()) return;
    setState(() => _busy = true);

    final auth = ref.read(authServiceProvider);
    try {
      await auth.signInWithEmailAndPassword(
        email: _loginEmail.text.trim(),
        password: _loginPassword.text.trim(),
      );

      if (mounted) context.go('/main');
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupKey.currentState!.validate()) return;

    if (_password.text.trim() != _confirmPass.text.trim()) {
      _show('كلمات المرور غير متطابقة');
      return;
    }

    setState(() => _busy = true);

    final auth = ref.read(authServiceProvider);
    try {
      await auth.createUserWithEmailAndPassword(
        email: _signupEmail.text.trim(),
        password: _password.text.trim(),
        displayName: _name.text.trim(),
      );

      if (mounted) context.go('/main');
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _show(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

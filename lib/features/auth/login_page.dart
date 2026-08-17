import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Future<void> Function() onLoggedIn;
  final Future<bool> Function(String username, String password)? authenticate;

  const LoginPage({
    super.key,
    required this.onLoggedIn,
    this.authenticate,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<bool> _authenticate(String username, String password) {
    final authenticate = widget.authenticate;
    return authenticate == null
        ? _auth.login(username, password)
        : authenticate(username, password);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await _authenticate(_username.text.trim(), _password.text);
    if (!mounted) return;

    if (ok) {
      await widget.onLoggedIn();
      return;
    }

    setState(() {
      _loading = false;
      _error = 'Usuário ou senha inválidos.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 26),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary.withOpacity(.16), scheme.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(.12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: scheme.primary.withOpacity(.28)),
                            ),
                            child: Icon(Icons.live_tv_rounded, size: 30, color: scheme.primary),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'LIVE STUDIO ASR',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: .9),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Central de comando para transmissões',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 8, color: scheme.primary),
                                const SizedBox(width: 7),
                                Text(
                                  'AMBIENTE LOCAL',
                                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(width < 380 ? 20 : 28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Entrar no estúdio', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 6),
                            Text('Use suas credenciais para continuar.', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _username,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username, AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Usuário',
                                hintText: 'Digite seu usuário',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) => value == null || value.trim().isEmpty ? 'Informe o usuário' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                hintText: 'Digite sua senha',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                                ),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Informe a senha' : null,
                              onFieldSubmitted: (_) => _login(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: scheme.error.withOpacity(.28)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.error_outline_rounded, size: 19, color: scheme.onErrorContainer),
                                    const SizedBox(width: 9),
                                    Expanded(child: Text(_error!, style: TextStyle(color: scheme.onErrorContainer, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: _loading ? null : _login,
                                icon: _loading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.login_rounded),
                                label: Text(_loading ? 'Validando acesso...' : 'Entrar'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shield_outlined, size: 15, color: scheme.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text('Acesso local protegido', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

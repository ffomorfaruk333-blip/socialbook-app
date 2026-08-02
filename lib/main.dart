import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl =
    'https://xsxrcrbcxckicskwppmb.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_0xGXFjbz404LyFWwWo6kzw_wHUgY0NT';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const SocialBookApp());
}

class SocialBookApp extends StatelessWidget {
  const SocialBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Book',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151A21),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.deepPurpleAccent,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(
        context,
        'Email এবং Password দুটোই দিতে হবে।',
        isError: true,
      );
      return;
    }

    if (!email.contains('@')) {
      showMessage(
        context,
        'সঠিক Email দিন।',
        isError: true,
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      showMessage(
        context,
        'Login সফল হয়েছে!',
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      showMessage(
        context,
        e.message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(
        context,
        'Login করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  const Icon(
                    Icons.people_alt_rounded,
                    size: 82,
                    color: Colors.deepPurpleAccent,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Social Book',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    onSubmitted: (_) => login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SignUpPage(),
                              ),
                            );
                          },
                    child: const Text(
                      "Don't have an account? Sign Up",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SIGN UP PAGE
// ============================================================

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;

    if (name.isEmpty) {
      showMessage(
        context,
        'আপনার নাম লিখুন।',
        isError: true,
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      showMessage(
        context,
        'সঠিক Email লিখুন।',
        isError: true,
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        context,
        'Password কমপক্ষে ৬ অক্ষরের হতে হবে।',
        isError: true,
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage(
        context,
        'দুইটি Password একই নয়।',
        isError: true,
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response =
          await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      if (!mounted) return;

      if (response.session != null) {
        showMessage(
          context,
          'Account সফলভাবে তৈরি হয়েছে!',
        );

        Navigator.pop(context);
      } else {
        showMessage(
          context,
          'Account তৈরি হয়েছে। Email খুলে confirmation করুন।',
        );

        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      showMessage(
        context,
        e.message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(
        context,
        'Account তৈরি করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 72,
                    color: Colors.deepPurpleAccent,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Create Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Join Social Book today',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextField(
                    controller: nameController,
                    textInputAction:
                        TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon:
                          Icon(Icons.person_outline),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon:
                          Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction:
                        TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller:
                        confirmPasswordController,
                    obscureText:
                        obscureConfirmPassword,
                    onSubmitted: (_) => signUp(),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                                !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed:
                          loading ? null : signUp,
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'Already have an account? Login',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;

      showMessage(
        context,
        'Logout সফল হয়েছে।',
      );
    } on AuthException catch (e) {
      if (!context.mounted) return;

      showMessage(
        context,
        e.message,
        isError: true,
      );
    } catch (_) {
      if (!context.mounted) return;

      showMessage(
        context,
        'Logout করতে সমস্যা হয়েছে।',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user =
        Supabase.instance.client.auth.currentUser;

    final email = user?.email ?? 'User';

    final fullName =
        user?.userMetadata?['full_name']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social Book',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                      'আপনি কি সত্যিই Logout করতে চান?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          await logout(context);
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(
            const Duration(milliseconds: 500),
          );
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF512DA8),
                    Color(0xFF7E57C2),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    fullName == null ||
                            fullName.isEmpty
                        ? 'Welcome!'
                        : 'Welcome, $fullName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Social Book',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  fullName == null ||
                          fullName.isEmpty
                      ? 'My Profile'
                      : fullName,
                ),
                subtitle: Text(email),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.public,
                  color: Colors.deepPurpleAccent,
                ),
                title: const Text(
                  'Welcome to Social Book',
                ),
                subtitle: const Text(
                  'Your account is connected with Supabase.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MESSAGE HELPER
// ============================================================

void showMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? Colors.red.shade700 : null,
      ),
    );
}

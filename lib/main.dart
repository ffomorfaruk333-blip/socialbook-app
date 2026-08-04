// ============================================================
// SOCIALBOOK — COMPLETE MAIN.DART
// Supabase-backed Flutter app
// Replace your existing lib/main.dart with this file.
// ============================================================

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
    publishableKey: supabasePublishableKey,
  );

  runApp(const SocialBookApp());
}

final supabase = Supabase.instance.client;

class SocialBookApp extends StatelessWidget {
  const SocialBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SocialBook',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (supabase.auth.currentSession != null) {
      return const MainNavigation();
    }

    return const LoginPage();
  }
}

InputDecoration inputDecoration(
  String hint,
  IconData icon,
) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: const Color(0xFF151820),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

void showAppMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

// ============================================================
// LOGIN
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
  bool hidden = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showAppMessage(context, 'Email এবং Password দিন');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (mounted) showAppMessage(context, e.message);
    } catch (_) {
      if (mounted) {
        showAppMessage(context, 'Login করতে সমস্যা হয়েছে');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  size: 90,
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SocialBook',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect. Share. Discover.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      inputDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: hidden,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon:
                        const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hidden = !hidden);
                      },
                      icon: Icon(
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF151820),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text('Create a new account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SIGN UP
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
  final confirmController = TextEditingController();

  bool loading = false;
  bool hiddenPassword = true;
  bool hiddenConfirm = true;

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      showAppMessage(context, 'সবগুলো তথ্য পূরণ করুন');
      return;
    }

    if (password.length < 6) {
      showAppMessage(
        context,
        'Password কমপক্ষে ৬ অক্ষরের হতে হবে',
      );
      return;
    }

    if (password != confirm) {
      showAppMessage(context, 'Password মিলছে না');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      if (!mounted) return;

      if (result.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(),
          ),
          (_) => false,
        );
      } else {
        showAppMessage(
          context,
          'Account তৈরি হয়েছে। Email confirmation করুন।',
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) showAppMessage(context, e.message);
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Sign Up করতে সমস্যা হয়েছে',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.person_add_alt_1_rounded,
                size: 80,
                color: Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 18),
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: inputDecoration(
                  'Full Name',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    inputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: hiddenPassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => hiddenPassword =
                            !hiddenPassword,
                      );
                    },
                    icon: Icon(
                      hiddenPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF151820),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmController,
                obscureText: hiddenConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon:
                      const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => hiddenConfirm =
                            !hiddenConfirm,
                      );
                    },
                    icon: Icon(
                      hiddenConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF151820),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton(
                  onPressed: loading ? null : signUp,
                  child: loading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const SearchPage(),
      CreatePostPage(
        onPublished: () {
          setState(() => currentIndex = 0);
        },
      ),
      const NotificationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        posts =
            List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        showAppMessage(
          context,
          'Post load করতে সমস্যা হয়েছে',
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String get currentName {
    final user = supabase.auth.currentUser;

    return user?.userMetadata?['full_name']
            ?.toString() ??
        user?.email?.split('@').first ??
        'SocialBook User';
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> deletePost(dynamic id) async {
    if (id == null) return;

    try {
      await supabase
          .from('posts')
          .delete()
          .eq('id', id);

      await loadPosts();

      if (mounted) {
        showAppMessage(
          context,
          'Post delete হয়েছে',
        );
      }
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Post delete করা যায়নি',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter = currentName.isNotEmpty
        ? currentName[0].toUpperCase()
        : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SocialBook',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPosts,
              child: ListView(
                padding:
                    const EdgeInsets.only(bottom: 30),
                children: [
                  const SizedBox(height: 12),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    color: const Color(0xFF12151C),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF7C4DFF),
                        child: Text(letter),
                      ),
                      title: const Text(
                        'What’s on your mind?',
                      ),
                      trailing: const Icon(
                        Icons.edit_outlined,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreatePostPage(),
                          ),
                        );
                        loadPosts();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: Text(
                          'এখনও কোনো post নেই',
                        ),
                      ),
                    ),
                  ...posts.map((post) {
                    final userId =
                        post['user_id']?.toString();
                    final myId =
                        supabase.auth.currentUser?.id;

                    final mine =
                        userId != null &&
                        myId != null &&
                        userId == myId;

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      color:
                          const Color(0xFF12151C),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor:
                                      Color(0xFF7C4DFF),
                                  child: Icon(
                                    Icons.person,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'SocialBook User',
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (mine)
                                  IconButton(
                                    onPressed: () =>
                                        deletePost(
                                      post['id'],
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color:
                                          Colors.redAccent,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              post['content']
                                      ?.toString() ??
                                  '',
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const Divider(height: 25),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceAround,
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons
                                        .favorite_border,
                                  ),
                                  label:
                                      const Text('Like'),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons
                                        .comment_outlined,
                                  ),
                                  label:
                                      const Text(
                                    'Comment',
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.share_outlined,
                                  ),
                                  label:
                                      const Text('Share'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// CREATE POST
// ============================================================

class CreatePostPage extends StatefulWidget {
  final VoidCallback? onPublished;

  const CreatePostPage({
    super.key,
    this.onPublished,
  });

  @override
  State<CreatePostPage> createState() =>
      _CreatePostPageState();
}

class _CreatePostPageState
    extends State<CreatePostPage> {
  final controller = TextEditingController();
  bool publishing = false;

  Future<void> publishPost() async {
    final text = controller.text.trim();

    if (text.isEmpty) {
      showAppMessage(context, 'Post লিখুন');
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      showAppMessage(context, 'আগে Login করুন');
      return;
    }

    setState(() => publishing = true);

    try {
      await supabase.from('posts').insert({
        'user_id': user.id,
        'content': text,
      });

      if (!mounted) return;

      controller.clear();

      showAppMessage(
        context,
        'Post সফলভাবে প্রকাশ হয়েছে 🎉',
      );

      widget.onPublished?.call();

      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (mounted) {
        showAppMessage(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Post প্রকাশ করতে সমস্যা হয়েছে',
        );
      }
    } finally {
      if (mounted) setState(() => publishing = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF12151C),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: controller,
                    expands: true,
                    maxLines: null,
                    textAlignVertical:
                        TextAlignVertical.top,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'What do you want to share?',
                      border: InputBorder.none,
                    ),
                    style:
                        const TextStyle(fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton.icon(
                  onPressed:
                      publishing ? null : publishPost,
                  icon: publishing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    publishing
                        ? 'Publishing...'
                        : 'Publish Post',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCH
// ============================================================

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          decoration: inputDecoration(
            'Search people, posts...',
            Icons.search,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const Center(
        child: Text(
          'No notifications yet',
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    final name =
        user?.userMetadata?['full_name']
                ?.toString() ??
            user?.email?.split('@').first ??
            'SocialBook User';

    final email = user?.email ?? '';

    final letter = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor:
                  const Color(0xFF7C4DFF),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              email,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            color: const Color(0xFF12151C),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () async {
                    await supabase.auth.signOut();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Creator: Omor Faruk',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

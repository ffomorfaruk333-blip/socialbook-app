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

// ============================================================
// APP
// ============================================================

class SocialBookApp extends StatelessWidget {
  const SocialBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SocialBook',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF080A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101218),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151820),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF8B5CF6),
              width: 1.5,
            ),
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
    if (supabase.auth.currentSession != null) {
      return const MainNavigation();
    }

    return const LoginPage();
  }
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
  bool hidePassword = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      message('Email এবং Password দিন');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
        (route) => false,
      );
    } on AuthException catch (e) {
      message(e.message);
    } catch (_) {
      message('Login করতে সমস্যা হয়েছে');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
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
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C4DFF),
                        Color(0xFFB388FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'SocialBook',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Connect. Share. Discover.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: loading ? null : login,
                    child: loading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
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

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignUpPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create a new account',
                    style: TextStyle(fontSize: 15),
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
  bool hidePassword = true;
  bool hideConfirm = true;

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      message('সবগুলো তথ্য পূরণ করুন');
      return;
    }

    if (password.length < 6) {
      message('Password কমপক্ষে ৬ অক্ষরের হতে হবে');
      return;
    }

    if (password != confirm) {
      message('Password মিলছে না');
      return;
    }

    setState(() => loading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      if (!mounted) return;

      if (response.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(),
          ),
          (route) => false,
        );
      } else {
        message(
          'Account তৈরি হয়েছে। Email confirmation চেক করুন।',
        );

        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      message(e.message);
    } catch (_) {
      message('Sign Up করতে সমস্যা হয়েছে');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
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
              const SizedBox(height: 15),

              const Icon(
                Icons.person_add_alt_1_rounded,
                size: 90,
                color: Color(0xFF8B5CF6),
              ),

              const SizedBox(height: 18),

              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: confirmController,
                obscureText: hideConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(
                    Icons.lock_reset_outlined,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hideConfirm = !hideConfirm;
                      });
                    },
                    icon: Icon(
                      hideConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: loading ? null : signUp,
                  child: loading
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
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

              const SizedBox(height: 10),

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

  final pages = const [
    HomePage(),
    SearchPage(),
    CreatePostPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
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
            icon: Icon(
              Icons.notifications_outlined,
            ),
            selectedIcon: Icon(
              Icons.notifications,
            ),
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
  final List<Map<String, dynamic>> posts = [
    {
      'name': 'SocialBook',
      'text': 'Welcome to SocialBook! 🎉',
      'likes': 12,
      'liked': false,
    },
    {
      'name': 'Gaming Community',
      'text':
          'Share your favorite gaming moments with everyone. 🎮',
      'likes': 8,
      'liked': false,
    },
  ];

  String get currentName {
    final user = supabase.auth.currentUser;

    return user?.userMetadata?['full_name']
            ?.toString() ??
        'SocialBook User';
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SocialBook',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
            ),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 400),
          );

          if (mounted) {
            setState(() {});
          }
        },
        child: ListView(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 30,
          ),
          children: [
            _storySection(),
            const SizedBox(height: 18),
            _createPostBox(),
            const SizedBox(height: 10),
            ...posts.map(
              (post) => _postCard(post),
            ),
          ],
        ),
      ),
    );
  }

  Widget _storySection() {
    return SizedBox(
      height: 125,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        children: [
          _story(
            'You',
            Icons.add,
            const Color(0xFF7C4DFF),
          ),
          _story(
            'Friends',
            Icons.people,
            const Color(0xFFEC4899),
          ),
          _story(
            'Gaming',
            Icons.gamepad,
            const Color(0xFF06B6D4),
          ),
          _story(
            'Music',
            Icons.music_note,
            const Color(0xFF10B981),
          ),
          _story(
            'Travel',
            Icons.flight,
            const Color(0xFFF59E0B),
          ),
          _story(
            'Sports',
            Icons.sports_soccer,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _story(
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 88,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 33,
              backgroundColor: color.withOpacity(.20),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createPostBox() {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      color: const Color(0xFF12151C),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFF7C4DFF),
              child: Text(
                currentName.isNotEmpty
                    ? currentName[0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1E27),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Text(
                    'What’s on your mind?',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(
    Map<String, dynamic> post,
  ) {
    final bool liked = post['liked'] as bool;
    final int likes = post['likes'] as int;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      color: const Color(0xFF12151C),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor:
                      Color(0xFF7C4DFF),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    post['name'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              post['text'].toString(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              '$likes likes',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),

            const Divider(height: 25),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      post['liked'] = !liked;

                      if (post['liked']) {
                        post['likes'] = likes + 1;
                      } else {
                        post['likes'] = likes - 1;
                      }
                    });
                  },
                  icon: Icon(
                    liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: liked
                        ? Colors.pink
                        : Colors.grey,
                  ),
                  label: Text(
                    'Like',
                    style: TextStyle(
                      color: liked
                          ? Colors.pink
                          : Colors.grey,
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed: _showComments,
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  label: const Text('Comment'),
                ),

                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share_outlined,
                  ),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12151C),
      builder: (_) {
        return SizedBox(
          height:
              MediaQuery.of(context).size.height * .60,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Expanded(
                  child: Center(
                    child: Text(
                      'No comments yet',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText:
                    'Search people, posts, pages...',
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 35),

            Icon(
              Icons.search_rounded,
              size: 90,
              color: Colors.grey.shade700,
            ),

            const SizedBox(height: 12),

            Text(
              'Search SocialBook',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 19,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Find people, posts and communities',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
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
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() =>
      _CreatePostPageState();
}

class _CreatePostPageState
    extends State<CreatePostPage> {
  final controller = TextEditingController();

  void publish() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('কিছু লিখুন'),
        ),
      );
      return;
    }

    controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post তৈরি হয়েছে!'),
      ),
    );
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
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF12151C),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        Color(0xFF7C4DFF),
                    child: Icon(Icons.person),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Create something new',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: controller,
              maxLines: 9,
              decoration: const InputDecoration(
                hintText:
                    'What do you want to share?',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.photo_outlined,
                    ),
                    label: const Text('Photo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.videocam_outlined,
                    ),
                    label: const Text('Video'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: publish,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Publish Post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
// NOTIFICATIONS
// ============================================================

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'Welcome to SocialBook 🎉',
      'Your account is successfully connected.',
      'Start creating your first post.',
      'Discover people and communities.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: notifications.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 6),
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF12151C),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              leading: const CircleAvatar(
                radius: 25,
                backgroundColor:
                    Color(0xFF7C4DFF),
                child: Icon(
                  Icons.notifications,
                ),
              ),
              title: Text(
                notifications[index],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Just now',
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String get name {
    final user = supabase.auth.currentUser;

    return user?.userMetadata?['full_name']
            ?.toString() ??
        'SocialBook User';
  }

  String get email {
    return supabase.auth.currentUser?.email ?? '';
  }

  Future<void> logout(
    BuildContext context,
  ) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter =
        name.isNotEmpty
            ? name[0].toUpperCase()
            : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),

          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8B5CF6),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor:
                    const Color(0xFF7C4DFF),
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              email,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              _stat('Posts', '0'),
              _stat('Friends', '0'),
              _stat('Following', '0'),
            ],
          ),

          const SizedBox(height: 30),

          Card(
            color: const Color(0xFF12151C),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                  ),
                  title: const Text(
                    'Edit Profile',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(
                    Icons.bookmark_outline,
                  ),
                  title: const Text(
                    'Saved Posts',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: () {},
                ),

                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                  ),
                  title: const Text(
                    'Settings',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
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
                  onTap: () => logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    String title,
    String value,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

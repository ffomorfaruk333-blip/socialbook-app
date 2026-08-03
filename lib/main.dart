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
        brightness: Brightness.dark,
        useMaterial3: true,
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
// COMMON INPUT
// ============================================================

InputDecoration inputStyle(
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
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool hidden = true;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> login() async {
    final e = email.text.trim();
    final p = password.text;

    if (e.isEmpty || p.isEmpty) {
      showMessage('Email এবং Password দিন');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: e,
        password: p,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
        (_) => false,
      );
    } on AuthException catch (err) {
      showMessage(err.message);
    } catch (_) {
      showMessage('Login করতে সমস্যা হয়েছে');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
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
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C4DFF),
                        Color(0xFFB388FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 55,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

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
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      inputStyle('Email', Icons.email_outlined),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: password,
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

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
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  bool hidden1 = true;
  bool hidden2 = true;

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> signUp() async {
    final n = name.text.trim();
    final e = email.text.trim();
    final p = password.text;
    final c = confirm.text;

    if (n.isEmpty || e.isEmpty || p.isEmpty || c.isEmpty) {
      showMessage('সবগুলো তথ্য পূরণ করুন');
      return;
    }

    if (p.length < 6) {
      showMessage('Password কমপক্ষে ৬ অক্ষরের হতে হবে');
      return;
    }

    if (p != c) {
      showMessage('Password মিলছে না');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await supabase.auth.signUp(
        email: e,
        password: p,
        data: {
          'full_name': n,
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
        showMessage(
          'Account তৈরি হয়েছে। Email confirmation করুন।',
        );

        Navigator.pop(context);
      }
    } on AuthException catch (err) {
      showMessage(err.message);
    } catch (_) {
      showMessage('Sign Up করতে সমস্যা হয়েছে');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
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
                size: 85,
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
                controller: name,
                decoration:
                    inputStyle(
                  'Full Name',
                  Icons.person_outline,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    inputStyle(
                  'Email',
                  Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: password,
                obscureText: hidden1,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => hidden1 = !hidden1,
                      );
                    },
                    icon: Icon(
                      hidden1
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF151820),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: confirm,
                obscureText: hidden2,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon:
                      const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => hidden2 = !hidden2,
                      );
                    },
                    icon: Icon(
                      hidden2
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF151820),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
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
  int index = 0;

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
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() => index = value);
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
            selectedIcon:
                Icon(Icons.notifications),
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
          'Share your favorite gaming moments! 🎮',
      'likes': 8,
      'liked': false,
    },
  ];

  String get currentName {
    final user = supabase.auth.currentUser;

    return user
            ?.userMetadata?['full_name']
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
      (_) => false,
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
            fontSize: 24,
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
            bottom: 25,
          ),
          children: [
            _stories(),
            const SizedBox(height: 15),
            _createBox(),
            const SizedBox(height: 10),
            ...posts.map(_postCard),
          ],
        ),
      ),
    );
  }

  Widget _stories() {
    final stories = [
      ['You', Icons.add],
      ['Friends', Icons.person],
      ['Gaming', Icons.gamepad],
      ['Music', Icons.music_note],
      ['Travel', Icons.flight],
    ];

    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (_, i) {
          return Container(
            width: 78,
            margin:
                const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor:
                      const Color(0xFF7C4DFF)
                          .withOpacity(.25),
                  child: Icon(
                    stories[i][1] as IconData,
                    color:
                        const Color(0xFF9B6DFF),
                    size: 29,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  stories[i][0].toString(),
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _createBox() {
    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF12151C),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  const Color(0xFF7C4DFF),
              child: Text(
                currentName.isNotEmpty
                    ? currentName[0].toUpperCase()
                    : 'S',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'What’s on your mind?',
                style:
                    TextStyle(color: Colors.grey),
              ),
            ),
            const Icon(
              Icons.photo_outlined,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(
      Map<String, dynamic> post) {
    final liked = post['liked'] as bool;
    final likes = post['likes'] as int;

    return Card(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      color: const Color(0xFF12151C),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post['name'].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              post['text'].toString(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              '$likes likes',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      post['liked'] = !liked;

                      post['likes'] =
                          liked
                              ? likes - 1
                              : likes + 1;
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
                  onPressed: () {
                    _comments();
                  },
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  label:
                      const Text('Comment'),
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

  void _comments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          const Color(0xFF12151C),
      builder: (_) {
        return SizedBox(
          height:
              MediaQuery.of(context).size.height *
                  .60,
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
                    hintText:
                        'Write a comment...',
                    suffixIcon: IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.send),
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
          style:
              TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: inputStyle(
                'Search people, posts...',
                Icons.search,
              ),
            ),
            const SizedBox(height: 35),
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 10),
            Text(
              'Search SocialBook',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 18,
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
          style:
              TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: inputStyle(
                'What do you want to share?',
                Icons.edit,
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

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: publish,
                icon:
                    const Icon(Icons.send),
                label:
                    const Text('Publish Post'),
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
      'Your account is connected.',
      'Create your first post.',
      'Discover people and communities.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style:
              TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (_, i) {
          return Card(
            color: const Color(0xFF12151C),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor:
                    Color(0xFF7C4DFF),
                child: Icon(
                  Icons.notifications,
                ),
              ),
              title:
                  Text(notifications[i]),
              subtitle:
                  const Text('Just now'),
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
    final user =
        supabase.auth.currentUser;

    return user
            ?.userMetadata?['full_name']
            ?.toString() ??
        'SocialBook User';
  }

  String get email {
    return supabase.auth.currentUser?.email ??
        '';
  }

  Future<void> logout(
      BuildContext context) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final letter = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style:
              TextStyle(fontWeight: FontWeight.bold),
        ),
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

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: const [
              _ProfileStat(
                title: 'Posts',
                value: '0',
              ),
              _ProfileStat(
                title: 'Friends',
                value: '0',
              ),
              _ProfileStat(
                title: 'Following',
                value: '0',
              ),
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
                  title:
                      const Text('Edit Profile'),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.bookmark_outline,
                  ),
                  title:
                      const Text('Saved Posts'),
                  trailing:
                      const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                  ),
                  title:
                      const Text('Settings'),
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
                  onTap: () =>
                      logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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

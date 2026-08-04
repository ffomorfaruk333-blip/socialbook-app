import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

const supabaseUrl = 'https://xsxrcrbcxckicskwppmb.supabase.co';

const supabasePublishableKey =
    'sb_publishable_0xGXFjbz404LyFWwWo6kzw_wHUgY0NT';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const SocialBookApp());
}

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

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (supabase.auth.currentSession != null) {
          return const MainNavigation();
        }

        return const LoginPage();
      },
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

InputDecoration decoration(
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

void message(
  BuildContext context,
  String text,
) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
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
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool hidden = true;

  Future<void> login() async {
    final e = email.text.trim();
    final p = password.text;

    if (e.isEmpty || p.isEmpty) {
      message(context, 'Email এবং Password দিন');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: e,
        password: p,
      );
    } on AuthException catch (e) {
      if (mounted) message(context, e.message);
    } catch (_) {
      if (mounted) message(context, 'Login করা যায়নি');
    } finally {
      if (mounted) setState(() => loading = false);
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
                  ),
                ),
                const SizedBox(height: 24),
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
                  decoration: decoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: password,
                  obscureText: hidden,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
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
                            width: 23,
                            height: 23,
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
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  bool hide1 = true;
  bool hide2 = true;

  Future<void> signup() async {
    final n = name.text.trim();
    final e = email.text.trim();
    final p = password.text;
    final c = confirm.text;

    if (n.isEmpty || e.isEmpty || p.isEmpty || c.isEmpty) {
      message(context, 'সব তথ্য পূরণ করুন');
      return;
    }

    if (p.length < 6) {
      message(context, 'Password কমপক্ষে ৬ অক্ষরের হতে হবে');
      return;
    }

    if (p != c) {
      message(context, 'Password মিলছে না');
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
        message(
          context,
          'Account তৈরি হয়েছে। Email confirmation করুন।',
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) message(context, e.message);
    } catch (_) {
      if (mounted) message(context, 'Signup করা যায়নি');
    } finally {
      if (mounted) setState(() => loading = false);
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
                controller: name,
                decoration: decoration(
                  'Full Name',
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: decoration(
                  'Email',
                  Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: password,
                obscureText: hide1,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => hide1 = !hide1);
                    },
                    icon: Icon(
                      hide1
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
                controller: confirm,
                obscureText: hide2,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => hide2 = !hide2);
                    },
                    icon: Icon(
                      hide2
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
                  onPressed: loading ? null : signup,
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
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  Future<void> openCreatePost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostPage(),
      ),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onRefresh: () => setState(() {}),
        onCreatePost: openCreatePost,
      ),
      const SearchPage(),
      CreatePostPage(
        onPublished: () {
          setState(() => index = 0);
        },
      ),
      const NotificationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() => index = i);
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
  final VoidCallback? onRefresh;
  final VoidCallback? onCreatePost;

  const HomePage({
    super.key,
    this.onRefresh,
    this.onCreatePost,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;
  List<Map<String, dynamic>> posts = [];

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
        posts = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        message(context, 'Post load করা যায়নি: $e');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String get currentName {
    final user = supabase.auth.currentUser;

    return user?.userMetadata?['full_name']?.toString() ??
        user?.email?.split('@').first ??
        'User';
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

  Future<void> deletePost(dynamic id) async {
    final user = supabase.auth.currentUser;

    if (user == null || id == null) return;

    try {
      await supabase
          .from('posts')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      await loadPosts();

      if (mounted) {
        message(context, 'Post delete হয়েছে');
      }
    } catch (e) {
      if (mounted) {
        message(context, 'Delete করা যায়নি: $e');
      }
    }
  }

  // ==========================================================
  // SHARE POST
  // ==========================================================

  Future<void> sharePost(Map<String, dynamic> post) async {
    final content = post['content']?.toString() ?? '';

    final shareText =
        'SocialBook Post\n\n'
        '$content\n\n'
        'Shared from SocialBook';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: 'SocialBook Post',
        ),
      );
    } catch (e) {
      if (mounted) {
        message(context, 'Share করা যায়নি: $e');
      }
    }
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
            onPressed: widget.onCreatePost,
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadPosts,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 30,
                ),
                children: [
                  createPostBox(),
                  const SizedBox(height: 12),
                  if (posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'এখনও কোনো Post নেই',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...posts.map(
                      (post) => postCard(post),
                    ),
                ],
              ),
      ),
    );
  }

  Widget createPostBox() {
    final letter = currentName.isNotEmpty
        ? currentName[0].toUpperCase()
        : 'U';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF12151C),
      child: InkWell(
        onTap: widget.onCreatePost,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF7C4DFF),
                child: Text(letter),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "What's on your mind?",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                color: Color(0xFF9B6DFF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget postCard(Map<String, dynamic> post) {
    final user = supabase.auth.currentUser;

    final ownerId = post['user_id']?.toString();
    final mine = user != null && ownerId == user.id;

    final content = post['content']?.toString() ?? '';

    String author = 'SocialBook User';

    if (mine) {
      author =
          user?.userMetadata?['full_name']?.toString() ??
          user?.email?.split('@').first ??
          'You';
    }

    final letter =
        author.isNotEmpty ? author[0].toUpperCase() : 'U';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      color: const Color(0xFF12151C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF7C4DFF),
                  child: Text(letter),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Public post',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (mine)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        deletePost(post['id']);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            const Divider(),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    message(
                      context,
                      'Like database system পরের ধাপে যুক্ত করা যাবে',
                    );
                  },
                  icon: const Icon(
                    Icons.favorite_border,
                  ),
                  label: const Text('Like'),
                ),
                TextButton.icon(
                  onPressed: () {
                    showComments(post['id']);
                  },
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  label: const Text('Comment'),
                ),
                TextButton.icon(
                  onPressed: () {
                    sharePost(post);
                  },
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

  void showComments(dynamic postId) {
    if (postId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12151C),
      builder: (_) {
        return CommentSheet(postId: postId);
      },
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
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final controller = TextEditingController();

  bool publishing = false;

  Future<void> publish() async {
    final text = controller.text.trim();

    if (text.isEmpty) {
      message(context, 'Post লিখুন');
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      message(context, 'আগে Login করুন');
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

      message(
        context,
        '🎉 Post সফলভাবে প্রকাশ হয়েছে',
      );

      widget.onPublished?.call();

      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      if (mounted) {
        message(
          context,
          'Database error: ${e.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Post করা যায়নি: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => publishing = false);
      }
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
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: publishing ? null : publish,
              child: publishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Post'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical:
                      TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        "What's on your mind?",
                    filled: true,
                    fillColor:
                        const Color(0xFF151820),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.all(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: FilledButton.icon(
                  onPressed:
                      publishing ? null : publish,
                  icon:
                      const Icon(Icons.send_rounded),
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
// COMMENTS
// ============================================================

class CommentSheet extends StatefulWidget {
  final dynamic postId;

  const CommentSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentSheet> createState() =>
      _CommentSheetState();
}

class _CommentSheetState
    extends State<CommentSheet> {
  final controller = TextEditingController();

  List<Map<String, dynamic>> comments = [];
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final data = await supabase
          .from('comments')
          .select()
          .eq('post_id', widget.postId)
          .order(
            'created_at',
            ascending: true,
          );

      if (!mounted) return;

      setState(() {
        comments =
            List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> addComment() async {
    final text = controller.text.trim();
    final user = supabase.auth.currentUser;

    if (text.isEmpty || user == null) return;

    setState(() => sending = true);

    try {
      await supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': user.id,
        'content': text,
      });

      controller.clear();

      await loadComments();
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Comment করা যায়নি: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height * .75,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : comments.isEmpty
                        ? const Center(
                            child: Text(
                              'No comments yet',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                comments.length,
                            itemBuilder: (_, i) {
                              return ListTile(
                                leading:
                                    const CircleAvatar(
                                  child: Icon(
                                    Icons.person,
                                  ),
                                ),
                                title: Text(
                                  comments[i]
                                          ['content']
                                      ?.toString() ??
                                      '',
                                ),
                              );
                            },
                          ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration:
                          InputDecoration(
                        hintText:
                            'Write a comment...',
                        filled: true,
                        fillColor:
                            const Color(0xFF191C24),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed:
                        sending ? null : addComment,
                    icon:
                        const Icon(Icons.send),
                  ),
                ],
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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() =>
      _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();

  List<Map<String, dynamic>> results = [];
  bool loading = false;

  Future<void> search() async {
    final q = controller.text.trim();

    if (q.isEmpty) return;

    setState(() => loading = true);

    try {
      final data = await supabase
          .from('posts')
          .select()
          .ilike('content', '%$q%')
          .order(
            'created_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        results =
            List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Search error: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: search,
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                ),
                filled: true,
                fillColor:
                    const Color(0xFF151820),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : results.isEmpty
                      ? const Center(
                          child: Text(
                            'Search result এখানে দেখাবে',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              results.length,
                          itemBuilder: (_, i) {
                            return Card(
                              color: const Color(
                                0xFF12151C,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  15,
                                ),
                                child: Text(
                                  results[i]['content']
                                          ?.toString() ??
                                      '',
                                ),
                              ),
                            );
                          },
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

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          Card(
            color: Color(0xFF12151C),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Color(0xFF7C4DFF),
                child:
                    Icon(Icons.notifications),
              ),
              title:
                  Text('Welcome to SocialBook 🎉'),
              subtitle:
                  Text('Your account is ready'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  String get name {
    final user = supabase.auth.currentUser;

    return user?.userMetadata?['full_name']
            ?.toString() ??
        user?.email?.split('@').first ??
        'SocialBook User';
  }

  String get email {
    return supabase.auth.currentUser?.email ?? '';
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> editName() async {
    final controller =
        TextEditingController(text: name);

    final value =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text('Edit Name'),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(
              hintText: 'Your name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  controller.text.trim(),
                );
              },
              child:
                  const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value == null || value.isEmpty) {
      return;
    }

    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': value,
          },
        ),
      );

      if (mounted) {
        setState(() {});
        message(
          context,
          'Profile update হয়েছে',
        );
      }
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Profile update করা যায়নি: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter =
        name.isNotEmpty
            ? name[0].toUpperCase()
            : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
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
                  fontWeight:
                      FontWeight.bold,
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
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              email,
              style: TextStyle(
                color:
                    Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            color:
                const Color(0xFF12151C),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: const Text(
                    'Edit Profile',
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                  ),
                  onTap: editName,
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
                  onTap: () {
                    message(
                      context,
                      'Settings আসছে',
                    );
                  },
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
                  onTap: logout,
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

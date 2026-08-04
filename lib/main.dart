import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://xsxrcrbcxckicskwppmb.supabase.co';
const supabasePublishableKey =
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        return supabase.auth.currentSession == null
            ? const LoginPage()
            : const MainNavigation();
      },
    );
  }
}

InputDecoration field(String hint, IconData icon) {
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

void message(BuildContext context, String text) {
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
  final pass = TextEditingController();

  bool loading = false;
  bool hide = true;

  Future<void> login() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      message(context, 'ইমেইল ও পাসওয়ার্ড দিন');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email.text.trim(),
        password: pass.text,
      );
    } on AuthException catch (e) {
      if (mounted) {
        message(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        message(context, 'Login করতে সমস্যা হয়েছে');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
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
                  color: Color(0xFF9B6DFF),
                ),
                const SizedBox(height: 18),
                const Text(
                  'SocialBook',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect. Share. Discover.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 38),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      field('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pass,
                  obscureText: hide,
                  decoration: field(
                    'Password',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => hide = !hide);
                      },
                      icon: Icon(
                        hide
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupPage(),
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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  final name = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  bool h1 = true;
  bool h2 = true;

  Future<void> signup() async {
    final n = name.text.trim();
    final u = username.text.trim().toLowerCase();
    final e = email.text.trim();
    final p = pass.text;

    if ([n, u, e, p, confirm.text].any((x) => x.isEmpty)) {
      message(context, 'সব তথ্য পূরণ করুন');
      return;
    }

    if (p.length < 6) {
      message(
        context,
        'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে',
      );
      return;
    }

    if (p != confirm.text) {
      message(context, 'পাসওয়ার্ড মিলছে না');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await supabase.auth.signUp(
        email: e,
        password: p,
        data: {
          'full_name': n,
          'username': u,
        },
      );

      if (!mounted) return;

      if (result.session == null) {
        message(
          context,
          'অ্যাকাউন্ট তৈরি হয়েছে। ইমেইল কনফার্ম করে Login করুন।',
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) {
        message(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        message(context, 'Sign Up করতে সমস্যা হয়েছে');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    name.dispose();
    username.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            size: 75,
            color: Color(0xFF9B6DFF),
          ),
          const SizedBox(height: 15),
          const Text(
            'Create Your Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: name,
            decoration:
                field('Full Name', Icons.person_outline),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: username,
            decoration:
                field('Username', Icons.alternate_email),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration:
                field('Email', Icons.email_outlined),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: pass,
            obscureText: h1,
            decoration: field(
              'Password',
              Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => h1 = !h1);
                },
                icon: Icon(
                  h1
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirm,
            obscureText: h2,
            decoration: field(
              'Confirm Password',
              Icons.lock_reset,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => h2 = !h2);
                },
                icon: Icon(
                  h2
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 55,
            child: FilledButton(
              onPressed: loading ? null : signup,
              child: loading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                    )
                  : const Text('Sign Up'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          const HomePage(),
          const SearchPage(),
          CreatePostPage(
            onPublished: () {
              setState(() => index = 0);
            },
          ),
          const NotificationsPage(),
          const ProfilePage(),
        ],
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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  List<Map<String, dynamic>> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      final data = await supabase
          .from('posts')
          .select(
            'id,user_id,content,created_at,profiles(full_name,username)',
          )
          .order(
            'created_at',
            ascending: false,
          );

      if (mounted) {
        setState(() {
          posts =
              List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Posts load হয়নি: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String author(Map<String, dynamic> post) {
    final profile = post['profiles'];

    if (profile is Map) {
      return (
        profile['full_name'] ??
        profile['username'] ??
        'User'
      ).toString();
    }

    return 'SocialBook User';
  }

  Future<void> deletePost(dynamic id) async {
    try {
      await supabase
          .from('posts')
          .delete()
          .eq('id', id);

      await load();
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Delete হয়নি: $e',
        );
      }
    }
  }

  Future<void> like(dynamic id) async {
    final me = supabase.auth.currentUser;

    if (me == null) return;

    try {
      final old = await supabase
          .from('post_likes')
          .select('id')
          .eq('post_id', id)
          .eq('user_id', me.id)
          .maybeSingle();

      if (old == null) {
        await supabase
            .from('post_likes')
            .insert({
          'post_id': id,
          'user_id': me.id,
        });
      } else {
        await supabase
            .from('post_likes')
            .delete()
            .eq('id', old['id']);
      }

      if (mounted) {
        message(
          context,
          old == null
              ? 'Like হয়েছে ❤️'
              : 'Like সরানো হয়েছে',
        );
      }
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Like করতে সমস্যা হয়েছে: $e',
        );
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              supabase.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  Card(
                    child: ListTile(
                      leading:
                          const Icon(Icons.edit),
                      title: const Text(
                        'What’s on your mind?',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreatePostPage(),
                          ),
                        ).then((_) => load());
                      },
                    ),
                  ),
                  if (posts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'এখনও কোনো post নেই',
                        ),
                      ),
                    ),
                  ...posts.map(
                    (post) => Card(
                      margin:
                          const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  child: Text(
                                    author(post)
                                            .isEmpty
                                        ? 'U'
                                        : author(
                                                post)[0]
                                            .toUpperCase(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    author(post),
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (post['user_id'] ==
                                    supabase
                                        .auth
                                        .currentUser
                                        ?.id)
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value ==
                                          'delete') {
                                        deletePost(
                                          post['id'],
                                        );
                                      }
                                    },
                                    itemBuilder: (_) =>
                                        const [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child:
                                            Text('Delete'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              post['content']
                                  .toString(),
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceAround,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      like(post['id']),
                                  icon: const Icon(
                                    Icons
                                        .favorite_border,
                                  ),
                                  label:
                                      const Text('Like'),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CommentsPage(
                                          postId:
                                              post['id'],
                                        ),
                                      ),
                                    );
                                  },
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
                                    Icons
                                        .share_outlined,
                                  ),
                                  label:
                                      const Text('Share'),
                                ),
                              ],
                            ),
                          ],
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
      _CreatePostState();
}

class _CreatePostState
    extends State<CreatePostPage> {
  final text = TextEditingController();

  bool loading = false;

  Future<void> publish() async {
    final me = supabase.auth.currentUser;

    if (me == null) {
      message(context, 'Login করুন');
      return;
    }

    final value = text.text.trim();

    if (value.isEmpty) {
      message(context, 'Post লিখুন');
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.from('posts').insert({
        'user_id': me.id,
        'content': value,
      });

      if (!mounted) return;

      message(
        context,
        'Post সফলভাবে প্রকাশ হয়েছে 🎉',
      );

      widget.onPublished?.call();

      Navigator.pop(context);
    } on PostgrestException catch (e) {
      if (mounted) {
        message(context, e.message);
      }
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Post প্রকাশ হয়নি',
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
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: text,
            minLines: 8,
            maxLines: 14,
            maxLength: 5000,
            decoration: const InputDecoration(
              hintText:
                  'What do you want to share?',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed:
                  loading ? null : publish,
              icon: const Icon(Icons.send),
              label: Text(
                loading
                    ? 'Publishing...'
                    : 'Publish Post',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMMENTS
// ============================================================

class CommentsPage extends StatefulWidget {
  final dynamic postId;

  const CommentsPage({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsPage> createState() =>
      _CommentsState();
}

class _CommentsState
    extends State<CommentsPage> {
  final text = TextEditingController();

  List<Map<String, dynamic>> comments = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await supabase
          .from('comments')
          .select(
            'id,user_id,content,created_at,profiles(full_name,username)',
          )
          .eq('post_id', widget.postId)
          .order('created_at');

      if (mounted) {
        setState(() {
          comments =
              List<Map<String, dynamic>>.from(
            data,
          );
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        message(
          context,
          'Comments load হয়নি: $e',
        );
      }
    }
  }

  Future<void> send() async {
    final me = supabase.auth.currentUser;
    final value = text.text.trim();

    if (me == null || value.isEmpty) return;

    try {
      await supabase.from('comments').insert({
        'post_id': widget.postId,
        'user_id': me.id,
        'content': value,
      });

      text.clear();

      await load();
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Comment করা যায়নি: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : ListView(
                    children: comments.map((item) {
                      final profile =
                          item['profiles'];

                      final name =
                          profile is Map
                              ? (
                                  profile['full_name'] ??
                                  profile['username'] ??
                                  'User'
                                ).toString()
                              : 'User';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            name.isEmpty
                                ? 'U'
                                : name[0]
                                    .toUpperCase(),
                          ),
                        ),
                        title: Text(name),
                        subtitle: Text(
                          item['content']
                              .toString(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: text,
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Write a comment...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: send,
                  icon:
                      const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
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
      _SearchState();
}

class _SearchState
    extends State<SearchPage> {
  final q = TextEditingController();

  List<Map<String, dynamic>> users = [];

  bool loading = false;

  Future<void> search() async {
    final value = q.text.trim();

    if (value.isEmpty) return;

    setState(() => loading = true);

    try {
      final data = await supabase
          .from('profiles')
          .select(
            'id,full_name,username',
          )
          .or(
            'full_name.ilike.%$value%,username.ilike.%$value%',
          )
          .limit(30);

      if (mounted) {
        setState(() {
          users =
              List<Map<String, dynamic>>.from(
            data,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Search হয়নি: $e',
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
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: q,
              onSubmitted: (_) => search(),
              decoration: field(
                'Search people...',
                Icons.search,
              ).copyWith(
                suffixIcon: IconButton(
                  onPressed: search,
                  icon:
                      const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (loading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView(
                  children: users.map((user) {
                    final name =
                        (user['full_name'] ??
                                'User')
                            .toString();

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          name.isEmpty
                              ? 'U'
                              : name[0]
                                  .toUpperCase(),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(
                        '@${user['username'] ?? ''}',
                      ),
                    );
                  }).toList(),
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
    return const Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: Text('Notifications'),
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
    final user =
        supabase.auth.currentUser;

    final name = (
      user?.userMetadata?['full_name'] ??
      user?.email?.split('@').first ??
      'User'
    ).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor:
                  Color(0xFF7C4DFF),
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? '',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Card(
            child: ListTile(
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
              onTap: () {
                supabase.auth.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

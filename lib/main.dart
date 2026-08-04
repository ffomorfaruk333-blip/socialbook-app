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

// ============================================================
// AUTH GATE
// ============================================================

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
    final session = supabase.auth.currentSession;

    if (session != null) {
      return const MainNavigation();
    }

    return const LoginPage();
  }
}

// ============================================================
// COMMON UI
// ============================================================

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
      showAppMessage(
        context,
        'Email এবং Password দিন',
      );
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      if (mounted) {
        showAppMessage(context, error.message);
      }
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Login করতে সমস্যা হয়েছে',
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
                const SizedBox(height: 30),

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
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 55,
                    color: Colors.white,
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
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: inputDecoration(
                    'Email',
                    Icons.email_outlined,
                  ),
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
                        setState(
                          () => hidden = !hidden,
                        );
                      },
                      icon: Icon(
                        hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
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

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed:
                        loading ? null : login,
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

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SignUpPage(),
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
  State<SignUpPage> createState() =>
      _SignUpPageState();
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
    final name =
        nameController.text.trim();
    final email =
        emailController.text.trim();
    final password =
        passwordController.text;
    final confirm =
        confirmController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      showAppMessage(
        context,
        'সবগুলো তথ্য পূরণ করুন',
      );
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
      showAppMessage(
        context,
        'Password মিলছে না',
      );
      return;
    }

    setState(() => loading = true);

    try {
      final result =
          await supabase.auth.signUp(
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
            builder: (_) =>
                const MainNavigation(),
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
    } on AuthException catch (error) {
      if (mounted) {
        showAppMessage(
          context,
          error.message,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Sign Up করতে সমস্যা হয়েছে',
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
                textCapitalization:
                    TextCapitalization.words,
                decoration: inputDecoration(
                  'Full Name',
                  Icons.person_outline,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: inputDecoration(
                  'Email',
                  Icons.email_outlined,
                ),
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
                  fillColor:
                      const Color(0xFF151820),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
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
                  fillColor:
                      const Color(0xFF151820),
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
                  onPressed:
                      loading ? null : signUp,
                  child: loading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () =>
                    Navigator.pop(context),
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
      HomePage(
        onCreatePost: () async {
          final result =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreatePostPage(),
            ),
          );

          if (result == true && mounted) {
            setState(() {});
          }
        },
      ),
      const SearchPage(),
      CreatePostPage(
        onPublished: () {
          setState(() {
            currentIndex = 0;
          });
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
      bottomNavigationBar:
          NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon:
                Icon(Icons.home_outlined),
            selectedIcon:
                Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.add_box_outlined),
            selectedIcon:
                Icon(Icons.add_box),
            label: 'Create',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.notifications_outlined),
            selectedIcon:
                Icon(Icons.notifications),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.person_outline),
            selectedIcon:
                Icon(Icons.person),
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
  final Future<void> Function()? onCreatePost;

  const HomePage({
    super.key,
    this.onCreatePost,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  List<Map<String, dynamic>> posts = [];

  bool postsLoading = true;

  String get currentName {
    final user =
        supabase.auth.currentUser;

    return user
            ?.userMetadata?['full_name']
            ?.toString() ??
        user?.email
            ?.split('@')
            .first ??
        'SocialBook User';
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    if (mounted) {
      setState(() {
        postsLoading = true;
      });
    }

    try {
      final data = await supabase
          .from('posts')
          .select()
          .order(
            'created_at',
            ascending: false,
          );

      if (!mounted) return;

      setState(() {
        posts = List<
            Map<String, dynamic>>.from(
          data,
        );
      });
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Posts load করতে সমস্যা হয়েছে',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          postsLoading = false;
        });
      }
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: postsLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadPosts,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.only(
                  top: 12,
                  bottom: 30,
                ),
                children: [
                  _stories(),

                  const SizedBox(height: 15),

                  _createBox(),

                  const SizedBox(height: 12),

                  if (posts.isEmpty)
                    const Padding(
                      padding:
                          EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'এখনও কোনো post নেই',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...posts.map(
                      _postCard,
                    ),
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
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: stories.length,
        itemBuilder: (_, index) {
          return SizedBox(
            width: 78,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor:
                      const Color(0xFF7C4DFF)
                          .withOpacity(.20),
                  child: Icon(
                    stories[index][1]
                        as IconData,
                    color: const Color(
                        0xFF9B6DFF),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  stories[index][0]
                      .toString(),
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
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
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      color:
          const Color(0xFF12151C),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: widget.onCreatePost,
        child: Padding(
          padding:
              const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    const Color(
                        0xFF7C4DFF),
                child: Text(
                  currentName
                          .isNotEmpty
                      ? currentName[0]
                          .toUpperCase()
                      : 'S',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'What’s on your mind?',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
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

  Widget _postCard(
    Map<String, dynamic> post,
  ) {
    final content =
        post['content']?.toString() ??
            '';

    final userId =
        post['user_id']?.toString();

    final currentUser =
        supabase.auth.currentUser;

    final isMine =
        userId != null &&
        currentUser != null &&
        userId == currentUser.id;

    final metadata =
        currentUser?.userMetadata;

    final author =
        isMine
            ? metadata?['full_name']
                    ?.toString() ??
                currentUser.email
                    ?.split('@')
                    .first ??
                'You'
            : 'SocialBook User';

    final letter = author.isNotEmpty
        ? author[0].toUpperCase()
        : 'S';

    return Card(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
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
                CircleAvatar(
                  backgroundColor:
                      const Color(
                          0xFF7C4DFF),
                  child: Text(
                    letter,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        author,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      const Text(
                        'Public post',
                        style:
                            TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected:
                      (value) {
                    if (value ==
                            'delete' &&
                        isMine) {
                      _deletePost(
                          post['id']);
                    }
                  },
                  itemBuilder: (_) => [
                    if (isMine)
                      const PopupMenuItem(
                        value:
                            'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                              color: Colors
                                  .redAccent,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Delete',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              content,
              style:
                  const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            const Divider(),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    showAppMessage(
                      context,
                      'Like system পরের ধাপে database-এর সাথে যুক্ত করা হবে ❤️',
                    );
                  },
                  icon: const Icon(
                    Icons
                        .favorite_border,
                  ),
                  label:
                      const Text('Like'),
                ),
                TextButton.icon(
                  onPressed:
                      _showComments,
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
    );
  }

  Future<void> _deletePost(
    dynamic postId,
  ) async {
    if (postId == null) return;

    try {
      await supabase
          .from('posts')
          .delete()
          .eq('id', postId);

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

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          const Color(0xFF12151C),
      builder: (_) {
        return Padding(
          padding:
              EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
          ),
          child: SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    .55,
            child: Column(
              children: [
                const Text(
                  'Comments',
                  style:
                      TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                    height: 20),
                const Expanded(
                  child: Center(
                    child: Text(
                      'No comments yet',
                      style:
                          TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  ),
                ),
                TextField(
                  decoration:
                      InputDecoration(
                    hintText:
                        'Write a comment...',
                    filled: true,
                    fillColor:
                        const Color(
                            0xFF1A1D25),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  15),
                      borderSide:
                          BorderSide
                              .none,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        showAppMessage(
                          context,
                          'Comment system পরের ধাপে database-এর সাথে যুক্ত করা হবে',
                        );
                      },
                      icon: const Icon(
                        Icons.send,
                      ),
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
  final controller =
      TextEditingController();

  bool publishing = false;

  String get currentName {
    final user =
        supabase.auth.currentUser;

    return user?.userMetadata?[
                'full_name']
            ?.toString() ??
        user?.email
            ?.split('@')
            .first ??
        'SocialBook User';
  }

  Future<void> publishPost() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) {
      showAppMessage(
        context,
        'Post লিখুন',
      );
      return;
    }

    if (text.length > 5000) {
      showAppMessage(
        context,
        'Post সর্বোচ্চ 5000 অক্ষরের হতে পারে',
      );
      return;
    }

    final user =
        supabase.auth.currentUser;

    if (user == null) {
      showAppMessage(
        context,
        'Post করতে Login করুন',
      );
      return;
    }

    setState(() {
      publishing = true;
    });

    try {
      await supabase
          .from('posts')
          .insert({
        'user_id': user.id,
        'content': text,
      });

      controller.clear();

      if (!mounted) return;

      showAppMessage(
        context,
        'Post সফলভাবে প্রকাশ হয়েছে 🎉',
      );

      widget.onPublished?.call();

      Navigator.pop(
        context,
        true,
      );
    } on PostgrestException catch (
        error) {
      if (mounted) {
        showAppMessage(
          context,
          error.message,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppMessage(
          context,
          'Post প্রকাশ করতে সমস্যা হয়েছে',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          publishing = false;
        });
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
    final name = currentName;

    final letter = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Post',
          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        const Color(
                            0xFF7C4DFF),
                    child: Text(
                      letter,
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                            height: 3),
                        Text(
                          'Public post',
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.public,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(
                  height: 20),

              Container(
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                          0xFF12151C),
                  borderRadius:
                      BorderRadius
                          .circular(18),
                  border:
                      Border.all(
                    color: Colors.white
                        .withOpacity(.06),
                  ),
                ),
                padding:
                    const EdgeInsets
                        .all(16),
                child: TextField(
                  controller:
                      controller,
                  minLines: 8,
                  maxLines: 14,
                  maxLength: 5000,
                  textCapitalization:
                      TextCapitalization
                          .sentences,
                  decoration:
                      const InputDecoration(
                    hintText:
                        'What do you want to share?',
                    border:
                        InputBorder
                            .none,
                    counterText: '',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(
                  height: 15),

              Container(
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                          0xFF12151C),
                  borderRadius:
                      BorderRadius
                          .circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(
                        Icons
                            .photo_outlined,
                        color:
                            Colors.green,
                      ),
                      title:
                          const Text(
                        'Add Photo',
                      ),
                      subtitle:
                          const Text(
                        'Photo upload',
                      ),
                      onTap:
                          publishing
                              ? null
                              : () {
                                  showAppMessage(
                                    context,
                                    'Photo upload পরের ধাপে যুক্ত করা হবে 📷',
                                  );
                                },
                    ),
                    const Divider(
                        height: 1),
                    ListTile(
                      leading:
                          const Icon(
                        Icons
                            .videocam_outlined,
                        color:
                            Colors.redAccent,
                      ),
                      title:
                          const Text(
                        'Add Video',
                      ),
                      subtitle:
                          const Text(
                        'Video upload',
                      ),
                      onTap:
                          publishing
                              ? null
                              : () {
                                  showAppMessage(
                                    context,
                                    'Video upload পরের ধাপে যুক্ত করা হবে 🎬',
                                  );
                                },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 20),

              SizedBox(
                width:
                    double.infinity,
                height: 56,
                child:
                    FilledButton.icon(
                  onPressed:
                      publishing
                          ? null
                          : publishPost,
                  icon: publishing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.5,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .send_rounded,
                        ),
                  label: Text(
                    publishing
                        ? 'Publishing...'
                        : 'Publish Post',
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height: 10),

              Center(
                child: Text(
                  'Your post will be saved securely to SocialBook.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                    fontSize: 12,
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

class SearchPage
    extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration:
                  inputDecoration(
                'Search people, posts...',
                Icons.search,
              ),
            ),
            const SizedBox(
                height: 40),
            Icon(
              Icons.search,
              size: 80,
              color:
                  Colors.grey.shade700,
            ),
            const SizedBox(
                height: 10),
            Text(
              'Search SocialBook',
              style: TextStyle(
                color:
                    Colors.grey.shade500,
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
// NOTIFICATIONS
// ============================================================

class NotificationsPage
    extends StatelessWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const notifications = [
      'Welcome to SocialBook 🎉',
      'Your account is connected.',
      'Create your first post.',
      'Discover people and communities.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding:
            const EdgeInsets.all(12),
        itemCount:
            notifications.length,
        itemBuilder: (_, index) {
          return Card(
            color:
                const Color(0xFF12151C),
            child: ListTile(
              leading:
                  const CircleAvatar(
                backgroundColor:
                    Color(0xFF7C4DFF),
                child: Icon(
                  Icons
                      .notifications,
                ),
              ),
              title: Text(
                notifications[index],
              ),
              subtitle:
                  const Text(
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

class ProfilePage
    extends StatelessWidget {
  const ProfilePage({super.key});

  String get name {
    final user =
        supabase.auth.currentUser;

    return user?.userMetadata?[
                'full_name']
            ?.toString() ??
        user?.email
            ?.split('@')
            .first ??
        'SocialBook User';
  }

  String get email {
    return supabase.auth.currentUser
            ?.email ??
        '';
  }

  Future<void> logout(
    BuildContext context,
  ) async {
    await supabase.auth.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
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
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const SizedBox(
              height: 20),

          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor:
                  const Color(
                      0xFF7C4DFF),
              child: Text(
                letter,
                style:
                    const TextStyle(
                  fontSize: 44,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(
              height: 18),

          Center(
            child: Text(
              name,
              style:
                  const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
              height: 7),

          Center(
            child: Text(
              email,
              style: TextStyle(
                color: Colors
                    .grey
                    .shade500,
              ),
            ),
          ),

          const SizedBox(
              height: 30),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly,
            children: const [
              ProfileStat(
                title: 'Posts',
                value: '0',
              ),
              ProfileStat(
                title: 'Friends',
                value: '0',
              ),
              ProfileStat(
                title: 'Following',
                value: '0',
              ),
            ],
          ),

          const SizedBox(
              height: 30),

          Card(
            color:
                const Color(
                    0xFF12151C),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .person_outline,
                  ),
                  title:
                      const Text(
                    'Edit Profile',
                  ),
                  trailing:
                      const Icon(
                    Icons
                        .chevron_right,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .bookmark_outline,
                  ),
                  title:
                      const Text(
                    'Saved Posts',
                  ),
                  trailing:
                      const Icon(
                    Icons
                        .chevron_right,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .settings_outlined,
                  ),
                  title:
                      const Text(
                    'Settings',
                  ),
                  trailing:
                      const Icon(
                    Icons
                        .chevron_right,
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      const Icon(
                    Icons.logout,
                    color:
                        Colors.redAccent,
                  ),
                  title:
                      const Text(
                    'Logout',
                    style:
                        TextStyle(
                      color:
                          Colors.redAccent,
                    ),
                  ),
                  onTap: () =>
                      logout(context),
                ),
              ],
            ),
          ),

          const SizedBox(
              height: 30),

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

// ============================================================
// PROFILE STAT
// ============================================================

class ProfileStat
    extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style:
              const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
            height: 4),
        Text(
          title,
          style: TextStyle(
            color:
                Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

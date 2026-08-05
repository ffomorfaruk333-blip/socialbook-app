import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

const supabaseUrl =
    'https://xsxrcrbcxckicskwppmb.supabase.co';

const supabasePublishableKey =
    'sb_publishable_0xGXFjbz404LyFWwWo6kzw_wHUgY0NT';

final supabase = Supabase.instance.client;

// ============================================================
// APP CONSTANTS
// ============================================================

const Color bgColor = Color(0xFF080A0F);
const Color cardColor = Color(0xFF12151C);
const Color inputColor = Color(0xFF181C25);
const Color primaryColor = Color(0xFF7C4DFF);
const Color primaryLight = Color(0xFF9B6DFF);

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const SocialBookApp());
}

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
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgColor,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: false,
        ),

        navigationBarTheme:
            NavigationBarThemeData(
          backgroundColor: Color(0xFF0D1016),
          indicatorColor: Color(0x337C4DFF),
          labelTextStyle:
              WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: cardColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: inputColor,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),
            borderSide: BorderSide.none,
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
  IconData icon, {
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(
      icon,
      color: Colors.grey.shade500,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: inputColor,
    contentPadding:
        const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 17,
    ),
    border: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: primaryLight,
        width: 1.4,
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
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        duration:
            const Duration(seconds: 2),
      ),
    );
}

Widget professionalButton({
  required String text,
  required VoidCallback? onPressed,
  IconData? icon,
  bool loading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor:
            primaryColor,
        disabledBackgroundColor:
            primaryColor.withOpacity(.35),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(17),
        ),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 9),
                ],
                Text(
                  text,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
    ),
  );
}

Widget userAvatar(
  String name, {
  double radius = 22,
}) {
  final letter =
      name.trim().isNotEmpty
          ? name.trim()[0].toUpperCase()
          : 'U';

  return CircleAvatar(
    radius: radius,
    backgroundColor:
        primaryColor,
    child: Text(
      letter,
      style: TextStyle(
        fontSize: radius * .8,
        fontWeight:
            FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}

Widget glassCard({
  required Widget child,
  EdgeInsetsGeometry padding =
      const EdgeInsets.all(16),
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius:
          BorderRadius.circular(20),
      border: Border.all(
        color:
            Colors.white.withOpacity(.05),
      ),
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(.18),
          blurRadius: 18,
          offset:
              const Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
}

// ============================================================
// LOGIN
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  final email =
      TextEditingController();

  final password =
      TextEditingController();

  bool loading = false;
  bool hidden = true;

  Future<void> login() async {
    final e =
        email.text.trim();

    final p =
        password.text;

    if (e.isEmpty || p.isEmpty) {
      message(
        context,
        'Email এবং Password দিন',
      );
      return;
    }

    setState(() =>
        loading = true);

    try {
      await supabase.auth
          .signInWithPassword(
        email: e,
        password: p,
      );
    } on AuthException catch (e) {
      if (mounted) {
        message(
          context,
          e.message,
        );
      }
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Login করা যায়নি',
        );
      }
    } finally {
      if (mounted) {
        setState(() =>
            loading = false);
      }
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
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFF7C4DFF),
                        Color(0xFFB388FF),
                      ],
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(30),
                  ),
                  child:
                      const Icon(
                    Icons
                        .people_alt_rounded,
                    size: 55,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                const Text(
                  'SocialBook',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: -.5,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  'Connect. Share. Discover.',
                  style: TextStyle(
                    color:
                        Colors.grey.shade400,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                TextField(
                  controller: email,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      decoration(
                    'Email',
                    Icons
                        .email_outlined,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextField(
                  controller:
                      password,
                  obscureText:
                      hidden,
                  decoration:
                      decoration(
                    'Password',
                    Icons
                        .lock_outline,
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() =>
                            hidden =
                                !hidden);
                      },
                      icon: Icon(
                        hidden
                            ? Icons
                                .visibility_outlined
                            : Icons
                                .visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                professionalButton(
                  text: 'Login',
                  icon: Icons
                      .login_rounded,
                  loading: loading,
                  onPressed:
                      loading
                          ? null
                          : login,
                ),

                const SizedBox(
                  height: 10,
                ),

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

class SignUpPage
    extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() =>
      _SignUpPageState();
}

class _SignUpPageState
    extends State<SignUpPage> {
  final name =
      TextEditingController();

  final email =
      TextEditingController();

  final password =
      TextEditingController();

  final confirm =
      TextEditingController();

  bool loading = false;
  bool hide1 = true;
  bool hide2 = true;

  Future<void> signup() async {
    final n =
        name.text.trim();

    final e =
        email.text.trim();

    final p =
        password.text;

    final c =
        confirm.text;

    if (n.isEmpty ||
        e.isEmpty ||
        p.isEmpty ||
        c.isEmpty) {
      message(
        context,
        'সব তথ্য পূরণ করুন',
      );
      return;
    }

    if (p.length < 6) {
      message(
        context,
        'Password কমপক্ষে ৬ অক্ষরের হতে হবে',
      );
      return;
    }

    if (p != c) {
      message(
        context,
        'Password মিলছে না',
      );
      return;
    }

    setState(() =>
        loading = true);

    try {
      final result =
          await supabase.auth
              .signUp(
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
            builder: (_) =>
                const MainNavigation(),
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
      if (mounted) {
        message(
          context,
          e.message,
        );
      }
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Signup করা যায়নি',
        );
      }
    } finally {
      if (mounted) {
        setState(() =>
            loading = false);
      }
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
        title:
            const Text('Create Account'),
      ),
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons
                    .person_add_alt_1_rounded,
                size: 80,
                color:
                    primaryLight,
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              TextField(
                controller: name,
                decoration:
                    decoration(
                  'Full Name',
                  Icons
                      .person_outline,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                controller: email,
                keyboardType:
                    TextInputType
                        .emailAddress,
                decoration:
                    decoration(
                  'Email',
                  Icons
                      .email_outlined,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                controller:
                    password,
                obscureText: hide1,
                decoration:
                    decoration(
                  'Password',
                  Icons
                      .lock_outline,
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() =>
                          hide1 =
                              !hide1);
                    },
                    icon: Icon(
                      hide1
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                controller: confirm,
                obscureText: hide2,
                decoration:
                    decoration(
                  'Confirm Password',
                  Icons.lock_reset,
                  suffixIcon:
                      IconButton(
                    onPressed: () {
                      setState(() =>
                          hide2 =
                              !hide2);
                    },
                    icon: Icon(
                      hide2
                          ? Icons
                              .visibility_outlined
                          : Icons
                              .visibility_off_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              professionalButton(
                text: 'Sign Up',
                icon: Icons
                    .person_add_alt_1,
                loading: loading,
                onPressed:
                    loading
                        ? null
                        : signup,
              ),

              TextButton(
                onPressed: () =>
                    Navigator.pop(
                        context),
                child:
                    const Text(
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

class MainNavigation
    extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int index = 0;

  Future<void>
      openCreatePost() async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CreatePostPage(),
      ),
    );

    if (result == true &&
        mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onRefresh: () =>
            setState(() {}),
        onCreatePost:
            openCreatePost,
      ),
      const SearchPage(),
      CreatePostPage(
        onPublished: () {
          setState(() =>
              index = 0);
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

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: index,
        onDestinationSelected:
            (i) {
          setState(() =>
              index = i);
        },
        destinations:
            const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon:
                Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .add_box_outlined,
            ),
            selectedIcon:
                Icon(Icons.add_box),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .notifications_outlined,
            ),
            selectedIcon:
                Icon(
              Icons.notifications,
            ),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .person_outline,
            ),
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

class HomePage
    extends StatefulWidget {
  final VoidCallback? onRefresh;
  final VoidCallback? onCreatePost;

  const HomePage({
    super.key,
    this.onRefresh,
    this.onCreatePost,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {
  bool loading = true;

  List<Map<String, dynamic>>
      posts = [];

  final Set<dynamic> likedPosts =
      {};

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() =>
        loading = true);

    try {
      final data =
          await supabase
              .from('posts')
              .select()
              .order(
                'created_at',
                ascending: false,
              );

      if (!mounted) return;

      setState(() {
        posts =
            List<Map<String,
                dynamic>>.from(data);
      });
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Post load করা যায়নি',
        );
      }
    } finally {
      if (mounted) {
        setState(() =>
            loading = false);
      }
    }
  }

  String get currentName {
    final user =
        supabase.auth.currentUser;

    return user
            ?.userMetadata?[
                'full_name']
            ?.toString() ??
        user?.email
            ?.split('@')
            .first ??
        'User';
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> deletePost(
      dynamic id) async {
    final user =
        supabase.auth.currentUser;

    if (user == null ||
        id == null) {
      return;
    }

    try {
      await supabase
          .from('posts')
          .delete()
          .eq('id', id)
          .eq(
            'user_id',
            user.id,
          );

      await loadPosts();

      if (mounted) {
        message(
          context,
          'Post delete হয়েছে',
        );
      }
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Delete করা যায়নি',
        );
      }
    }
  }

  Future<void> sharePost(
      Map<String, dynamic>
          post) async {
    final content =
        post['content']
                ?.toString() ??
            '';

    try {
      await SharePlus.instance
          .share(
        ShareParams(
          text:
              'SocialBook Post\n\n$content\n\nShared from SocialBook',
          subject:
              'SocialBook Post',
        ),
      );
    } catch (e) {
      if (mounted) {
        message(
          context,
          'Share করা যায়নি',
        );
      }
    }
  }

  void toggleLike(dynamic id) {
    if (id == null) return;

    setState(() {
      if (likedPosts.contains(id)) {
        likedPosts.remove(id);
      } else {
        likedPosts.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SocialBook',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                widget.onCreatePost,
            icon: const Icon(
              Icons
                  .add_circle_outline,
            ),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadPosts,
        child: loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.only(
                  top: 12,
                  bottom: 30,
                ),
                children: [
                  createPostBox(),

                  const SizedBox(
                    height: 14,
                  ),

                  if (posts.isEmpty)
                    glassCard(
                      padding:
                          const EdgeInsets
                              .all(40),
                      child:
                          const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons
                                  .post_add_outlined,
                              size: 50,
                              color:
                                  Colors.grey,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              'এখনও কোনো Post নেই',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                                fontSize:
                                    16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...posts.map(
                      (post) =>
                          postCard(post),
                    ),
                ],
              ),
      ),
    );
  }

  Widget createPostBox() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: glassCard(
        child: InkWell(
          onTap:
              widget.onCreatePost,
          borderRadius:
              BorderRadius.circular(
                  16),
          child: Row(
            children: [
              userAvatar(
                currentName,
                radius: 23,
              ),
              const SizedBox(
                width: 12,
              ),
              const Expanded(
                child: Text(
                  "What's on your mind?",
                  style:
                      TextStyle(
                    color:
                        Colors.grey,
                    fontSize:
                        15,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets
                        .all(10),
                decoration:
                    BoxDecoration(
                  color: primaryColor
                      .withOpacity(.15),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .edit_outlined,
                  color:
                      primaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget postCard(
      Map<String, dynamic>
          post) {
    final user =
        supabase.auth.currentUser;

    final ownerId =
        post['user_id']
            ?.toString();

    final mine =
        user != null &&
            ownerId == user.id;

    final content =
        post['content']
                ?.toString() ??
            '';

    String author =
        'SocialBook User';

    if (mine) {
      author =
          user?.userMetadata?[
                  'full_name']
              ?.toString() ??
          user?.email
              ?.split('@')
              .first ??
          'You';
    }

    final liked =
        likedPosts.contains(
            post['id']);

    return Padding(
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      child: glassCard(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                userAvatar(author),

                const SizedBox(
                  width: 10,
                ),

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
                          fontSize:
                              16,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons
                                .public,
                            size: 13,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            'Public',
                            style:
                                TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                              fontSize:
                                  12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (mine)
                  PopupMenuButton<
                      String>(
                    onSelected:
                        (value) {
                      if (value ==
                          'delete') {
                        deletePost(
                          post['id'],
                        );
                      }
                    },
                    itemBuilder:
                        (_) =>
                            const [
                      PopupMenuItem(
                        value:
                            'delete',
                        child:
                            Row(
                          children: [
                            Icon(
                              Icons
                                  .delete_outline,
                              color:
                                  Colors.redAccent,
                            ),
                            SizedBox(
                              width:
                                  8,
                            ),
                            Text(
                                'Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              content,
              style:
                  const TextStyle(
                fontSize: 16,
                height: 1.55,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Divider(
              color: Colors.white
                  .withOpacity(.06),
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      toggleLike(
                          post['id']),
                  icon: Icon(
                    liked
                        ? Icons
                            .favorite
                        : Icons
                            .favorite_border,
                    color: liked
                        ? Colors
                            .redAccent
                        : Colors.grey,
                  ),
                  label: Text(
                    liked
                        ? 'Liked'
                        : 'Like',
                    style:
                        TextStyle(
                      color: liked
                          ? Colors
                              .redAccent
                          : Colors.grey,
                    ),
                  ),
                ),

                TextButton.icon(
                  onPressed: () =>
                      showComments(
                    post['id'],
                  ),
                  icon:
                      const Icon(
                    Icons
                        .comment_outlined,
                  ),
                  label:
                      const Text(
                    'Comment',
                  ),
                ),

                TextButton.icon(
                  onPressed: () =>
                      sharePost(post),
                  icon:
                      const Icon(
                    Icons
                        .share_outlined,
                  ),
                  label:
                      const Text(
                    'Share',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showComments(
      dynamic postId) {
    if (postId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          cardColor,
      builder: (_) {
        return CommentSheet(
          postId: postId,
        );
      },
    );
  }
}

// ============================================================
// CREATE POST
// ============================================================

class CreatePostPage
    extends StatefulWidget {
  final VoidCallback? onPublished;

  const CreatePostPage({
    super.key,
    this.onPublished,
  });

  @override
  State<CreatePostPage>
      createState() =>
          _CreatePostPageState();
}

class _CreatePostPageState
    extends State<CreatePostPage> {
  final controller =
      TextEditingController();

  bool publishing = false;

  Future<void> publish() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) {
      message(
        context,
        'Post লিখুন',
      );
      return;
    }

    final user =
        supabase.auth.currentUser;

    if (user == null) {
      message(
        context,
        'আগে Login করুন',
      );
      return;
    }

    setState(() =>
        publishing = true);

    try {
      await supabase
          .from('posts')
          .insert({
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

      Navigator.pop(
        context,
        true,
      );
    } on PostgrestException catch (e) {
      if (mounted) {
        message(
          context,
          'Database error: ${e.message}',
        );
      }
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Post করা যায়নি',
        );
      }
    } finally {
      if (mounted) {
        setState(() =>
            publishing = false);
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
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
              right: 12,
            ),
            child:
                FilledButton(
              onPressed:
                  publishing
                      ? null
                      : publish,
              child: Text(
                publishing
                    ? '...'
                    : 'Post',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical:
                      TextAlignVertical
                          .top,
                  style:
                      const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        "What's on your mind?",
                    filled: true,
                    fillColor:
                        inputColor,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                      borderSide:
                          BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets
                            .all(20),
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              professionalButton(
                text: publishing
                    ? 'Publishing...'
                    : 'Publish Post',
                icon:
                    Icons.send_rounded,
                loading:
                    publishing,
                onPressed:
                    publishing
                        ? null
                        : publish,
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

class CommentSheet
    extends StatefulWidget {
  final dynamic postId;

  const CommentSheet({
    super.key,
    required this.postId,
  });

  @override
  State<CommentSheet>
      createState() =>
          _CommentSheetState();
}

class _CommentSheetState
    extends State<CommentSheet> {
  final controller =
      TextEditingController();

  List<Map<String, dynamic>>
      comments = [];

  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final data =
          await supabase
              .from('comments')
              .select()
              .eq(
                'post_id',
                widget.postId,
              )
              .order(
                'created_at',
                ascending: true,
              );

      if (!mounted) return;

      setState(() {
        comments =
            List<Map<String,
                dynamic>>.from(data);
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() =>
            loading = false);
      }
    }
  }

  Future<void> addComment() async {
    final text =
        controller.text.trim();

    final user =
        supabase.auth.currentUser;

    if (text.isEmpty ||
        user == null) {
      return;
    }

    setState(() =>
        sending = true);

    try {
      await supabase
          .from('comments')
          .insert({
        'post_id':
            widget.postId,
        'user_id':
            user.id,
        'content': text,
      });

      controller.clear();

      await loadComments();
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Comment করা যায়নি',
        );
      }
    } finally {
      if (mounted) {
        setState(() =>
            sending = false);
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
            MediaQuery.of(context)
                    .size
                    .height *
                .78,
        child: Padding(
          padding:
              const EdgeInsets.all(
            18,
          ),
          child: Column(
            children: [
              Container(
                width: 45,
                height: 5,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade700,
                  borderRadius:
                      BorderRadius
                          .circular(10),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

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
                height: 15,
              ),

              Expanded(
                child: loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : comments
                            .isEmpty
                        ? const Center(
                            child:
                                Text(
                              'No comments yet',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          )
                        : ListView
                            .builder(
                            itemCount:
                                comments
                                    .length,
                            itemBuilder:
                                (_, i) {
                              final text =
                                  comments[i]['content']
                                          ?.toString() ??
                                      '';

                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom:
                                      10,
                                ),
                                child:
                                    Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    userAvatar(
                                      'User',
                                      radius:
                                          19,
                                    ),
                                    const SizedBox(
                                      width:
                                          10,
                                    ),
                                    Expanded(
                                      child:
                                          Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal:
                                              14,
                                          vertical:
                                              11,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              inputColor,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            16,
                                          ),
                                        ),
                                        child:
                                            Text(
                                          text,
                                          style:
                                              const TextStyle(
                                            height:
                                                1.35,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        TextField(
                      controller:
                          controller,
                      textInputAction:
                          TextInputAction
                              .send,
                      onSubmitted:
                          (_) =>
                              addComment(),
                      decoration:
                          decoration(
                        'Write a comment...',
                        Icons
                            .chat_bubble_outline,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  IconButton.filled(
                    onPressed:
                        sending
                            ? null
                            : addComment,
                    style:
                        IconButton
                            .styleFrom(
                      backgroundColor:
                          primaryColor,
                    ),
                    icon:
                        const Icon(
                      Icons.send,
                    ),
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

class SearchPage
    extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage>
      createState() =>
          _SearchPageState();
}

class _SearchPageState
    extends State<SearchPage> {
  final controller =
      TextEditingController();

  List<Map<String, dynamic>>
      results = [];

  bool loading = false;

  Future<void> search() async {
    final q =
        controller.text.trim();

    if (q.isEmpty) {
      return;
    }

    setState(() =>
        loading = true);

    try {
      final data =
          await supabase
              .from('posts')
              .select()
              .ilike(
                'content',
                '%$q%',
              )
              .order(
                'created_at',
                ascending: false,
              );

      if (!mounted) return;

      setState(() {
        results =
            List<Map<String,
                dynamic>>.from(data);
      });
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Search error',
        );
      }
    } finally {
      if (mounted) {
        setState(() =>
            loading = false);
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
              controller:
                  controller,
              onSubmitted: (_) =>
                  search(),
              decoration:
                  decoration(
                'Search posts...',
                Icons.search,
                suffixIcon:
                    IconButton(
                  onPressed: search,
                  icon: const Icon(
                    Icons
                        .arrow_forward_rounded,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

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
                            style:
                                TextStyle(
                              color:
                                  Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              results.length,
                          itemBuilder:
                              (_, i) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    10,
                              ),
                              child:
                                  glassCard(
                                child:
                                    Text(
                                  results[i]['content']
                                          ?.toString() ??
                                      '',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        15,
                                    height:
                                        1.5,
                                  ),
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
  const NotificationsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Notifications',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(12),
        children: [
          glassCard(
            child: const ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading:
                  CircleAvatar(
                backgroundColor:
                    primaryColor,
                child: Icon(
                  Icons
                      .celebration_rounded,
                ),
              ),
              title: Text(
                'Welcome to SocialBook 🎉',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Your account is ready',
              ),
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

class ProfilePage
    extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage>
      createState() =>
          _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {
  String get name {
    final user =
        supabase.auth.currentUser;

    return user
            ?.userMetadata?[
                'full_name']
            ?.toString() ??
        user?.email
            ?.split('@')
            .first ??
        'SocialBook User';
  }

  String get email {
    return supabase.auth
            .currentUser
            ?.email ??
        '';
  }

  Future<void> editName() async {
    final controller =
        TextEditingController(
      text: name,
    );

    final value =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text(
            'Edit Name',
          ),
          content:
              TextField(
            controller:
                controller,
            decoration:
                const InputDecoration(
              hintText:
                  'Your name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                controller
                    .text
                    .trim(),
              ),
              child:
                  const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value == null ||
        value.isEmpty) {
      return;
    }

    try {
      await supabase.auth
          .updateUser(
        UserAttributes(
          data: {
            'full_name':
                value,
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
    } catch (_) {
      if (mounted) {
        message(
          context,
          'Profile update করা যায়নি',
        );
      }
    }
  }

  Future<void> logout() async {
    await supabase.auth
        .signOut();
  }

  @override
  Widget build(BuildContext context) {
    final letter =
        name.isNotEmpty
            ? name[0]
                .toUpperCase()
            : 'U';

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
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
            height: 20,
          ),

          Center(
            child:
                userAvatar(
              name,
              radius: 60,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

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
            height: 7,
          ),

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
            height: 30,
          ),

          glassCard(
            padding:
                EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .edit_outlined,
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
                  onTap:
                      editName,
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
                  onTap: () {
                    message(
                      context,
                      'Settings আসছে',
                    );
                  },
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .logout_rounded,
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
                  onTap:
                      logout,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 35,
          ),

          const Center(
            child: Text(
              'SocialBook',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          const Center(
            child: Text(
              'Creator: Omor Faruk',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

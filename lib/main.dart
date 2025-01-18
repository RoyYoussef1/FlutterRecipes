import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:math';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cooking Recipe App',
      home: MyHomePage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard': (context) => DashboardPage(),
        '/predict': (context) => PredictPage(),
        '/add-recipe': (context) => AddRecipePage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'Welcome',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to the Recipe Generator Book',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                _buildHomePageButton(
                  context,
                  label: 'Login',
                  icon: Icons.login,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                SizedBox(height: 20),
                _buildHomePageButton(
                  context,
                  label: 'Register',
                  icon: Icons.app_registration,
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomePageButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: onPressed,
    );
  }
}

class DashboardPage extends StatelessWidget {
  void _showQuitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quit App'),
          content: Text('Are you sure you want to quit?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 200), () {
                  SystemNavigator.pop();
                });
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context) {
    final TextEditingController _reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int _selectedRating = 0;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Review App',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rate your experience:'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: index < _selectedRating
                              ? Colors.amber
                              : Colors.grey,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('access_token');

                    if (token == null || token.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Authorization token is missing. Please log in again.'),
                        ),
                      );
                      return;
                    }

                    final email =
                        prefs.getString('user_email') ?? 'user@example.com';
                    final now = DateTime.now().toIso8601String();

                    final reviewData = {
                      "content": _reviewController.text.trim(),
                      "created_at": now,
                    };

                    try {
                      final response = await http.post(
                        Uri.parse(
                            'http://10.0.2.2:8001/save-review/?email=$email'),
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer $token",
                        },
                        body: jsonEncode(reviewData),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Review submitted successfully!')),
                        );
                        Navigator.of(context).pop(); // Close the dialog
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Failed to submit review: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, $name!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 30),
                _buildDashboardButton(
                  context,
                  label: 'Generate Recipe',
                  icon: Icons.insights,
                  onPressed: () => Navigator.pushNamed(context, '/predict'),
                ),
                _buildDashboardButton(
                  context,
                  label: 'Add Recipe',
                  icon: Icons.add_circle,
                  onPressed: () => Navigator.pushNamed(context, '/add-recipe'),
                ),
                _buildDashboardButton(
                  context,
                  label: 'Review App',
                  icon: Icons.feedback,
                  onPressed: () => _showReviewDialog(context),
                ),
                _buildDashboardButton(
                  context,
                  label: 'Quit',
                  icon: Icons.exit_to_app,
                  color: Colors.red,
                  onPressed: () => _showQuitConfirmation(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed,
      Color color = Colors.white}) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon,
            size: 30, color: color == Colors.white ? Colors.purple : color),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color == Colors.white ? Colors.black : color,
          ),
        ),
        onTap: onPressed,
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Please login to your account',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 40),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      hint: 'Enter your name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Login')),
                          );

                          final requestBody = {
                            "email": _emailController.text.trim(),
                            "name": _nameController.text.trim(),
                            "password": _passwordController.text,
                            "embedding": [0],
                          };

                          try {
                            final response = await http.post(
                              Uri.parse('http://10.0.2.2:8001/login/'),
                              headers: {
                                "Content-Type": "application/json",
                              },
                              body: jsonEncode(requestBody),
                            );

                            if (response.statusCode == 200) {
                              final responseData = jsonDecode(response.body);
                              final accessToken = responseData['access_token'];

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                  'access_token', accessToken);
                              await prefs.setString(
                                  'email', _emailController.text);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login Successful')),
                              );

                              Navigator.pushReplacementNamed(
                                context,
                                '/dashboard',
                                arguments: _nameController.text,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Login Failed: ${response.body}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.purple),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            errorStyle: TextStyle(color: Colors.redAccent),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Please fill the form to register',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 40),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      hint: 'Enter your name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Processing Registration')),
                          );

                          final requestBody = {
                            "email": _emailController.text.trim(),
                            "name": _nameController.text.trim(),
                            "password": _passwordController.text,
                          };

                          try {
                            final response = await http.post(
                              Uri.parse('http://10.0.2.2:8001/signup/'),
                              headers: {
                                "Content-Type": "application/json",
                              },
                              body: jsonEncode(requestBody),
                            );

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Registration Successful')),
                              );
                              Navigator.pushReplacementNamed(context, '/login');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Failed to Register: ${response.body}')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        errorStyle: TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}

class PredictPage extends StatefulWidget {
  @override
  _PredictPageState createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();
  final TextEditingController cookTimeController = TextEditingController();

  List<String> cuisines = [];
  List<String> courses = [];
  List<String> diets = [];
  List<String> ingredients = [];

  Set<String> selectedCuisines = {};
  Set<String> selectedCourses = {};
  Set<String> selectedDiets = {};
  Set<String> selectedIngredients = {};

  String? email;
  String? image;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEmail(); // Load email from SharedPreferences
    fetchDropdownData(); // Fetch dropdown data
  }

  Future<void> loadEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
    });
  }

  Future<void> sendPredictRequest() async {
    if (email == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Email not found in shared preferences."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final predictData = {
      "email": email,
      "title_text": titleController.text,
      "prep_time": prepTimeController.text,
      "cook_time": cookTimeController.text,
      "selected_cuisines": selectedCuisines.toList(), // Convert Set to List
      "selected_courses": selectedCourses.toList(), // Convert Set to List
      "selected_diets": selectedDiets.toList(), // Convert Set to List
      "selected_ingredients":
          selectedIngredients.toList(), // Convert Set to List
      "image": "",
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8001/predict/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(predictData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final details = jsonDecode(responseData["details"]);

        // Extract recipes
        List<Map<String, dynamic>> recipes = [];
        int count = (details["id"] as Map).length;

        for (int i = 0; i < count; i++) {
          final recipe = {
            "id": details["id"]["$i"],
            "title": details["title"]["$i"],
            "ingredients": details["ingredients"]["$i"],
            "instructions": details["instructions"]["$i"],
            "prep_time": details["prep_time"]["$i"],
            "cook_time": details["cook_time"]["$i"],
            "cuisine": details["cuisine"]["$i"],
            "course": details["course"]["$i"],
            "diet": details["diet"]["$i"],
            "url": details["url"]["$i"],
            "similarity": details["similarity"]["$i"],
          };
          recipes.add(recipe);
        }

        // Navigate to the RecipesPage with the recipes list
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipesPage(recipes: recipes),
          ),
        );
      } else {
        throw Exception("Failed to get a valid response: ${response.body}");
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8001/dropdown-data/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          cuisines = List<String>.from(data['cuisines']);
          courses = List<String>.from(data['courses']);
          diets = List<String>.from(data['diets']);
          ingredients = List<String>.from(data['ingredients']);
          isLoading = false; // Data loading complete
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading even on error
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget buildSearchableDropdown(
      String label, List<String> items, Set<String> selectedItems) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredItems = List.from(items);
    bool isDropdownOpen = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                setState(() {
                  isDropdownOpen = !isDropdownOpen;
                  if (!isDropdownOpen) {
                    searchController.clear();
                    filteredItems = List.from(items);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "DropDown $label",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Icon(isDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            if (isDropdownOpen)
              Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search $label",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredItems = items
                            .where((item) => item
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView(
                      shrinkWrap: true,
                      children: filteredItems.map((item) {
                        return ListTile(
                          title: Text(
                            item,
                            style: TextStyle(fontSize: 16),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          onTap: () {
                            setState(() {
                              selectedItems.add(item); // Ensure adding to Set
                              isDropdownOpen = false; // Close dropdown
                              searchController.clear();
                              filteredItems = List.from(items);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            Wrap(
              spacing: 8.0,
              children: selectedItems.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: () => setState(() {
                    selectedItems.remove(item); // Ensure removing from Set
                  }),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: prepTimeController,
                      decoration: InputDecoration(labelText: 'Prep Time'),
                    ),
                    TextField(
                      controller: cookTimeController,
                      decoration: InputDecoration(labelText: 'Cook Time'),
                    ),
                    SizedBox(height: 20),
                    buildSearchableDropdown(
                        "Cuisines", cuisines, selectedCuisines),
                    buildSearchableDropdown(
                        "Courses", courses, selectedCourses),
                    buildSearchableDropdown("Diets", diets, selectedDiets),
                    buildSearchableDropdown(
                        "Ingredients", ingredients, selectedIngredients),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: sendPredictRequest,
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for other fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  // Dropdown data
  List<String> _cuisines = [];
  List<String> _courses = [];
  List<String> _diets = [];
  List<String> _ingredients = [];

  // Selected values
  List<String> _selectedCuisines = [];
  List<String> _selectedCourses = [];
  List<String> _selectedDiets = [];
  List<String> _selectedIngredients = [];
  List<String> _instructions = []; // List to store added instructions

  bool _instructionError = false; // Track error for instructions

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8001/dropdown-data/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _cuisines = List<String>.from(data['cuisines']);
          _courses = List<String>.from(data['courses']);
          _diets = List<String>.from(data['diets']);
          _ingredients = List<String>.from(data['ingredients']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch dropdown data: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dropdown data: $e')),
      );
    }
  }

  void _addInstruction() {
    final instruction = _instructionController.text.trim();
    if (instruction.isNotEmpty) {
      setState(() {
        _instructions.add(instruction);
        _instructionController.clear();
        _instructionError = false; // Clear error on valid input
      });
    }
  }

  void _removeInstruction(String instruction) {
    setState(() {
      _instructions.remove(instruction);
    });
  }

  Future<void> _submitRecipe() async {
    setState(() {
      _instructionError = _instructions.isEmpty; // Check instruction validity
    });
    int newId;
    Random random = Random();
    newId = random.nextInt(1000000);
    if (_formKey.currentState!.validate() && !_instructionError) {
      final recipeData = {
        "id": newId,
        "title": _titleController.text,
        "ingredients": _selectedIngredients,
        "instructions": _instructions,
        "prep_time": int.tryParse(_prepTimeController.text) ?? 0,
        "cook_time": int.tryParse(_cookTimeController.text) ?? 0,
        "cuisine":
            _selectedCuisines.join(','), // Join as a comma-separated string
        "course":
            _selectedCourses.join(','), // Join as a comma-separated string
        "diet": _selectedDiets.join(','), // Join as a comma-separated string
        "image": _imageController.text,
        "url": _urlController.text,
      };

      try {
        // Retrieve token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Authorization token is missing. Please log in again.')),
          );
          return;
        }

        // Make POST request
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8001/add-recipe/'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(recipeData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Recipe added successfully!')),
          );

          // Reset fields and selected items
          _formKey.currentState!.reset();
          setState(() {
            _selectedCuisines.clear();
            _selectedCourses.clear();
            _selectedDiets.clear();
            _selectedIngredients.clear();
            _instructions.clear(); // Clear instructions
          });

          // Navigate back to the dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add recipe: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding recipe: $e')),
        );
      }
    }
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required String errorMessage,
  }) {
    return DropdownSearch<String>.multiSelection(
      items: items,
      selectedItems: selectedItems,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(labelText: label),
      ),
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(hintText: "Search $label"),
        ),
      ),
      onChanged: (List<String> value) {
        setState(() {
          selectedItems.clear();
          selectedItems.addAll(value);
        });
      },
      validator: (value) {
        if (selectedItems.isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                label: 'Cuisines',
                items: _cuisines,
                selectedItems: _selectedCuisines,
                errorMessage: 'Please select at least one cuisine',
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                label: 'Courses',
                items: _courses,
                selectedItems: _selectedCourses,
                errorMessage: 'Please select at least one course',
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                label: 'Diets',
                items: _diets,
                selectedItems: _selectedDiets,
                errorMessage: 'Please select at least one diet',
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                label: 'Ingredients',
                items: _ingredients,
                selectedItems: _selectedIngredients,
                errorMessage: 'Please select at least one ingredient',
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _instructionController,
                decoration: InputDecoration(labelText: 'Add Instruction'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _addInstruction,
                child: Text('Add Instruction'),
              ),
              SizedBox(height: 16),
              if (_instructions.isNotEmpty) ...[
                Text(
                  'Instructions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Column(
                  children: _instructions
                      .map(
                        (instruction) => ListTile(
                          title: Text(instruction),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeInstruction(instruction),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (_instructionError)
                Text(
                  'Please add at least one instruction',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16),
              TextFormField(
                controller: _prepTimeController,
                decoration: InputDecoration(labelText: 'Prep Time (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Prep time is required'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cookTimeController,
                decoration: InputDecoration(labelText: 'Cook Time (minutes)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Cook time is required'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Image URL is required'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(labelText: 'Recipe URL'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Recipe URL is required'
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRecipe,
                child: Text('Submit Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipesPage extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;

  const RecipesPage({Key? key, required this.recipes}) : super(key: key);

  Future<void> _submitFeedback(
      BuildContext context, String comment, double rating) async {
    try {
      // Retrieve user email (stored during login)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final email = prefs.getString('user_email') ??
          'user@example.com'; // Replace with actual email retrieval

      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Authorization token is missing. Please log in again.")),
        );
        return;
      }

      // Gather feedback data
      final feedbackData = {
        "email": email,
        "input_description": "Predicted Recipes",
        "input_image": "", // Empty for now
        "recipe_ids": recipes.map((recipe) => recipe["id"]).toList(),
        "rating": rating.toInt(),
        "comment": comment,
        "created_at": DateTime.now().toIso8601String(),
      };

      // Send POST request
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8001/submit-feedback/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Include token
        },
        body: jsonEncode(feedbackData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Feedback submitted successfully!")),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to submit feedback: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _openFeedbackDialog(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    double selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Submit Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Rate your experience:"),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                selectedRating = rating;
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Comment",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedRating > 0 && commentController.text.isNotEmpty) {
                _submitFeedback(
                    context, commentController.text, selectedRating);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Please provide a rating and comment")),
                );
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Predicted Recipes"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(recipe["title"] ?? "No Title"),
                    subtitle: Text(
                        "Cuisine: ${recipe["cuisine"] ?? "N/A"}\nCourse: ${recipe["course"] ?? "N/A"}"),
                    onTap: () {
                      // Navigate to RecipeDetailPage when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _openFeedbackDialog(context),
              child: Text("Submit Feedback"),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe["title"] ?? "Recipe Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Title: ${recipe["title"]}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Cuisine: ${recipe["cuisine"] ?? "N/A"}"),
              Text("Course: ${recipe["course"] ?? "N/A"}"),
              Text("Diet: ${recipe["diet"] ?? "N/A"}"),
              Text("Prep Time: ${recipe["prep_time"]} mins"),
              Text("Cook Time: ${recipe["cook_time"]} mins"),
              SizedBox(height: 16),
              Text("Ingredients:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...(recipe["ingredients"] as List<dynamic>)
                  .map((ingredient) => Text("- $ingredient"))
                  .toList(),
              SizedBox(height: 16),
              Text("Instructions:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...(recipe["instructions"] as List<dynamic>)
                  .map((instruction) => Text("• $instruction"))
                  .toList(),
              if (recipe["url"] != null) ...[
                SizedBox(height: 16),
                Text("Recipe URL:"),
                Text(recipe["url"], style: TextStyle(color: Colors.blue)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:math';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome App',
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
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Welcome to the Recipe Generator Book',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Welcome'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to the Recipe Generator Book',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Login'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: Text('Register'),
          ),
        ],
      ),
    ),
  );
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

  @override
  Widget build(BuildContext context) {
    final String name =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Personalized greeting
            Text(
              'Hello, $name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            // Predict Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/predict');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Predict',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            // Add Recipe Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-recipe');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add Recipe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            // Quit Button
            ElevatedButton(
              onPressed: () {
                _showQuitConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Quit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
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
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Show a SnackBar while processing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Login')),
                    );

                    // Construct the request body
                    final Map<String, dynamic> requestBody = {
                      "email": _emailController.text,
                      "name": _nameController.text,
                      "password": _passwordController.text,
                      "embedding": [0], // Placeholder for embedding
                    };

                    try {
                      // Send POST request
                      final response = await http.post(
                        Uri.parse('http://10.0.2.2:8001/login/'),
                        headers: {
                          "Content-Type": "application/json",
                        },
                        body: jsonEncode(requestBody),
                      );

                      if (response.statusCode == 200) {
                        // Parse response
                        final responseData = jsonDecode(response.body);
                        final accessToken = responseData['access_token'];

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('access_token', accessToken);
                        await prefs.setString('email', _emailController.text);
                        // Print token
                        print('Access Token: $accessToken');

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
                              content: Text('Login Failed: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
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
        title: Text('Register Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Show a SnackBar while processing

                    // Construct the request body
                    final Map<String, dynamic> requestBody = {
                      "email": _emailController.text,
                      "name": _nameController.text,
                      "password": _passwordController.text,
                    };

                    try {
                      // Send POST request
                      final response = await http.post(
                        Uri.parse('http://10.0.2.2:8001/signup/'),
                        headers: {
                          "Content-Type": "application/json",
                        },
                        body: jsonEncode(requestBody),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Registration Successful')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to Register: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
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
      "selected_ingredients": selectedIngredients.toList(), // Convert Set to List
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Response"),
            content: Text(responseData.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
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
      final response = await http.get(Uri.parse('http://10.0.2.2:8001/dropdown-data/'));

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
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    Icon(isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
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
                            .where((item) =>
                                item.toLowerCase().contains(value.toLowerCase()))
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
            ? Center(child: CircularProgressIndicator()) // Show loading indicator
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
                    buildSearchableDropdown("Cuisines", cuisines, selectedCuisines),
                    buildSearchableDropdown("Courses", courses, selectedCourses),
                    buildSearchableDropdown("Diets", diets, selectedDiets),
                    buildSearchableDropdown("Ingredients", ingredients, selectedIngredients),
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

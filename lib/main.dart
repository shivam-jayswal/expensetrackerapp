import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entry Point
void main() {
  runApp(MyApp());
}

// Main Application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.grey, // Changed to grey
        scaffoldBackgroundColor: Color(0xFF121212),
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme), // Using Google Fonts
        appBarTheme: AppBarTheme(
          color: Colors.grey, // Changed to grey
          titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black87,
          selectedItemColor: Colors.grey[400], // Changed to grey
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: LoginScreen(),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Handle login
  void _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedPassword = prefs.getString(email); // Get password for the email

      if (savedPassword != null && savedPassword == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(email: email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid login credentials")));
      }
    }
  }

  // Navigate to the signup screen
  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              style: GoogleFonts.lato(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black26,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: GoogleFonts.lato(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black26,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]), // Changed to grey
              child: Text('Login', style: GoogleFonts.lato(color: Colors.white)),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _navigateToSignup,
              child: Text('Don’t have an account? Sign up', style: GoogleFonts.lato(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Signup Screen
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Handle signup
  void _handleSignup() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool emailExists = prefs.containsKey(email); // Check if email already exists

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email already exists")));
      } else {
        // Save email and password in SharedPreferences
        prefs.setString(email, password);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account created successfully")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              style: GoogleFonts.lato(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black26,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: GoogleFonts.lato(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black26,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignup,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]), // Changed to grey
              child: Text('Sign Up', style: GoogleFonts.lato(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  final String email;
  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double cashBalance = 0.0;
  double bankAccountBalance = 0.0;
  List<Map<String, dynamic>> transactionHistory = [];

  void _addExpense(double amount, String description, String mode, String type) {
    setState(() {
      if (type == 'incoming') {
        totalBalance += amount;
        totalIncome += amount;
        if (mode == 'cash') {
          cashBalance += amount;
        } else if (mode == 'account') {
          bankAccountBalance += amount;
        }
      } else {
        totalBalance -= amount;
        totalExpense += amount;
        if (mode == 'cash') {
          cashBalance -= amount;
        } else if (mode == 'account') {
          bankAccountBalance -= amount;
        }
      }

      transactionHistory.add({
        'description': description,
        'amount': amount,
        'mode': mode,
        'type': type,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle Logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Balance Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Card(
                  color: Colors.black54,
                  child: ListTile(
                    title: Text('Total Balance', style: GoogleFonts.lato(color: Colors.white)),
                    trailing: Text('₹$totalBalance', style: GoogleFonts.lato(color: Colors.white)),
                  ),
                ),
                Card(
                  color: Colors.black54,
                  child: ListTile(
                    title: Text('Total Incoming', style: GoogleFonts.lato(color: Colors.white)),
                    trailing: Text('₹$totalIncome', style: GoogleFonts.lato(color: Colors.white)),
                  ),
                ),
                Card(
                  color: Colors.black54,
                  child: ListTile(
                    title: Text('Total Outgoing', style: GoogleFonts.lato(color: Colors.white)),
                    trailing: Text('₹$totalExpense', style: GoogleFonts.lato(color: Colors.white)),
                  ),
                ),
                Card(
                  color: Colors.black54,
                  child: ListTile(
                    title: Text('Cash Balance', style: GoogleFonts.lato(color: Colors.white)),
                    trailing: Text('₹$cashBalance', style: GoogleFonts.lato(color: Colors.white)),
                  ),
                ),
                Card(
                  color: Colors.black54,
                  child: ListTile(
                    title: Text('Account Balance', style: GoogleFonts.lato(color: Colors.white)),
                    trailing: Text('₹$bankAccountBalance', style: GoogleFonts.lato(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),

          // Transaction History
          Expanded(
            child: ListView.builder(
              itemCount: transactionHistory.length,
              itemBuilder: (context, index) {
                var transaction = transactionHistory[index];
                return Card(
                  color: Colors.black54,
                  child: ListTile(
                    title: Text(transaction['description'], style: GoogleFonts.lato(color: Colors.white)),
                    subtitle: Text(
                        '${transaction['type']} - ₹${transaction['amount']} - ${transaction['mode']}',
                        style: GoogleFonts.lato(color: Colors.white70)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddExpenseDialog(
                onSubmit: _addExpense,
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.grey[400], // Changed to grey
      ),
    );
  }
}

// Add Expense Dialog
class AddExpenseDialog extends StatefulWidget {
  final Function(double, String, String, String) onSubmit;

  AddExpenseDialog({required this.onSubmit});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _mode = 'cash';
  String _type = 'outgoing';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Amount TextField with white text
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.lato(color: Colors.white), // White text color
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white70), // Light white label color
            ),
          ),
          SizedBox(height: 10),
          // Description TextField with white text
          TextField(
            controller: _descriptionController,
            style: GoogleFonts.lato(color: Colors.white), // White text color
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: Colors.white70), // Light white label color
            ),
          ),
          SizedBox(height: 10),
          // Mode Dropdown with capitalized first letter
          DropdownButton<String>(
            value: _mode,
            onChanged: (String? newValue) {
              setState(() {
                _mode = newValue!;
              });
            },
            items: <String>['cash', 'account']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value[0].toUpperCase() + value.substring(1), // Capitalizing first letter
                  style: GoogleFonts.lato(color: Colors.white), // White text color
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          // Type Dropdown with capitalized first letter
          DropdownButton<String>(
            value: _type,
            onChanged: (String? newValue) {
              setState(() {
                _type = newValue!;
              });
            },
            items: <String>['incoming', 'outgoing']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value[0].toUpperCase() + value.substring(1), // Capitalizing first letter
                  style: GoogleFonts.lato(color: Colors.white), // White text color
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: GoogleFonts.lato(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            double amount = double.parse(_amountController.text);
            String description = _descriptionController.text;
            widget.onSubmit(amount, description, _mode, _type);
            Navigator.of(context).pop();
          },
          child: Text('Add', style: GoogleFonts.lato(color: Colors.grey)),
        ),
      ],
    );
  }
}

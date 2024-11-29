import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Code Executor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200], // Add background color
      ),
      home: PythonCodeExecutor(),
    );
  }
}

class PythonCodeExecutor extends StatefulWidget {
  @override
  _PythonCodeExecutorState createState() => _PythonCodeExecutorState();
}

class _PythonCodeExecutorState extends State<PythonCodeExecutor> {
  final TextEditingController _controller = TextEditingController();
  String _output = '';
  bool _isLoading = false;

  Future<void> _executeCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/execute'), // Flask backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': _controller.text}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _output = json.decode(response.body)['output'] ?? 'No output';
        });
      } else {
        setState(() {
          _output = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _output = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Python Code Executor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter Python Code:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Write Python code here...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _executeCode,
                  icon: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Icon(Icons.send),
                  label: Text(_isLoading ? '' : 'Run'),
                ),
                ElevatedButton.icon(
                  onPressed: _clear,
                  icon: Icon(Icons.clear),
                  label: Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Output:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: Card(
                elevation: 2,
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: SingleChildScrollView(
                    child: Text(
                      _output,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
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
}

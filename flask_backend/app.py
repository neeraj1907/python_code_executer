from flask import Flask, request, jsonify
from flask_cors import CORS
import sys
from io import StringIO

app = Flask(__name__)
CORS(app)


@app.route('/')
def home():
    return "Python Code Executor API is running. Use POST /execute to run Python code."

@app.route('/execute', methods=['POST'])
def execute_code():
    try:
        
        code = request.json.get('code', '')
        
        
        old_stdout = sys.stdout
        new_stdout = StringIO()
        sys.stdout = new_stdout

        
        exec(code)

        
        output = new_stdout.getvalue()

        
        sys.stdout = old_stdout

        return jsonify({'output': output})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)

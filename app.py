from flask import Flask, jsonify, render_template
import requests
import random

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/liveness')
def liveness():
    return jsonify({"status": "Application is live!"}), 200

@app.route('/colors')
def colors_page():
    return render_template('colors.html')

@app.route('/generate-colors', methods=['GET'])
def generate_colors():
    try:
        response = requests.post("http://colormind.io/api/", json={"model": "default"})
        if response.status_code == 200:
            colors = response.json().get('result', [])
            hex_colors = ["#{:02x}{:02x}{:02x}".format(color[0], color[1], color[2]) for color in colors]
            return jsonify({"colors": hex_colors}), 200
        else:
            return jsonify({"error": "Unable to fetch colors"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
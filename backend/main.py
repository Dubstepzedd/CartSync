from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/cart/<int:cart_id>', methods=['GET'])
def get_recipes(cart_id: int):
    return jsonify({"id":cart_id, 'recipe': ["Example" for i in range(5)]})



if __name__ == "__main__":
    app.run(debug=True)
from flask import Flask
app = Flask(__name__)

@app.route("/", methods=["GET"])
def starting_url():
    json_data = flask.request.json
    a_value = json_data["a_key"]
    return "JSON value sent: " + a_value

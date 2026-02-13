from flask import Blueprint, jsonify

main = Blueprint('main', __name__)

@main.route("/")
def index():
    """Root route for testing."""
    return jsonify({"message": "Project Artemis Webserver Running!"})

@main.route("/health")
def health():
    """Optional health check route."""
    return jsonify({"status": "ok"})

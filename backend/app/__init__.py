from flask import Flask

def create_app():
    """
    Factory function to create Flask app.
    Allows easy configuration and testing.
    """
    app = Flask(__name__)
    app.config.from_object("app.config.Config")

    # Import routes and register blueprint
    from app.routes import main
    app.register_blueprint(main)

    return app

# Run app if this file is called directly
if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=5000)

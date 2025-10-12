import os
from flask import Flask

application_version = os.environ.get("APPLICATION_VERSION", "v0.0.1")
environment_information = os.environ.get("ENVIRONMENT", "LOCAL")
database_connection_string = os.environ.get("DATABASE_CONNECTION", "LOCAL-DATABASE-STRING")

web_app = Flask(__name__)


@web_app.route('/')
def home():
    return (f"Welcome to the {environment_information} environment <br><br> "
            f"This application is running on {application_version} with database connection: {database_connection_string}")


if __name__ == '__main__':
    web_app.run(host='0.0.0.0', port=5000)

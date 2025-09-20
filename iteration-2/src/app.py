import os
import random
import time
from flask import Flask, jsonify
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry.instrumentation.flask import FlaskInstrumentor

web_app = Flask(__name__)

# Configure Azure Monitor with OpenTelemetry
connection_string = os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING")
if connection_string:
    configure_azure_monitor(connection_string=connection_string)
    FlaskInstrumentor().instrument_app(web_app)
    print("Application Insights, successfully configured with OpenTelemetry!")
else:
    print("WARNING! Application Insights connection string not found!")


@web_app.route('/')
def home():
    return "Monitoring Demo App - OpenTelemetry Enabled and Reporting!"


@web_app.route('/slow')
def slow_endpoint():
    delay = random.uniform(0.5, 3.0)
    time.sleep(delay)
    return jsonify({"delay": delay})


@web_app.route('/error')
def error_endpoint():
    # 30% chance of error
    if random.random() < 0.3:
        raise Exception("Simulated error! ")
    return jsonify({"status": "success"})


@web_app.route('/memory')
def memory_intensive():
    data = [i for i in range(10_000_000)]
    return jsonify({"processed": len(data)})


if __name__ == '__main__':
    web_app.run(host='0.0.0.0', port=5000)

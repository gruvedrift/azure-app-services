import os
import random
import time
from flask import Flask, jsonify
from azure.monitor.opentelemetry import configure_azure_monitor
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from logging_config import setup_logger
from meter_config import (
    slow_endpoint_accumulated,
    error_rate_counter,
    success_rate_counter
)

web_app = Flask(__name__)

# Configure Azure Monitor with OpenTelemetry
connection_string = os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING")
if connection_string:
    configure_azure_monitor(connection_string=connection_string)
    FlaskInstrumentor().instrument_app(web_app)
    print("Application Insights, successfully configured with OpenTelemetry!")
else:
    print("WARNING! Application Insights connection string not found!")

# Setup logger
logger = setup_logger()


@web_app.route('/')
def home():
    logger.info("Home endpoint accessed")
    return "Monitoring Demo App - OpenTelemetry Enabled and Reporting!"


@web_app.route('/slow')
def slow_endpoint():
    delay = random.uniform(0.5, 3.0)
    time.sleep(delay)

    # Add measured delay to meter
    slow_endpoint_accumulated.add(delay)

    logger.info(f"Slow endpoint completed after {delay:.2f} seconds")
    return jsonify({"delay": delay})


@web_app.route('/error')
def error_endpoint():
    # 30% chance of error
    if random.random() < 0.3:
        # Increment error counter
        error_rate_counter.add(1)
        logger.error("About to throw simulated error")
        raise Exception("Simulated error!")
    # Increment success counter
    success_rate_counter.add(1)
    return jsonify({"status": "success"})


@web_app.route('/memory')
def memory_intensive():
    logger.warning("Starting memory intensive operation - this may impact performance")
    data = [i for i in range(10_000_000)]
    logger.info(f"Memory operation completed - processed {len(data)} items")
    return jsonify({"processed": len(data)})


@web_app.route('/metrics')
def metrics_summary():
    print("error_rate_counter: ", error_rate_counter)
    print("success_rate_counter: ", success_rate_counter)
    error_rate = (error_rate_counter / success_rate_counter) * 100
    return jsonify({
        "error_rate": error_rate,
        "total_delay": slow_endpoint_accumulated
    })


if __name__ == '__main__':
    web_app.run(host='0.0.0.0', port=5000)

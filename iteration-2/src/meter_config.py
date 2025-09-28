from opentelemetry import metrics
from opentelemetry.metrics import get_meter

# Create meter for custom metrics
meter = get_meter(__name__)

slow_endpoint_accumulated = meter.create_counter(
    name="total_delay_slow_endpoint",
    description="Total time spent waiting for slow endpoint to answer",
    unit="s"
)

error_rate_counter = meter.create_counter(
    name="simulated_errors_total",
    description="Total count of simulated errors"
)
success_rate_counter = meter.create_counter(
    name="error_endpoint_success_total",
    description="Total count of successful requests"
)
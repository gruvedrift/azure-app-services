import logging


def setup_logger(level=logging.INFO):
    # Create logger
    logger = logging.getLogger(__name__)

    # Set minimum level for logger, messages below this level will be ignored.
    # Example: if INFO, DEBUG logs are discarded immediately.
    logger.setLevel(logging.INFO)

    # Create a handler that writes error to the console ( stdout / stderr )
    console_handler = logging.StreamHandler()

    # Set handler minimum level.
    # Handler will now only process levels higher or equal to INFO that the logger passes to it.
    console_handler.setLevel(logging.INFO)

    # Format logs
    formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

    # Attach formater to log handler
    console_handler.setFormatter(formatter)

    # Add handler to logger, so that it is able to pass logs to it.
    logger.addHandler(console_handler)
    return logger

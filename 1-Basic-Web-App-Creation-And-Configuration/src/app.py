import psycopg2
import os
from flask import Flask, jsonify
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient


def get_secret_from_kv():
    keyvault_name = os.environ.get("KV_NAME")
    db_secret_name = os.environ.get("DB_SECRET_NAME")
    keyvault_uri = f"https://{keyvault_name}.vault.azure.net"
    credential = DefaultAzureCredential()
    client = SecretClient(vault_url=keyvault_uri, credential=credential)
    print(f"Retrieving secret from {keyvault_name}.")
    return client.get_secret(db_secret_name).value


web_app = Flask(__name__)

# Get password in Keyvault
db_password = get_secret_from_kv()

# Create connection to Database
connection = psycopg2.connect(
    host=os.environ.get("DB_HOST"),
    database=os.environ.get("DB_NAME"),
    user=os.environ.get("DB_USER"),
    password=db_password,
    port=5432,
    sslmode="require"
)
curs = connection.cursor()

# Create table
curs.execute(
    """
    CREATE TABLE IF NOT EXISTS DUNE_QUOTE (
        name VARCHAR(255),
        quote VARCHAR(255)
    )
    """
)

# Insert data
curs.execute(
    """
    INSERT INTO DUNE_QUOTE(name, quote)
    VALUES
        ('Duke Leto Atreides', 'Without change, something sleeps inside us, and seldom awakens.'),
        ('Princess Irulan','What do you despise? By this are you truly known.'),
        ('Paul Atreides', 'Fear is the mind-killer. Fear is the little-death that brings total obliteration.')
    """
)
connection.commit()


@web_app.route('/')
def greet():
    return "The mystery of life isn't a problem to solve, but a reality to experience.<br><br>– Frank Herbert"


@web_app.route('/dune-quotes')
def authors():
    curs.execute(
        """
        SELECT * FROM DUNE_QUOTE
        """)
    rows = curs.fetchall()
    result = [{"name": row[0], "quote": row[1]} for row in rows]
    return jsonify(result)


if __name__ == '__main__':
    web_app.run(host='0.0.0.0', port=5000)

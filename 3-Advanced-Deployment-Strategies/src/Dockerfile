FROM python:3.13.0

WORKDIR ./app

COPY requirements.txt app.py ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python3", "app.py"]
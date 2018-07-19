FROM python:3.7

RUN pip install psycopg2==2.7.5 sqlalchemy==1.2.10
COPY bootstrap.py .

CMD echo "noop"


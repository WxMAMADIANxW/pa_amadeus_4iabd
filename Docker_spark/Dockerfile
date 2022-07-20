FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:slim


ENV PYTHONDONTWRITEBYTECODE=1
ENV GCP_PROJECT = 'cellular-smoke-352111'
ENV GCP_BUCKET = 'amadeus_bucket'

EXPOSE 8080
ENV PORT 8080
ENV HOST 0.0.0.0



# ------------------------------------------------------------------------------
# ---- Spark
# ------------------------------------------------------------------------------
ADD spark-3.3.0-bin-hadoop3.tgz .

RUN apt -y -q update && \
    apt -y -q install curl && \
    # installation JAVA
    apt -y -q install apt-transport-https ca-certificates dirmngr gnupg software-properties-common && \
    curl https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt -y -q update && \
    apt -y -q install adoptopenjdk-8-hotspot && \
    # installation Spark
    mv spark-3.3.0-bin-hadoop3 /opt/spark




# Add java to PATH
ENV JAVA_HOME="/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Add spark to PATH
ENV SPARK_HOME="/opt/spark"
ENV PATH="${SPARK_HOME}/bin:${PATH}"
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9-src.zip"
ENV PYTHONIOENCODING=utf8
ENV PYSPARK_PYTHON=python

# Add spark dependencies
COPY *.jar $SPARK_HOME/jars/


WORKDIR /amadeus_call

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY Spark_call.py Spark_call.py
COPY airline_mapping.csv airline_mapping.csv
COPY airport_mapping.csv airport_mapping.csv

ENTRYPOINT ["python3","Spark_call.py"]


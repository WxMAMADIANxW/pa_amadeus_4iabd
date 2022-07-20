import json
import os, sys
import pandas as pd
from flask import Flask, request, jsonify
from google.cloud import storage
from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    explode,
    col,
    size,
    lit,
)

os.environ["PYSPARK_PYTHON"] = sys.executable

app = Flask(__name__)


@app.route('/', methods=['POST'])
def handler():
    content = json.loads(request.data)
    filename = content["filename"]
    escale = content["escale"]
    tmp = amadeus_client(filename, escale)
    tmp.send_to_gcs()
    res={"res":200}
    return jsonify(res)


class amadeus_client:
    def __init__(self, filename, escale):
        self.spark = (
            SparkSession.builder.config("spark.port.maxRetries", 100)
                .master("local[*]")
                .getOrCreate()
        )
        conf = self.spark.sparkContext._jsc.hadoopConfiguration()
        conf.set("spark.driver.host", "localhost")
        conf.set(
            "spark.hadoop.fs.gs.impl",
            "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem",
        )
        conf.set(
            "spark.hadoop.fs.AbstractFileSystem.gs.impl",
            "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS",
        )
        conf.set("spark.hadoop.fs.gs.auth.service.account.enable", "true")
        conf.set("spark.hadoop.fs.gs.project.id", "cellular-smoke-352111")
        conf.set(
            "spark.hadoop.google.cloud.auth.service.account.email",
            "amadeus-id@cellular-smoke-352111.iam.gserviceaccount.com",
        )
        self.df_airline = self.init_data_airline()
        self.df_airport = self.init_data_airport()
        self.name_file = filename
        self.escale = escale

    def init_data_airport(self):
        return (
            self.spark.read.option("delimiter", ",")
                .option("header", "true")
                .csv("airport_mapping.csv")
        )

    def init_data_airline(self):
        return (
            self.spark.read.option("delimiter", ",")
                .option("header", "true")
                .csv("airline_mapping.csv")
        )

    def bronze_table(self):
        df = self.spark.read.json("gs://amadeus_bucket/input/{}".format(self.name_file))
        return df

    def silver_table(self):
        tmp = self.bronze_table()
        tmp2 = tmp.select(
            explode("itineraries.segments"),
            "travelerPricings",
            "price.currency",
            "price.grandTotal",
            "lastTicketingDate",
            "validatingAirlineCodes",
        )
        tmp3 = tmp2.select(
            "col.departure",
            "col.arrival",
            "lastTicketingDate",
            "currency",
            "grandTotal",
            "travelerPricings",
            "validatingAirlineCodes",
        )
        tmp4 = tmp3.select(
            explode("travelerPricings.fareDetailsBySegment"),
            "departure",
            "arrival",
            "lastTicketingDate",
            "currency",
            "grandTotal",
            "validatingAirlineCodes",
        )
        tmp5 = tmp4.select(
            "col.cabin",
            "departure",
            "arrival",
            "lastTicketingDate",
            "currency",
            "grandTotal",
            explode("validatingAirlineCodes").alias("company"),
        )
        return (
            tmp5.join(self.df_airline, tmp5.company == self.df_airline.IATA, "inner")
                .select(
                "cabin",
                "departure",
                "arrival",
                "lastTicketingDate",
                "currency",
                "grandTotal",
                "Airline_name",
            )
                .withColumnRenamed("Airline_name", "company")
        )

    def gold_table(self):
        df_silver = self.silver_table()
        if self.escale == "false":
            dftmp = df_silver.filter(size("departure") == 1)

            dftmp2 = (
                dftmp.select(
                    explode("cabin").alias("Class"),
                    "departure",
                    "arrival",
                    "lastTicketingDate",
                    "currency",
                    "grandTotal",
                    "company",
                )
                    .select(
                    "Class",
                    explode("departure").alias("depart"),
                    "arrival",
                    "lastTicketingDate",
                    "currency",
                    "grandTotal",
                    "company",
                )
                    .select(
                    "Class",
                    "depart",
                    explode("arrival").alias("arrivee"),
                    "lastTicketingDate",
                    "currency",
                    "grandTotal",
                    "company",
                )
            )

            dftmp3 = (
                dftmp2.withColumn("date_de_depart", col("depart.at"))
                    .withColumn("aeroport_de_depart", col("depart.iataCode"))
                    .withColumn("date_darriver", col("arrivee.at"))
                    .withColumn("aeroport_darrivee", col("arrivee.iataCode"))
                    .drop("depart", "arrivee")
            )

            dftmp4 = (
                dftmp3.join(
                    self.df_airport,
                    dftmp3.aeroport_de_depart == self.df_airport.IATA,
                    "inner",
                )
                    .select(
                    "Class",
                    "lastTicketingDate",
                    "currency",
                    "grandTotal",
                    "company",
                    "date_de_depart",
                    "aeroport_de_depart",
                    "date_darriver",
                    "aeroport_darrivee",
                    "City",
                )
                    .withColumnRenamed("City", "Ville_de_depart")
            )

            return (
                dftmp4.join(
                    self.df_airport,
                    dftmp3.aeroport_darrivee == self.df_airport.IATA,
                    "inner",
                )
                    .select(
                    "aeroport_de_depart",
                    "Ville_de_depart",
                    "date_de_depart",
                    "aeroport_darrivee",
                    "City",
                    "date_darriver",
                    "currency",
                    "grandTotal",
                    "company",
                    "lastTicketingDate",
                )
                    .withColumnRenamed("aeroport_de_depart", "aeroportDepart")
                    .withColumnRenamed("aeroport_darrivee", "aeroportArrivee")
                    .withColumnRenamed("date_de_depart", "dateDepart")
                    .withColumnRenamed("date_darriver", "dateArrivee")
                    .withColumnRenamed("Ville_de_depart", "villeDepart")
                    .withColumnRenamed("City", "villeArrivee")
                    .withColumnRenamed("grandTotal", "prix")
                    .withColumnRenamed("company", "compagnie")
                    .withColumnRenamed("currency", "devise")
            )

        if self.escale == "true":
            dftmp = df_silver.filter(size("departure") == 2)

            dftmp2 = dftmp.select(
                col("cabin")[0],
                col("departure")[0],
                col("arrival")[0],
                col("departure")[1],
                col("arrival")[1],
                "lastTicketingDate",
                "currency",
                "grandTotal",
                "company",
            ).distinct()
            dftmp3 = (
                dftmp2.withColumn("Class", col("cabin[0]"))
                    .withColumn("date_de_depart_1", col("departure[0].at"))
                    .withColumn("aeroport_de_depart_1", col("departure[0].iataCode"))
                    .withColumn("date_darrive_1", col("arrival[0].at"))
                    .withColumn("aeroport_darrivee_1", col("arrival[0].iataCode"))
                    .withColumn("date_de_depart_escale", col("departure[1].at"))
                    .withColumn("date_darrive_2", col("arrival[1].at"))
                    .withColumn("aeroport_darrivee_2", col("arrival[1].iataCode"))
                    .drop(
                    "cabin[0]",
                    "departure[0]",
                    "arrival[0]",
                    "departure[1]",
                    "arrival[1]",
                )
            )

            dftmp4 = (
                dftmp3.join(
                    self.df_airport,
                    dftmp3.aeroport_de_depart_1 == self.df_airport.IATA,
                    "inner",
                )
                    .select(
                    "aeroport_de_depart_1",
                    "City",
                    "date_de_depart_1",
                    "aeroport_darrivee_1",
                    "date_darrive_1",
                    "date_de_depart_escale",
                    "aeroport_darrivee_2",
                    "date_darrive_2",
                    "currency",
                    "grandTotal",
                    "Class",
                    "company",
                    "lastTicketingDate",
                )
                    .withColumnRenamed("City", "Ville_de_depart_1")
            )

            dftmp5 = (
                dftmp4.join(
                    self.df_airport,
                    dftmp4.aeroport_darrivee_1 == self.df_airport.IATA,
                    "inner",
                )
                    .select(
                    "aeroport_de_depart_1",
                    "Ville_de_depart_1",
                    "date_de_depart_1",
                    "aeroport_darrivee_1",
                    "City",
                    "date_darrive_1",
                    "date_de_depart_escale",
                    "aeroport_darrivee_2",
                    "date_darrive_2",
                    "currency",
                    "grandTotal",
                    "Class",
                    "company",
                    "lastTicketingDate",
                )
                    .withColumnRenamed("City", "Ville_darrivee_1")
            )

            return (
                dftmp5.join(
                    self.df_airport,
                    dftmp4.aeroport_darrivee_2 == self.df_airport.IATA,
                    "inner",
                )
                    .select(
                    "aeroport_de_depart_1",
                    "Ville_de_depart_1",
                    "date_de_depart_1",
                    "aeroport_darrivee_1",
                    "Ville_darrivee_1",
                    "date_darrive_1",
                    "aeroport_darrivee_2",
                    "City",
                    "date_darrive_2",
                    "currency",
                    "grandTotal",
                    "company",
                    "lastTicketingDate",
                )
                    .withColumnRenamed("aeroport_de_depart_1", "aeroportDepart")
                    .withColumnRenamed("aeroport_darrivee_2", "aeroportArrivee")
                    .withColumnRenamed("date_de_depart_1", "dateDepart")
                    .withColumnRenamed("date_darrive_2", "dateArrivee")
                    .withColumnRenamed("Ville_de_depart_1", "villeDepart")
                    .withColumnRenamed("City", "villeArrivee")
                    .withColumnRenamed("grandTotal", "prix")
                    .withColumnRenamed("company", "compagnie")
                    .withColumnRenamed("currency", "devise")
                    .withColumnRenamed("Ville_darrivee_1", "villeEscale")
                    .withColumnRenamed("date_darrive_1", "dateEscale")
                    .withColumnRenamed("aeroport_darrivee_1", "aeroportEscale")

            )

    def send_to_gcs(self):
        client = storage.Client(project="cellular-smoke-352111")
        bucket = client.get_bucket("amadeus_bucket")
        blob = bucket.blob("output/{}".format(self.name_file))
        self.gold_table().toPandas().to_json(
            "{}".format(self.name_file), orient="records", lines=True
        )
        blob.upload_from_filename("{}".format(self.name_file))


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))

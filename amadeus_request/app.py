"""
A sample Hello World server.
"""
import os
import time
from amadeus import Client
from flask import Flask, render_template,jsonify, request
from googletrans import Translator
from google.cloud import language,storage, bigquery
import json
import requests

app = Flask(__name__)




# Translator client && NLP function
translator = Translator()
client = language.LanguageServiceClient()

#GetDate function
def getDate(text):
  day = ""
  month = ""
  year = ""
  text = translator.translate(text, dest="en").text
  document = language.Document(content=text, type_=language.Document.Type.PLAIN_TEXT)
  resp = client.analyze_entities(document = language.Document(content=text, type_=language.Document.Type.PLAIN_TEXT))
  for entity in resp.entities:
    if entity.type_.name == "DATE":
      for metadata_name, metadata_value in entity.metadata.items():
        if metadata_name == "day":
          day = metadata_value
        if metadata_name == "month":
          month = metadata_value
        if metadata_name == "year": 
          year = metadata_value

  if int(month) < 10:
    if int(day) < 10:
        date = year+"-0"+month+"-0"+day
    else:
        date = year+"-0"+month+"-"+day
  else:
    if int(day) < 10:
        date = year+"-"+month+"-0"+day
    else:
        date = year+"-"+month+"-"+day
  
  return date

#Function Get City of departure and arrival
def translation_nlp(query):
    departure, arrival= "", ""
    trad = translator.translate(query, dest="en").text
    document = language.Document(content=trad, type_=language.Document.Type.PLAIN_TEXT)
    response = client.analyze_syntax(document=document)
    
    for e in response.tokens:
        if (e.part_of_speech.tag.name == "ADP") & (e.text.content.lower() == "from"):
            resp = client.analyze_entities(document = language.Document(content=trad.split(e.text.content)[1], type_=language.Document.Type.PLAIN_TEXT))
            if resp.entities[0].type_.name == 'LOCATION':
                departure = resp.entities[0].name

        if (e.part_of_speech.tag.name == "ADP") & (e.text.content.lower() == "to"):
            resp = client.analyze_entities(document = language.Document(content=trad.split(e.text.content)[1], type_=language.Document.Type.PLAIN_TEXT))
            if resp.entities[0].type_.name == 'LOCATION':
                arrival = resp.entities[0].name

    return departure, arrival
  


def amadeus_request(departure, arrival, date, nb_passengers, escale):
  amadeus = Client(
    client_id=os.environ['AMADEUS_CLIENT_ID'],
    client_secret=os.environ['AMADEUS_CLIENT_SECRET'],
  )

  response = amadeus.shopping.flight_offers_search.get(
              originLocationCode=departure,
              destinationLocationCode=arrival,
              departureDate=date,
              adults=nb_passengers
          )
  name_file = "{}{}{}{}{}{}".format( departure,arrival,date, nb_passengers,escale,time.time_ns())
  client = storage.Client(project=os.environ['PROJECT_ID'])
  bucket = client.get_bucket(os.environ['BUCKET_NAME'])
  blob = bucket.blob(f"input/{name_file}")
  with open(name_file, "a+") as outfile:
      json.dump(response.data, outfile)
  blob.upload_from_filename(name_file)
  
  return response, name_file

def response_amadeus(name_file) :
  client = storage.Client(project=os.environ['PROJECT_ID'])
  bucket = client.get_bucket(os.environ['BUCKET_NAME'])
  blob = bucket.blob(f"output/{name_file}")
  
  while(not blob.exists()):
    time.sleep(1)
  
  jl = blob.download_as_string()
  data = []  
  for line in jl.decode('utf-8').splitlines():
    data.append(json.loads(line))
  
  return data

def getAeroport(city):
  client= bigquery.Client(project=os.environ['PROJECT_ID'])
  query = f"SELECT * FROM `cellular-smoke-352111.amadeus.airport` WHERE city = '{city}'"
  
  return client.query(query).to_dataframe().iloc[0]['code']

@app.route('/', methods=['POST'])
def amadeus():

    dict = {
      "los angeles" : "LAX",
      "new york" : "JFK",
      "madrid" : "MAD",
      "paris" : "CDG",
      "rome" : "FCO",
      "london" : "LGW",
    }
    content = json.loads(request.data)
    #Translate the query && NLP on query
    departure, arrival = translation_nlp(content["query"])
    departure = getAeroport(departure)
    arrival = getAeroport(arrival)
    nb_passengers = content["nbPassengers"]
    escale = content["escale"]
    
    #Translate the query && NLP on query
    date = getDate(content["date"])
    
    #Request Amadeus
    response, namefile = amadeus_request(departure, arrival, date, nb_passengers, escale)
    data = {
        "filename": namefile,
        "escale": escale,
    }
    #Request Cloud Run API
    url = "https://python-test-t5wtk4fqgq-ew.a.run.app" 
    headers = {"Content-Type": "application/json; charset=utf-8"}
    reponse = requests.post(url,headers=headers, json=data)
    
    res = response_amadeus(namefile)
    
    return jsonify(res)
    

    
        
@app.route('/')
def hello():
    """Return a friendly HTTP greeting."""
    message = "La préparation du Projet Annuel VOCALEARTH est en cours!"

    """Get Cloud Run environment variables."""
    service = os.environ.get('K_SERVICE', 'Unknown service')
    revision = os.environ.get('K_REVISION', 'Unknown revision')

    return render_template('index.html',
        message=message,
        Service=service,
        Revision=revision)

if __name__ == '__main__':
    server_port = os.environ.get('PORT', '8080')
    app.run(debug=False, port=server_port, host='0.0.0.0')

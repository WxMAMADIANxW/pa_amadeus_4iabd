"""
A sample Hello World server.
"""
import os
from amadeus import Client, ResponseError
from google.cloud import secretmanager
from flask import Flask, render_template, send_from_directory, jsonify, request
from google.oauth2 import service_account
from googletrans import Translator
from google.cloud import language
import json
import pandas as pd

# pylint: disable=C0103
app = Flask(__name__)
# Amaadeus API

# secret = secretmanager.SecretManagerServiceClient()
# amadeus_client_id = secret.access_secret_version({"name": f"projects/360711503960/secrets/amadeus_client_id"}).payload.data.decode("UTF-8")
# amadeus_client_secret = secret.access_secret_version({"name": f"projects/360711503960/secrets/amadeus_client_secret"}).payload.data.decode("UTF-8")

# amadeus = Client(client_id = amadeus_client_id,
#     client_secret = amadeus_client_secret)



# Translator client && NLP function
translator = Translator()
client = language.LanguageServiceClient()

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

# def amadeus_request(departure, arrival, date, nb_passengers, escale):
#     response = amadeus.shopping.flight_offers_search.get(
#                 originLocationCode=departure,
#                 destinationLocationCode=arrival,
#                 departureDate=date,
#                 adults=nb_passengers
#             )
#     return escale, response.data


@app.route('/', methods=['POST'])
def amadeus():
    
    content = json.loads(request.data)
    query = content['query']
    #return f"{query}"

    #Translate the query && NLP on query
    origin, destination = translation_nlp(query)
    return f'Départ : {origin}\nArrivéé : {destination}'
    
    #return c
    
    #Do amadeus request
    #escale, data = amadeus_request(origin, destination, date, nbPassengers, escale)
        
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

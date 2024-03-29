import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import "package:intl/intl.dart";

class Ticket {
  String aeroportDepart;
  String aeroportArrivee;
  String dateDepart;
  String dateArrivee;
  String villeDepart;
  String villeArrivee;
  String prix;
  String compagnie;
  String devise;
  String classe = "ECONOMIQUE";
  String? villeEscale;
  String? dateEscale;
  String? aeroportEscale;
  String lastTicketingDate;

  Ticket(
      {
      required this.aeroportDepart,
      required this.aeroportArrivee,
      required this.dateDepart,
      required this.dateArrivee,
      required this.villeDepart,
      required this.villeArrivee,
      required this.prix,
      required this.compagnie,
      required this.devise,
      required this.classe,
      required this.lastTicketingDate,
      this.villeEscale,
      this.dateEscale,
      this.aeroportEscale});

  factory Ticket.fromJson(Map<String, dynamic> json) {
    if (json['escale'] == "true") {
      return Ticket(
          aeroportDepart: json['aeroportDepart'],
          aeroportArrivee: json['aeroportArrivee'],
          dateDepart: json['dateDepart'],
          dateArrivee: json['dateArrivee'],
          villeDepart: json['villeDepart'],
          villeArrivee: json['villeArrivee'],
          prix: json['prix'],
          compagnie: json['compagnie'],
          devise: json['devise'],
          classe: "ECONOMIQUE",
          villeEscale: json['villeEscale'],
          dateEscale: json['dateEscale'],
          aeroportEscale: json['aeroportEscale'],
          lastTicketingDate: json['lastTicketingDate']);
    } else {
      return Ticket(
          aeroportDepart: json['aeroportDepart'],
          aeroportArrivee: json['aeroportArrivee'],
          dateDepart: json['dateDepart'],
          dateArrivee: json['dateArrivee'],
          villeDepart: json['villeDepart'],
          villeArrivee: json['villeArrivee'],
          prix: json['prix'],
          compagnie: json['compagnie'],
          devise: json['devise'],
          classe: "ECONOMIQUE",
          lastTicketingDate: json['lastTicketingDate']);
    }
  }

  String get title => aeroportDepart + " - " + aeroportArrivee;

  String get subtitle => "$prix $devise";

  String get description =>
      "Prix : " +
      prix +
      " " +
      devise +
      "\n" +
      "Compagnie : " +
      compagnie +
      "\n" +
      "Classe : " +
      classe +
      "\n" +
      "Date de d : " +
      dateDepart;
}

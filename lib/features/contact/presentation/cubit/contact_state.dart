import 'package:flutter/material.dart';

@immutable
abstract class ContactState {}

class ContactInitial extends ContactState {}

// Types
class ContactTypesLoading extends ContactState {}

class ContactTypesLoaded extends ContactState {
  final List<dynamic> types;
  ContactTypesLoaded(this.types);
}

class ContactTypesError extends ContactState {
  final String error;
  ContactTypesError(this.error);
}

// Submit Request
class ContactSubmitLoading extends ContactState {}

class ContactSubmitSuccess extends ContactState {
  final String message;
  ContactSubmitSuccess(this.message);
}

class ContactSubmitError extends ContactState {
  final String error;
  ContactSubmitError(this.error);
}

// My Tickets
class ContactMyTicketsLoading extends ContactState {}

class ContactMyTicketsLoaded extends ContactState {
  final List<dynamic> tickets;
  ContactMyTicketsLoaded(this.tickets);
}

class ContactMyTicketsError extends ContactState {
  final String error;
  ContactMyTicketsError(this.error);
}

// Ticket Details
class ContactTicketDetailsLoading extends ContactState {}

class ContactTicketDetailsLoaded extends ContactState {}

class ContactTicketDetailsError extends ContactState {
  final String error;
  ContactTicketDetailsError(this.error);
}

// Reply
class ContactTicketReplyLoading extends ContactState {}

class ContactTicketReplySuccess extends ContactState {
  final String message;
  ContactTicketReplySuccess(this.message);
}

class ContactTicketReplyError extends ContactState {
  final String error;
  ContactTicketReplyError(this.error);
}

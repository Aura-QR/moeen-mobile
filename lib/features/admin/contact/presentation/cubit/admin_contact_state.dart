import 'package:flutter/material.dart';

@immutable
abstract class AdminContactState {}

class AdminContactInitial extends AdminContactState {}

// Stats States
class AdminContactStatsLoading extends AdminContactState {}

class AdminContactStatsLoaded extends AdminContactState {
  final Map<String, dynamic> stats;
  AdminContactStatsLoaded(this.stats);
}

class AdminContactStatsError extends AdminContactState {
  final String error;
  AdminContactStatsError(this.error);
}

// Tickets States
class AdminContactTicketsLoading extends AdminContactState {}

class AdminContactTicketsLoaded extends AdminContactState {
  final List<dynamic> tickets;
  AdminContactTicketsLoaded(this.tickets);
}

class AdminContactTicketsError extends AdminContactState {
  final String error;
  AdminContactTicketsError(this.error);
}

// Ticket Details States
class AdminContactTicketDetailsLoading extends AdminContactState {}

class AdminContactTicketDetailsLoaded extends AdminContactState {
  final Map<String, dynamic> ticket;
  AdminContactTicketDetailsLoaded(this.ticket);
}

class AdminContactTicketDetailsError extends AdminContactState {
  final String error;
  AdminContactTicketDetailsError(this.error);
}

// Update Ticket States
class AdminContactTicketUpdateLoading extends AdminContactState {}

class AdminContactTicketUpdateSuccess extends AdminContactState {
  final String message;
  AdminContactTicketUpdateSuccess(this.message);
}

class AdminContactTicketUpdateError extends AdminContactState {
  final String error;
  AdminContactTicketUpdateError(this.error);
}

// Reply Ticket States
class AdminContactTicketReplyLoading extends AdminContactState {}

class AdminContactTicketReplySuccess extends AdminContactState {
  final String message;
  AdminContactTicketReplySuccess(this.message);
}

class AdminContactTicketReplyError extends AdminContactState {
  final String error;
  AdminContactTicketReplyError(this.error);
}

// Delete Ticket States
class AdminContactTicketDeleteLoading extends AdminContactState {}

class AdminContactTicketDeleteSuccess extends AdminContactState {}

class AdminContactTicketDeleteError extends AdminContactState {
  final String error;
  AdminContactTicketDeleteError(this.error);
}

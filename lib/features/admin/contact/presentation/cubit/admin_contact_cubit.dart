import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_state.dart';

class AdminContactCubit extends Cubit<AdminContactState> {
  AdminContactCubit() : super(AdminContactInitial());

  static AdminContactCubit get(BuildContext context) => BlocProvider.of(context);

  Map<String, dynamic>? stats;
  List<dynamic> tickets = [];

  Future<void> getStats() async {
    if (!isClosed) emit(AdminContactStatsLoading());

    final result = await ApiService.getAdminContactStats();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(AdminContactStatsError(error));
      },
      (data) {
        stats = data;
        if (!isClosed) emit(AdminContactStatsLoaded(data));
      },
    );
  }

  Future<void> getTickets({String? status, String? type, String? search}) async {
    if (!isClosed) emit(AdminContactTicketsLoading());

    final result = await ApiService.getAdminContactTickets(
      status: status,
      type: type,
      search: search,
    );
    if (isClosed) return;
    
    result.fold(
      (error) {
        if (!isClosed) emit(AdminContactTicketsError(error));
      },
      (data) {
        tickets = data['data'] ?? [];
        if (!isClosed) emit(AdminContactTicketsLoaded(tickets));
      },
    );
  }

  Map<String, dynamic>? currentTicket;

  Future<void> getTicketDetails(int id) async {
    if (!isClosed) emit(AdminContactTicketDetailsLoading());

    final result = await ApiService.getAdminContactTicketDetails(id: id);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(AdminContactTicketDetailsError(error));
      },
      (data) {
        currentTicket = data;
        if (!isClosed) emit(AdminContactTicketDetailsLoaded(data));
      },
    );
  }

  Future<void> updateTicket({required int id, String? status, String? adminNotes}) async {
    if (!isClosed) emit(AdminContactTicketUpdateLoading());

    final result = await ApiService.updateAdminContactTicket(
      id: id,
      status: status,
      adminNotes: adminNotes,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminContactTicketUpdateError(error));
      },
      (data) {
        if (!isClosed) emit(AdminContactTicketUpdateSuccess(data['message'] ?? 'تم التحديث بنجاح'));
        getTicketDetails(id);
      },
    );
  }

  Future<void> replyToTicket({required int id, required String body}) async {
    if (!isClosed) emit(AdminContactTicketReplyLoading());

    final result = await ApiService.replyAdminContactTicket(
      id: id,
      body: body,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminContactTicketReplyError(error));
      },
      (data) {
        if (!isClosed) emit(AdminContactTicketReplySuccess(data['message'] ?? 'تم إرسال الرد بنجاح'));
        getTicketDetails(id);
      },
    );
  }

  Future<void> deleteTicket(int id) async {
    if (!isClosed) emit(AdminContactTicketDeleteLoading());

    final result = await ApiService.deleteAdminContactTicket(id: id);
    if (isClosed) return;
    
    result.fold(
      (error) {
        if (!isClosed) emit(AdminContactTicketDeleteError(error));
      },
      (_) {
        if (!isClosed) emit(AdminContactTicketDeleteSuccess());
      },
    );
  }
}

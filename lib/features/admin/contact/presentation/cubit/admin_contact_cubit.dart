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
    emit(AdminContactStatsLoading());

    final result = await ApiService.getAdminContactStats();
    result.fold(
      (error) => emit(AdminContactStatsError(error)),
      (data) {
        stats = data;
        emit(AdminContactStatsLoaded(data));
      },
    );
  }

  Future<void> getTickets({String? status, String? type, String? search}) async {
    emit(AdminContactTicketsLoading());

    final result = await ApiService.getAdminContactTickets(
      status: status,
      type: type,
      search: search,
    );
    
    result.fold(
      (error) => emit(AdminContactTicketsError(error)),
      (data) {
        tickets = data['data'] ?? [];
        emit(AdminContactTicketsLoaded(tickets));
      },
    );
  }

  Map<String, dynamic>? currentTicket;

  Future<void> getTicketDetails(int id) async {
    emit(AdminContactTicketDetailsLoading());

    final result = await ApiService.getAdminContactTicketDetails(id: id);
    result.fold(
      (error) => emit(AdminContactTicketDetailsError(error)),
      (data) {
        currentTicket = data;
        emit(AdminContactTicketDetailsLoaded(data));
      },
    );
  }

  Future<void> updateTicket({required int id, String? status, String? adminNotes}) async {
    emit(AdminContactTicketUpdateLoading());

    final result = await ApiService.updateAdminContactTicket(
      id: id,
      status: status,
      adminNotes: adminNotes,
    );

    result.fold(
      (error) => emit(AdminContactTicketUpdateError(error)),
      (data) {
        emit(AdminContactTicketUpdateSuccess(data['message'] ?? 'تم التحديث بنجاح'));
        getTicketDetails(id);
      },
    );
  }

  Future<void> replyToTicket({required int id, required String body}) async {
    emit(AdminContactTicketReplyLoading());

    final result = await ApiService.replyAdminContactTicket(
      id: id,
      body: body,
    );

    result.fold(
      (error) => emit(AdminContactTicketReplyError(error)),
      (data) {
        emit(AdminContactTicketReplySuccess(data['message'] ?? 'تم إرسال الرد بنجاح'));
        getTicketDetails(id);
      },
    );
  }

  Future<void> deleteTicket(int id) async {
    emit(AdminContactTicketDeleteLoading());

    final result = await ApiService.deleteAdminContactTicket(id: id);
    
    result.fold(
      (error) => emit(AdminContactTicketDeleteError(error)),
      (_) => emit(AdminContactTicketDeleteSuccess()),
    );
  }
}

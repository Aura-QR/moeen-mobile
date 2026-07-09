import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/contact/presentation/cubit/contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit() : super(ContactInitial());

  static ContactCubit get(context) => BlocProvider.of(context);

  List<dynamic> types = [];
  List<dynamic> myTickets = [];

  Future<void> getContactTypes() async {
    emit(ContactTypesLoading());

    final result = await ApiService.getContactTypes();
    result.fold(
      (error) => emit(ContactTypesError(error)),
      (data) {
        types = data['types'] ?? [];
        emit(ContactTypesLoaded(types));
      },
    );
  }

  Future<void> submitContactRequest({
    required String name,
    required String email,
    String? phone,
    required String type,
    required String message,
  }) async {
    emit(ContactSubmitLoading());

    final result = await ApiService.submitContactRequest(
      name: name,
      email: email,
      phone: phone,
      type: type,
      message: message,
    );

    result.fold(
      (error) => emit(ContactSubmitError(error)),
      (data) => emit(ContactSubmitSuccess(data['message'] ?? 'تم إرسال طلبك بنجاح.')),
    );
  }

  Future<void> getMyTickets() async {
    emit(ContactMyTicketsLoading());

    final result = await ApiService.getMyContactTickets();
    result.fold(
      (error) => emit(ContactMyTicketsError(error)),
      (data) {
        myTickets = data['data'] ?? [];
        emit(ContactMyTicketsLoaded(myTickets));
      },
    );
  }

  Map<String, dynamic>? currentTicket;

  Future<void> getTicketDetails(int id) async {
    emit(ContactTicketDetailsLoading());

    final result = await ApiService.getMyContactTicketDetails(id: id);
    result.fold(
      (error) => emit(ContactTicketDetailsError(error)),
      (data) {
        currentTicket = data['ticket'] ?? data;
        emit(ContactTicketDetailsLoaded());
      },
    );
  }

  Future<void> replyToTicket({required int id, required String body}) async {
    emit(ContactTicketReplyLoading());

    final result = await ApiService.replyContactTicket(id: id, body: body);
    result.fold(
      (error) => emit(ContactTicketReplyError(error)),
      (data) {
        emit(ContactTicketReplySuccess(data['message'] ?? 'تم إرسال الرد بنجاح'));
        // Refresh ticket details to get the new reply
        getTicketDetails(id);
      },
    );
  }
}

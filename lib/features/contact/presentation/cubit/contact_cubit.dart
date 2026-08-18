import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/contact/presentation/cubit/contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit() : super(ContactInitial());

  static ContactCubit get(context) => BlocProvider.of(context);

  List<dynamic> types = [];
  List<dynamic> myTickets = [];

  Future<void> getContactTypes() async {
    if (!isClosed) emit(ContactTypesLoading());

    final result = await ApiService.getContactTypes();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(ContactTypesError(error));
      },
      (data) {
        types = data['types'] ?? [];
        if (!isClosed) emit(ContactTypesLoaded(types));
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
    if (!isClosed) emit(ContactSubmitLoading());

    final result = await ApiService.submitContactRequest(
      name: name,
      email: email,
      phone: phone,
      type: type,
      message: message,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(ContactSubmitError(error));
      },
      (data) {
        if (!isClosed) emit(ContactSubmitSuccess(data['message'] ?? 'تم إرسال طلبك بنجاح.'));
      },
    );
  }

  Future<void> getMyTickets() async {
    if (!isClosed) emit(ContactMyTicketsLoading());

    final result = await ApiService.getMyContactTickets();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(ContactMyTicketsError(error));
      },
      (data) {
        myTickets = data['data'] ?? [];
        if (!isClosed) emit(ContactMyTicketsLoaded(myTickets));
      },
    );
  }

  Map<String, dynamic>? currentTicket;

  Future<void> getTicketDetails(int id) async {
    if (!isClosed) emit(ContactTicketDetailsLoading());

    final result = await ApiService.getMyContactTicketDetails(id: id);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(ContactTicketDetailsError(error));
      },
      (data) {
        currentTicket = data['ticket'] ?? data;
        if (!isClosed) emit(ContactTicketDetailsLoaded());
      },
    );
  }

  Future<void> replyToTicket({required int id, required String body}) async {
    if (!isClosed) emit(ContactTicketReplyLoading());

    final result = await ApiService.replyContactTicket(id: id, body: body);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(ContactTicketReplyError(error));
      },
      (data) {
        if (!isClosed) emit(ContactTicketReplySuccess(data['message'] ?? 'تم إرسال الرد بنجاح'));
        // Refresh ticket details to get the new reply
        getTicketDetails(id);
      },
    );
  }
}

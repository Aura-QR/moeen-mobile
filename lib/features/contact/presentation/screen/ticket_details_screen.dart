import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/contact/presentation/cubit/contact_cubit.dart';
import 'package:moean/features/contact/presentation/cubit/contact_state.dart';
import 'package:moean/features/contact/presentation/widgets/ticket_chat_history.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late int ticketId;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = context.getArg<Map<String, dynamic>>();
      ticketId = args?['id'] ?? 0;
      if (ticketId != 0) {
        ContactCubit.get(context).getTicketDetails(ticketId);
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ColorsManager.black),
            onPressed: () => context.pop(true),
          ),
          title: Column(
            children: [
              Text(
                appTranslation().get('ticket_details') ?? 'تفاصيل التذكرة',
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.black),
              ),
              verticalSpace4,
              Text(
                '${appTranslation().get('ticket_number') ?? 'التذكرة رقم'} #$ticketId',
                style: TextStylesManager.regular14.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<ContactCubit, ContactState>(
          listener: (context, state) {
            if (state is ContactTicketReplySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.green));
            } else if (state is ContactTicketReplyError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.red));
            }
          },
          buildWhen: (previous, current) => current is ContactTicketDetailsLoading || current is ContactTicketDetailsLoaded || current is ContactTicketDetailsError,
          builder: (context, state) {
            if (state is ContactTicketDetailsLoading || ContactCubit.get(context).currentTicket == null) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ContactTicketDetailsError) {
              return Center(child: Text(state.error, style: TextStylesManager.bold16.copyWith(color: Colors.red)));
            }

            final ticket = ContactCubit.get(context).currentTicket!;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: TicketChatHistory(ticket: ticket),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_state.dart';
import 'package:moean/features/admin/contact/presentation/widgets/admin_ticket_info_card.dart';
import 'package:moean/features/admin/contact/presentation/widgets/admin_ticket_chat_history.dart';

class AdminTicketDetailsScreen extends StatefulWidget {
  const AdminTicketDetailsScreen({super.key});

  @override
  State<AdminTicketDetailsScreen> createState() => _AdminTicketDetailsScreenState();
}

class _AdminTicketDetailsScreenState extends State<AdminTicketDetailsScreen> {
  late int ticketId;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = context.getArg<Map<String, dynamic>>();
      ticketId = args?['id'] ?? 0;
      if (ticketId != 0) {
        AdminContactCubit.get(context).getTicketDetails(ticketId);
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
            icon: Icon(Icons.arrow_back, color: ColorsManager.mainText),
            onPressed: () => context.pop(true), // pass true to refresh list if needed
          ),
          title: Text(
            appTranslation().get('admin_ticket_details'),
            style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<AdminContactCubit, AdminContactState>(
          listener: (context, state) {
            if (state is AdminContactTicketUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.green));
            } else if (state is AdminContactTicketUpdateError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.red));
            } else if (state is AdminContactTicketReplySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.green));
            } else if (state is AdminContactTicketReplyError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.red));
            } else if (state is AdminContactTicketDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(appTranslation().get('ticket_deleted'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.green));
              context.pop(true);
            } else if (state is AdminContactTicketDeleteError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error, style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)), backgroundColor: Colors.red));
            }
          },
          buildWhen: (previous, current) => current is AdminContactTicketDetailsLoading || current is AdminContactTicketDetailsLoaded || current is AdminContactTicketDetailsError,
          builder: (context, state) {
            if (state is AdminContactTicketDetailsLoading || AdminContactCubit.get(context).currentTicket == null) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminContactTicketDetailsError) {
              return Center(child: Text(state.error, style: TextStylesManager.bold16.copyWith(color: Colors.red)));
            }

            final ticket = AdminContactCubit.get(context).currentTicket!;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: AdminTicketChatHistory(ticket: ticket),
                        ),
                        horizontalSpace24,
                        Expanded(
                          flex: 1,
                          child: AdminTicketInfoCard(ticket: ticket),
                        ),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AdminTicketInfoCard(ticket: ticket),
                          verticalSpace24,
                          AdminTicketChatHistory(ticket: ticket),
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/widgets/attach_to_portfolio_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_sheet.dart';

/// What a document tool opens once a save succeeds.
enum DocumentFollowUp { export, attachToPortfolio }

/// Opens the export sheet, or the portfolio sheet with [portfolioItemKey]
/// preselected, for the saved document of [documentType].
Future<void> runDocumentFollowUp(
  BuildContext context, {
  required DocumentFollowUp? followUp,
  required int documentId,
  required String documentType,
  required String portfolioItemKey,
}) async {
  switch (followUp) {
    case DocumentFollowUp.export:
      await DocumentExportSheet.show(
        context,
        documentId: documentId,
        landscape: DocumentTypes.isLandscape(documentType),
      );
    case DocumentFollowUp.attachToPortfolio:
      final attached = await AttachToPortfolioSheet.show(
        context,
        documentId: documentId,
        suggestedItemKey: portfolioItemKey,
      );
      if (attached && context.mounted) showPrimarySnackBar(context, 'document_attached', isError: false);
    case null:
      break;
  }
}

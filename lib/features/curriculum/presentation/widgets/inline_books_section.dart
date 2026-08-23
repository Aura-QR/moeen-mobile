import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'package:moean/features/curriculum/presentation/cubit/curriculum_books_cubit.dart';

class InlineBooksSection extends StatelessWidget {
  const InlineBooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurriculumBooksCubit, CurriculumBooksState>(
      listener: (context, state) {
        if (state is CurriculumBooksDownloadReady) {
          _openDownloadUrl(context, state.download.url);
        }
      },
      builder: (context, state) {
        List<CurriculumBookModel> books = [];
        int? loadingBookId;

        if (state is CurriculumBooksLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CurriculumBooksLoaded) {
          books = state.books;
        } else if (state is CurriculumBooksDownloadLoading) {
          books = state.books;
          loadingBookId = state.bookId;
        } else if (state is CurriculumBooksDownloadReady) {
          books = state.books;
        } else if (state is CurriculumBooksError) {
          return const SizedBox.shrink(); // hide section if error loading books inline
        }

        if (books.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: books.map((book) {
              final isDownloading = loadingBookId == book.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderLightGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red, size: 24),
                    ),
                    horizontalSpace12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: TextStylesManager.bold12.copyWith(color: ColorsManager.mainText),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (book.sizeMb != null) ...[
                            verticalSpace2,
                            Text(
                              '${book.sizeMb} ميجا',
                              style: TextStylesManager.regular12.copyWith(
                                  color: ColorsManager.secondaryText, fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                    horizontalSpace12,
                    GestureDetector(
                      onTap: isDownloading ? null : () => CurriculumBooksCubit.get(context).getDownloadUrl(book.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF13192B), // very dark color from screenshot
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isDownloading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.download_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text('تحميل', style: TextStylesManager.bold12.copyWith(color: Colors.white, fontSize: 10)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

Future<void> _openDownloadUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر فتح رابط التحميل'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

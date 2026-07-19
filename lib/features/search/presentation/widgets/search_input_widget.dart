import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

class SearchInputWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback? onClear;

  const SearchInputWidget({
    super.key,
    required this.onSearch,
    this.onClear,
  });

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submit() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) widget.onSearch(query);
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textDirection: TextDirection.rtl,
      style: TextStylesManager.regular14.copyWith(
        color: ColorsManager.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: appTranslation().get('search_hint'),
        hintStyle: TextStylesManager.regular14.copyWith(
          color: ColorsManager.placeholder,
        ),
        hintTextDirection: TextDirection.rtl,
        prefixIcon: GestureDetector(
          onTap: _submit,
          child: Icon(
            Icons.search_rounded,
            color: ColorsManager.primaryColor,
            size: 22,
          ),
        ),
        suffixIcon: _hasText
            ? GestureDetector(
                onTap: _clear,
                child: Icon(
                  Icons.close_rounded,
                  color: ColorsManager.placeholder,
                  size: 20,
                ),
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
    );
  }
}

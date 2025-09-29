import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';

import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/facility/facility_mock_service.dart';
import 'package:aipet_frontend/shared/foundation/error_handler/app_error_handler.dart';
import 'package:aipet_frontend/shared/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSearch,
    this.onClear,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: '検索',
      hintText: hintText,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller.text.isNotEmpty ? const Icon(Icons.clear) : null,
    );
  }
}

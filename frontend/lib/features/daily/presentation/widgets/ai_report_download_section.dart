import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// レポートダウンロード形式
enum ReportFormat { pdf, png, json }

/// AIレポートダウンロードセクション
///
/// レポート形式選択とダウンロードボタンを提供
class AIReportDownloadSection extends StatefulWidget {
  final Function(ReportFormat format)? onDownloadReport;

  const AIReportDownloadSection({
    super.key,
    this.onDownloadReport,
  });

  @override
  State<AIReportDownloadSection> createState() =>
      _AIReportDownloadSectionState();
}

class _AIReportDownloadSectionState extends State<AIReportDownloadSection> {
  ReportFormat _selectedFormat = ReportFormat.pdf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'リポート形式',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFormatDropdown(),
        const SizedBox(height: AppSpacing.md),
        _buildDownloadButton(),
      ],
    );
  }

  /// 形式選択ドロップダウン
  Widget _buildFormatDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF667EEA)),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReportFormat>(
          value: _selectedFormat,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF667EEA)),
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textPrimary),
          onChanged: (ReportFormat? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFormat = newValue;
              });
            }
          },
          items: const [
            DropdownMenuItem(
              value: ReportFormat.pdf,
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 20,
                    color: Color(0xFF667EEA),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(child: Text('PDF')),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReportFormat.png,
              child: Row(
                children: [
                  Icon(Icons.image, size: 20, color: Color(0xFF667EEA)),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(child: Text('PNG画像')),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReportFormat.json,
              child: Row(
                children: [
                  Icon(Icons.code, size: 20, color: Color(0xFF667EEA)),
                  SizedBox(width: AppSpacing.sm),
                  Flexible(child: Text('JSONデータ')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ダウンロードボタン
  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          widget.onDownloadReport?.call(_selectedFormat);
        },
        icon: _getFormatIcon(_selectedFormat),
        label: Text('${_getFormatText(_selectedFormat)}をダウンロード'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  /// 形式アイコン取得
  Widget _getFormatIcon(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return const Icon(Icons.picture_as_pdf, size: 20);
      case ReportFormat.png:
        return const Icon(Icons.image, size: 20);
      case ReportFormat.json:
        return const Icon(Icons.code, size: 20);
    }
  }

  /// 形式テキスト取得
  String _getFormatText(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.png:
        return 'PNG画像';
      case ReportFormat.json:
        return 'JSONデータ';
    }
  }
}

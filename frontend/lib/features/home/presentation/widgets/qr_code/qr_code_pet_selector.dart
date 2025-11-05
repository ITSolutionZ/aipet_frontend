import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import 'qr_code_display.dart';


/// ペット選択とQRコード表示ウィジェット
///
/// ペット登録用と予約用の両方に対応
class QRCodePetSelector extends StatefulWidget {
  final List<PetProfileEntity> pets;
  final QRCodeType qrType;

  const QRCodePetSelector({
    super.key,
    required this.pets,
    required this.qrType,
  });

  @override
  State<QRCodePetSelector> createState() => _QRCodePetSelectorState();
}

class _QRCodePetSelectorState extends State<QRCodePetSelector> {
  PetProfileEntity? _selectedPet;
  bool _showQRCode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ペット選択ドロップダウン
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.pointGray.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PetProfileEntity>(
              isExpanded: true,
              value: _selectedPet,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ペットを選択',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              items: widget.pets.map((pet) {
                return DropdownMenuItem(
                  value: pet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          pet.typeIcon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pet.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.pointDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (pet) {
                setState(() {
                  _selectedPet = pet;
                  _showQRCode = false;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // QRコード表示ボタン
        if (_selectedPet != null)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showQRCode = !_showQRCode;
                });
              },
              icon: Icon(_showQRCode ? Icons.visibility_off : Icons.qr_code),
              label: Text(_showQRCode ? 'QRコードを隠す' : 'QRコードを表示'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pointBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

        // QRコード表示
        if (_showQRCode && _selectedPet != null) ...[
          const SizedBox(height: 20),
          QRCodeDisplay(pet: _selectedPet!, qrType: widget.qrType),
        ],
      ],
    );
  }
}

/// QRコードタイプ
enum QRCodeType { petRegistration, reservation }

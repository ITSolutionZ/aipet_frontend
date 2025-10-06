import 'package:flutter/material.dart';

/// 폼 상태 관리 Mixin
///
/// 폼의 기본적인 상태 관리 기능을 제공합니다.
mixin FormStateMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDirty = false;
  bool _isValid = false;

  /// 폼 키
  GlobalKey<FormState> get formKey => _formKey;

  /// 로딩 상태
  bool get isLoading => _isLoading;

  /// 폼이 변경되었는지 여부
  bool get isDirty => _isDirty;

  /// 폼이 유효한지 여부
  bool get isValid => _isValid;

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// 폼 변경 상태 설정
  void setDirty(bool dirty) {
    if (_isDirty != dirty) {
      setState(() {
        _isDirty = dirty;
      });
    }
  }

  /// 폼 유효성 상태 설정
  void setValid(bool valid) {
    if (_isValid != valid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  /// 폼 유효성 검사
  bool validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    setValid(isValid);
    return isValid;
  }

  /// 폼 저장
  void saveForm() {
    _formKey.currentState?.save();
  }

  /// 폼 재설정
  void resetForm() {
    _formKey.currentState?.reset();
    setDirty(false);
    setValid(false);
    setLoading(false);
  }

  /// 폼 필드 변경 감지
  void onFieldChanged() {
    setDirty(true);
    // 폼 유효성 재검사 (선택적)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        validateForm();
      }
    });
  }

  /// 폼 제출 처리
  Future<void> submitForm({
    required Future<void> Function() onSubmit,
    VoidCallback? onSuccess,
    Function(Object error)? onError,
    VoidCallback? onFinally,
  }) async {
    if (!validateForm()) {
      return;
    }

    setLoading(true);

    try {
      await onSubmit();
      onSuccess?.call();
    } catch (error) {
      onError?.call(error);
    } finally {
      if (mounted) {
        setLoading(false);
      }
      onFinally?.call();
    }
  }

  /// 에러 메시지 표시
  void showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// 성공 메시지 표시
  void showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  /// 정보 메시지 표시
  void showInfoMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.blue),
      );
    }
  }

  /// 경고 메시지 표시
  void showWarningMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
    }
  }

  /// 확인 다이얼로그 표시
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 로딩 다이얼로그 표시
  void showLoadingDialog({String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[const SizedBox(width: 16), Text(message)],
          ],
        ),
      ),
    );
  }

  /// 로딩 다이얼로그 숨기기
  void hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  /// 폼 초기화 (상속받는 클래스에서 구현)
  void initializeForm();

  /// 폼 정리 (상속받는 클래스에서 구현)
  void disposeForm();

  @override
  void initState() {
    super.initState();
    initializeForm();
  }

  @override
  void dispose() {
    disposeForm();
    super.dispose();
  }
}

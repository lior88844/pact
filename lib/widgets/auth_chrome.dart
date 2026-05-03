import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/tokens.dart';

class PactPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const PactPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: disabled ? AppColors.bg3 : AppColors.ink0,
            borderRadius: BorderRadius.circular(14),
            boxShadow: disabled
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x4D14120C),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: AppText.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: disabled ? AppColors.ink3 : Colors.white,
                    ).copyWith(letterSpacing: -0.15),
                  ),
          ),
        ),
      ),
    );
  }
}

class PactGhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const PactGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Center(
            child: Text(
              label,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.ink1,
              ).copyWith(letterSpacing: -0.07),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthLabeledField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const AuthLabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  State<AuthLabeledField> createState() => _AuthLabeledFieldState();
}

class _AuthLabeledFieldState extends State<AuthLabeledField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused ? AppColors.ink1 : AppColors.hairline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            widget.label.toUpperCase(),
            style: AppText.tracked(size: 9, color: AppColors.ink3),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.youGlow,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            style: AppText.body(
              size: 15,
              weight: FontWeight.w500,
              color: AppColors.ink0,
            ).copyWith(letterSpacing: -0.15),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppText.body(
                size: 15,
                weight: FontWeight.w500,
                color: AppColors.ink4,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

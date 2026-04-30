import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../theme/tokens.dart';
import 'pact_checkbox.dart';

// ─── Editable category label ───────────────────────────────────────────────────
class _EditableLabel extends StatefulWidget {
  final String value;
  final bool interactive;
  final ValueChanged<String>? onChanged;

  const _EditableLabel({required this.value, required this.interactive, this.onChanged});

  @override
  State<_EditableLabel> createState() => _EditableLabelState();
}

class _EditableLabelState extends State<_EditableLabel> {
  bool _editing = false;
  late TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
    _focus.addListener(() { if (!_focus.hasFocus && _editing) setState(() => _editing = false); });
  }

  @override
  void didUpdateWidget(_EditableLabel old) {
    super.didUpdateWidget(old);
    if (!_editing && _ctrl.text != widget.value) _ctrl.text = widget.value;
  }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  void _start() {
    if (!widget.interactive) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _ctrl.selection = TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = AppText.tracked(size: 9.5, color: AppColors.ink2);
    if (_editing) {
      return SizedBox(
        height: 14,
        child: CupertinoTextField(
          controller: _ctrl,
          focusNode: _focus,
          style: style,
          textCapitalization: TextCapitalization.characters,
          padding: EdgeInsets.zero,
          decoration: null,
          maxLength: 14,
          onChanged: (v) => widget.onChanged?.call(v.toUpperCase()),
          onSubmitted: (_) => setState(() => _editing = false),
        ),
      );
    }
    return GestureDetector(
      onTap: _start,
      behavior: HitTestBehavior.opaque,
      child: Text(widget.value, style: style),
    );
  }
}

// ─── Task text input ──────────────────────────────────────────────────────────
class _TaskTextField extends StatefulWidget {
  final String text;
  final bool done;
  final ValueChanged<String>? onChanged;

  const _TaskTextField({required this.text, required this.done, this.onChanged});

  @override
  State<_TaskTextField> createState() => _TaskTextFieldState();
}

class _TaskTextFieldState extends State<_TaskTextField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(_TaskTextField old) {
    super.didUpdateWidget(old);
    if (_ctrl.text != widget.text) {
      final sel = _ctrl.selection;
      _ctrl.text = widget.text;
      _ctrl.selection = sel.isValid ? sel : TextSelection.collapsed(offset: widget.text.length);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      placeholder: "Define today's focus…",
      placeholderStyle: AppText.body(size: 17, weight: FontWeight.w500, color: AppColors.ink4),
      style: AppText.body(
        size: 17,
        weight: FontWeight.w500,
        color: widget.done ? AppColors.ink2 : AppColors.ink0,
        letterSpacing: -0.24,
        height: 1.3,
      ),
      padding: EdgeInsets.zero,
      decoration: null,
      minLines: 1,
      maxLines: 2,
    );
  }
}

// ─── Task row ─────────────────────────────────────────────────────────────────
class TaskRow extends StatefulWidget {
  final Task task;
  final Color color;
  final bool interactive;
  final ValueChanged<String>? onTextChanged;
  final ValueChanged<String>? onLabelChanged;
  final VoidCallback? onToggle;

  const TaskRow({
    super.key,
    required this.task,
    required this.color,
    this.interactive = true,
    this.onTextChanged,
    this.onLabelChanged,
    this.onToggle,
  });

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> {
  bool _flashComplete = false;

  void _handleToggle() {
    if (!widget.interactive || widget.task.text.trim().isEmpty) return;
    if (!widget.task.done) {
      setState(() => _flashComplete = true);
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _flashComplete = false);
      });
    } else {
      HapticFeedback.lightImpact();
    }
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.task.text.trim().isEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      color: _flashComplete ? AppColors.youGlow : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PactCheckbox(
              checked: widget.task.done,
              interactive: widget.interactive && !isEmpty,
              color: widget.color,
              size: 24,
              onTap: _handleToggle,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedOpacity(
                opacity: widget.task.done ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: widget.color.withAlpha(widget.task.done ? 102 : 217),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _EditableLabel(
                          value: widget.task.label,
                          interactive: widget.interactive,
                          onChanged: widget.onLabelChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (widget.interactive)
                      _TaskTextField(
                        text: widget.task.text,
                        done: widget.task.done,
                        onChanged: widget.onTextChanged,
                      )
                    else
                      Text(
                        widget.task.text.isEmpty ? '—' : widget.task.text,
                        style: AppText.body(
                          size: 17,
                          weight: FontWeight.w500,
                          color: widget.task.text.isEmpty
                              ? AppColors.ink4
                              : widget.task.done ? AppColors.ink2 : AppColors.ink0,
                          letterSpacing: -0.24,
                          height: 1.3,
                        ).copyWith(
                          decoration: widget.task.done ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.ink3,
                          fontStyle: widget.task.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Task list ────────────────────────────────────────────────────────────────
class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Color color;
  final bool interactive;
  final ValueChanged<(String, String)>? onTextChanged;
  final ValueChanged<(String, String)>? onLabelChanged;
  final ValueChanged<String>? onToggle;

  const TaskList({
    super.key,
    required this.tasks,
    required this.color,
    this.interactive = true,
    this.onTextChanged,
    this.onLabelChanged,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: cardDecoration(radius: 20),
      child: Column(
        children: List.generate(tasks.length, (i) {
          final task = tasks[i];
          return Column(
            children: [
              if (i > 0)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 38),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.hairline, width: 0.5),
                    ),
                  ),
                ),
              TaskRow(
                key: ValueKey('${task.id}-$interactive'),
                task: task,
                color: color,
                interactive: interactive,
                onTextChanged: (text) => onTextChanged?.call((task.id, text)),
                onLabelChanged: (label) => onLabelChanged?.call((task.id, label)),
                onToggle: () => onToggle?.call(task.id),
              )
                  .animate(delay: (i * 45).ms)
                  .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic)
                  .moveY(begin: 5, end: 0, duration: 340.ms),
            ],
          );
        }),
      ),
    );
  }
}

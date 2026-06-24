import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standardised search input used across all listing screens.
///
/// Height: 46 px | radius: 14 px | white bg with subtle shadow.
/// Wrap with [Expanded] when placing inside a [Row].
class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData prefixIcon;

  const AppSearchField({
    super.key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon = Icons.search_rounded,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.hintText,
      textField: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? AppColors.primary : AppColors.border,
            width: _focused ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _focused
                  ? AppColors.primary.withOpacity(0.10)
                  : AppColors.shadowLight,
              blurRadius: _focused ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: Icon(widget.prefixIcon, size: 20,
                color: _focused ? AppColors.primary : AppColors.textMuted),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            isDense: true,
            filled: false,
          ),
        ),
      ),
    );
  }
}

/// Primary gradient button — full-width by default.
///
/// Matches the theme's [ElevatedButton] height (52 px) and radius (12 px).
/// Use [width] to constrain when you need a fixed-width variant.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final double? width;
  final double height;
  final double radius;
  final double fontSize;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.radius = 12,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !isLoading;
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? const LinearGradient(
                  colors: [AppColors.disabled, AppColors.disabled])
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? () {} : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Standardised error / no-connection state used across all listing screens
/// and full-screen error scenarios.
///
/// Shows a wifi-off icon, an optional title and message, and a Retry button.
/// For listing screens that need pull-to-refresh, wrap this inside a [ListView].
class AppErrorState extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorState({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gradient app bar — primary→secondary left-to-right.
/// Drop-in replacement for [AppBar]; pass [title] for a plain text title
/// or [titleWidget] for a custom title widget.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const GradientAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.bottom,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: AppBar(
        title: titleWidget ?? (title != null ? Text(title!) : null),
        actions: actions,
        leading: leading,
        bottom: bottom,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

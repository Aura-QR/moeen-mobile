import 'package:flutter/material.dart';

/// Template 5 — "زوايا حديثة" (Modern Corner)
///
/// React reference:
/// ```
/// <div absolute inset-0 bg-white />
/// <div absolute left-0  top-0    h-64 w-52 bg-[#F4436C] style={{clipPath:"polygon(0 0,100% 0,0 100%)"}} />
/// <div absolute right-0 top-0    h-64 w-52 bg-[#FFC857] style={{clipPath:"polygon(0 0,100% 0,100% 100%)"}} />
/// <div absolute left-0  bottom-0 h-56 w-52 bg-[#0E9F86] style={{clipPath:"polygon(0 0,0 100%,100% 100%)"}} />
/// <div absolute right-0 bottom-0 h-56 w-52 bg-[#2377B8] style={{clipPath:"polygon(100% 0,0 100%,100% 100%)"}} />
/// ```
/// Tailwind: h-64 = 256px, h-56 = 224px, w-52 = 208px.
///
/// ClipPath polygons map as follows to Flutter CustomClipper(Path):
///   `polygon(0 0, 100% 0, 0 100%)` → top-left right triangle
///   `polygon(0 0, 100% 0, 100% 100%)` → top-right right triangle
///   `polygon(0 0, 0 100%, 100% 100%)` → bottom-left right triangle
///   `polygon(100% 0, 0 100%, 100% 100%)` → bottom-right right triangle
class CertBgModernCorner extends StatelessWidget {
  const CertBgModernCorner({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── White base ──────────────────────────────────────────────────
        Positioned.fill(child: Container(color: Colors.white)),

        // ── Top-left pink triangle  h-64(256) w-52(208) ────────────────
        Positioned(
          left: 0,
          top: 0,
          child: ClipPath(
            clipper: const _TopLeftTriangleClipper(),
            child: Container(
              width: 208,
              height: 256,
              color: const Color(0xFFF4436C),
            ),
          ),
        ),

        // ── Top-right yellow/gold triangle  h-64(256) w-52(208) ────────
        Positioned(
          right: 0,
          top: 0,
          child: ClipPath(
            clipper: const _TopRightTriangleClipper(),
            child: Container(
              width: 208,
              height: 256,
              color: const Color(0xFFFFC857),
            ),
          ),
        ),

        // ── Bottom-left green triangle  h-56(224) w-52(208) ────────────
        Positioned(
          left: 0,
          bottom: 0,
          child: ClipPath(
            clipper: const _BottomLeftTriangleClipper(),
            child: Container(
              width: 208,
              height: 224,
              color: const Color(0xFF0E9F86),
            ),
          ),
        ),

        // ── Bottom-right blue triangle  h-56(224) w-52(208) ────────────
        Positioned(
          right: 0,
          bottom: 0,
          child: ClipPath(
            clipper: const _BottomRightTriangleClipper(),
            child: Container(
              width: 208,
              height: 224,
              color: const Color(0xFF2377B8),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Clip path implementations ─────────────────────────────────────────────

/// polygon(0 0, 100% 0, 0 100%) — top-left right triangle
class _TopLeftTriangleClipper extends CustomClipper<Path> {
  const _TopLeftTriangleClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(size.width, 0)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

/// polygon(0 0, 100% 0, 100% 100%) — top-right right triangle
class _TopRightTriangleClipper extends CustomClipper<Path> {
  const _TopRightTriangleClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

/// polygon(0 0, 0 100%, 100% 100%) — bottom-left right triangle
class _BottomLeftTriangleClipper extends CustomClipper<Path> {
  const _BottomLeftTriangleClipper();

  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height)
    ..lineTo(size.width, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

/// polygon(100% 0, 0 100%, 100% 100%) — bottom-right right triangle
class _BottomRightTriangleClipper extends CustomClipper<Path> {
  const _BottomRightTriangleClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(0, size.height)
    ..lineTo(size.width, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

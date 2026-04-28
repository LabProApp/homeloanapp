// Shared helpers for all agreement templates
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

final dateFmt  = DateFormat('dd MMMM yyyy');
final moneyFmt = NumberFormat('#,##,###');

/// Converts integer rupee amount to Indian English words.
String inWords(int amount) {
  if (amount == 0) return 'Zero Only';
  const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
    'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
    'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
  const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty',
    'Sixty', 'Seventy', 'Eighty', 'Ninety'];

  String convert(int n) {
    if (n < 20)     return ones[n];
    if (n < 100)    return '${tens[n ~/ 10]}${n % 10 > 0 ? " ${ones[n % 10]}" : ""}';
    if (n < 1000)   return '${ones[n ~/ 100]} Hundred${n % 100 > 0 ? " ${convert(n % 100)}" : ""}';
    if (n < 100000) return '${convert(n ~/ 1000)} Thousand${n % 1000 > 0 ? " ${convert(n % 1000)}" : ""}';
    if (n < 10000000) return '${convert(n ~/ 100000)} Lakh${n % 100000 > 0 ? " ${convert(n % 100000)}" : ""}';
    return '${convert(n ~/ 10000000)} Crore${n % 10000000 > 0 ? " ${convert(n % 10000000)}" : ""}';
  }
  return '${convert(amount)} Only';
}

// ── PDF helpers ──────────────────────────────────────────────────────────────

pw.Widget pdfSection(String title, List<pw.Widget> children) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 12),
      pw.Text(title,
          style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline)),
      pw.SizedBox(height: 6),
      ...children,
    ],
  );
}

pw.Widget pdfPara(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: pw.TextAlign.justify),
  );
}

pw.Widget pdfSignatureRow(String leftRole, String leftName, String rightRole, String rightName) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      _pdfSigBlock(leftRole, leftName),
      _pdfSigBlock(rightRole, rightName),
    ],
  );
}

pw.Widget _pdfSigBlock(String role, String name) {
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Container(width: 150, height: 1, color: PdfColors.black),
    pw.SizedBox(height: 4),
    pw.Text('$role Signature', style: const pw.TextStyle(fontSize: 10)),
    pw.Text(name, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    pw.Text('Date: ________________', style: const pw.TextStyle(fontSize: 9)),
  ]);
}

pw.Widget pdfFooter(String city) {
  return pw.Column(children: [
    pw.SizedBox(height: 20),
    pw.Center(child: pw.Text(
      'Witness 1: _______________________    Witness 2: _______________________',
      style: const pw.TextStyle(fontSize: 9),
    )),
    pw.SizedBox(height: 8),
    pw.Center(child: pw.Text(
      'Note: This agreement should be registered/notarized for legal validity as per applicable Indian law. '
      'Courts at $city shall have jurisdiction.',
      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
    )),
  ]);
}

// ── Flutter preview helpers ──────────────────────────────────────────────────

Widget previewSection(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            decoration: TextDecoration.underline)),
  );
}

Widget previewPara(String text) {
  return Text(text,
      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.5),
      textAlign: TextAlign.justify);
}

Widget previewKV(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 140,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}

Widget previewSignatureRow(String leftRole, String leftName, String rightRole, String rightName) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _flutterSigBlock(leftRole, leftName),
      _flutterSigBlock(rightRole, rightName),
    ],
  );
}

Widget _flutterSigBlock(String role, String name) {
  return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
    Container(width: 130, height: 40, color: const Color(0xFFF5F5F5)),
    const SizedBox(height: 4),
    Text(role, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    const Text('Date: ___________',
        style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
  ]);
}

Widget draftBanner() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFFB74D)),
    ),
    child: const Row(children: [
      Icon(Icons.info_outline, color: Color(0xFFE65100), size: 18),
      SizedBox(width: 8),
      Expanded(child: Text(
        'This is a draft document. It should be registered/notarized for full legal validity.',
        style: TextStyle(fontSize: 11, color: Color(0xFFBF360C)),
      )),
    ]),
  );
}

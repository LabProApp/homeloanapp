import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/app_colors.dart';
import 'agreement_helpers.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class RentAgreementData {
  final String propAddress, propCity, propState, propPincode, propType, furnishing;
  final DateTime startDate;
  final String ownerName, ownerAddress, ownerIdType, ownerIdNo, ownerPhone;
  final String tenantName, tenantAddress, tenantIdType, tenantIdNo, tenantPhone;
  final int monthlyRent, securityDeposit, maintenance;
  final int durationMonths, noticePeriod, lockIn;
  final String rentDay;
  final List<String> furnishedItems;
  final String additionalTerms;

  const RentAgreementData({
    required this.propAddress, required this.propCity, required this.propState,
    required this.propPincode, required this.propType, required this.furnishing,
    required this.startDate, required this.ownerName, required this.ownerAddress,
    required this.ownerIdType, required this.ownerIdNo, required this.ownerPhone,
    required this.tenantName, required this.tenantAddress, required this.tenantIdType,
    required this.tenantIdNo, required this.tenantPhone, required this.monthlyRent,
    required this.securityDeposit, required this.maintenance, required this.durationMonths,
    required this.noticePeriod, required this.lockIn, required this.rentDay,
    required this.furnishedItems, required this.additionalTerms,
  });
}

// ── Template ─────────────────────────────────────────────────────────────────

class RentAgreementTemplate {

  static Future<pw.Document> buildPdf(RentAgreementData d) async {
    final pdf = pw.Document();
    final endDate = DateTime(d.startDate.year, d.startDate.month + d.durationMonths, d.startDate.day);

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => [
        pw.Center(child: pw.Column(children: [
          pw.Text('LEAVE AND LICENSE AGREEMENT',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('(Rent Agreement)', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 4),
          pw.Text('This Agreement is made at ${d.propCity} on ${dateFmt.format(d.startDate)}',
              style: const pw.TextStyle(fontSize: 10)),
        ])),
        pw.Divider(height: 20),

        pdfSection('BETWEEN THE PARTIES', [
          pdfPara('LICENSOR (Owner): ${d.ownerName}, residing at ${d.ownerAddress}, '
              'bearing ${d.ownerIdType} No. ${d.ownerIdNo}, '
              'hereinafter referred to as the "Owner" (of the First Part).'),
          pdfPara('LICENSEE (Tenant): ${d.tenantName}, residing at ${d.tenantAddress}, '
              'bearing ${d.tenantIdType} No. ${d.tenantIdNo}, '
              'hereinafter referred to as the "Tenant" (of the Second Part).'),
        ]),

        pdfSection('SCHEDULE OF PROPERTY', [
          pdfPara('The Owner hereby grants leave and license to the Tenant for the following '
              'property: ${d.propType} situated at ${d.propAddress}, ${d.propCity}, '
              '${d.propState} - ${d.propPincode}. The property is ${d.furnishing.toLowerCase()}.'),
        ]),

        pdfSection('DURATION', [
          pdfPara('This Agreement shall be valid for a period of ${d.durationMonths} months, '
              'commencing from ${dateFmt.format(d.startDate)} and ending on '
              '${dateFmt.format(endDate)}, unless terminated earlier as per the terms herein.'),
          if (d.lockIn > 0)
            pdfPara('Lock-in Period: ${d.lockIn} month(s) from the date of commencement.'),
          pdfPara('Notice Period: ${d.noticePeriod} month(s) written notice required by either party for termination.'),
        ]),

        pdfSection('LICENSE FEE AND DEPOSIT', [
          pdfPara('Monthly License Fee (Rent): ₹${moneyFmt.format(d.monthlyRent)} '
              '(Rupees ${inWords(d.monthlyRent)}), payable on or before the ${d.rentDay} of each month.'),
          pdfPara('Security Deposit: ₹${moneyFmt.format(d.securityDeposit)} '
              '(Rupees ${inWords(d.securityDeposit)}), refundable at the end of the agreement '
              'period subject to deductions for damages if any.'),
          if (d.maintenance > 0)
            pdfPara('Maintenance Charges: ₹${moneyFmt.format(d.maintenance)} per month, payable along with the rent.'),
        ]),

        if (d.furnishedItems.isNotEmpty)
          pdfSection('FURNISHING DETAILS', [
            pdfPara('The following items are provided by the Owner in the premises:'),
            pw.Wrap(spacing: 12,
                children: d.furnishedItems.map((e) =>
                    pw.Text('• $e', style: const pw.TextStyle(fontSize: 10))).toList()),
          ]),

        pdfSection('TERMS AND CONDITIONS', [pdfPara(d.additionalTerms)]),

        pdfSection('GENERAL CONDITIONS', [
          pdfPara('1. This Agreement shall be governed by the laws of India.'),
          pdfPara('2. Any dispute shall be subject to the jurisdiction of courts at ${d.propCity}.'),
          pdfPara('3. Both parties have read and understood the terms of this Agreement.'),
          pdfPara('4. This Agreement constitutes the entire agreement and supersedes all prior negotiations.'),
        ]),

        pw.SizedBox(height: 40),
        pdfSignatureRow('Owner', d.ownerName, 'Tenant', d.tenantName),
        pdfFooter(d.propCity),
      ],
    ));
    return pdf;
  }

  static Widget buildPreview(RentAgreementData d) {
    final endDate = DateTime(d.startDate.year, d.startDate.month + d.durationMonths, d.startDate.day);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Center(child: Text('LEAVE AND LICENSE AGREEMENT',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
      const Center(child: Text('(Rent Agreement)',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      const SizedBox(height: 4),
      Center(child: Text('Made at ${d.propCity} on ${dateFmt.format(d.startDate)}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      const Divider(height: 24),

      previewSection('BETWEEN THE PARTIES'),
      previewPara('LICENSOR (Owner): ${d.ownerName}, residing at ${d.ownerAddress}, '
          'bearing ${d.ownerIdType} No. ${d.ownerIdNo}.'),
      const SizedBox(height: 6),
      previewPara('LICENSEE (Tenant): ${d.tenantName}, residing at ${d.tenantAddress}, '
          'bearing ${d.tenantIdType} No. ${d.tenantIdNo}.'),

      previewSection('SCHEDULE OF PROPERTY'),
      previewPara('${d.propType} at ${d.propAddress}, ${d.propCity}, ${d.propState} - ${d.propPincode}. (${d.furnishing})'),

      previewSection('DURATION'),
      previewPara('${d.durationMonths} months: ${dateFmt.format(d.startDate)} to ${dateFmt.format(endDate)}.'),
      if (d.lockIn > 0) previewPara('Lock-in: ${d.lockIn} month(s).'),
      previewPara('Notice period: ${d.noticePeriod} month(s).'),

      previewSection('LICENSE FEE & DEPOSIT'),
      previewKV('Monthly Rent', '₹ ${moneyFmt.format(d.monthlyRent)} (${inWords(d.monthlyRent)})'),
      previewKV('Security Deposit', '₹ ${moneyFmt.format(d.securityDeposit)} (${inWords(d.securityDeposit)})'),
      if (d.maintenance > 0)
        previewKV('Maintenance', '₹ ${moneyFmt.format(d.maintenance)}/month'),
      previewKV('Rent Due', '${d.rentDay} of each month'),

      if (d.furnishedItems.isNotEmpty) ...[
        previewSection('FURNISHING'),
        previewPara(d.furnishedItems.join(' • ')),
      ],

      previewSection('TERMS & CONDITIONS'),
      previewPara(d.additionalTerms),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),
      previewSignatureRow('Owner', d.ownerName, 'Tenant', d.tenantName),
      const SizedBox(height: 16),
      const Center(child: Text('Witness 1: ___________________    Witness 2: ___________________',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
    ]);
  }
}


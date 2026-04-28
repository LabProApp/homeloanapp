import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/app_colors.dart';
import 'agreement_helpers.dart';

// ── Data model ───────────────────────────────────────────────────────────────

class SaleAgreementData {
  final String propAddress, propCity, propState, propPincode, propType;
  final String sellerName, sellerAddress, sellerIdType, sellerIdNo, sellerPhone;
  final String buyerName, buyerAddress, buyerIdType, buyerIdNo, buyerPhone;
  final int saleConsideration;
  final int tokenAmount;
  final DateTime tokenDate;
  final DateTime balanceDate;
  final DateTime possessionDate;
  final String paymentMode;
  final String additionalTerms;

  int get balanceAmount => saleConsideration - tokenAmount;

  const SaleAgreementData({
    required this.propAddress, required this.propCity, required this.propState,
    required this.propPincode, required this.propType,
    required this.sellerName, required this.sellerAddress,
    required this.sellerIdType, required this.sellerIdNo, required this.sellerPhone,
    required this.buyerName, required this.buyerAddress,
    required this.buyerIdType, required this.buyerIdNo, required this.buyerPhone,
    required this.saleConsideration, required this.tokenAmount,
    required this.tokenDate, required this.balanceDate, required this.possessionDate,
    required this.paymentMode, required this.additionalTerms,
  });
}

// ── Template ─────────────────────────────────────────────────────────────────

class SaleAgreementTemplate {

  static Future<pw.Document> buildPdf(SaleAgreementData d) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => [
        pw.Center(child: pw.Column(children: [
          pw.Text('AGREEMENT FOR SALE',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('(Beana / Memorandum of Understanding)', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 4),
          pw.Text('This Agreement is made at ${d.propCity} on ${dateFmt.format(d.tokenDate)}',
              style: const pw.TextStyle(fontSize: 10)),
        ])),
        pw.Divider(height: 20),

        pdfSection('BETWEEN THE PARTIES', [
          pdfPara('VENDOR (Seller): ${d.sellerName}, residing at ${d.sellerAddress}, '
              'bearing ${d.sellerIdType} No. ${d.sellerIdNo}, '
              'hereinafter referred to as the "Seller" (of the First Part).'),
          pdfPara('PURCHASER (Buyer): ${d.buyerName}, residing at ${d.buyerAddress}, '
              'bearing ${d.buyerIdType} No. ${d.buyerIdNo}, '
              'hereinafter referred to as the "Buyer" (of the Second Part).'),
        ]),

        pdfSection('SCHEDULE OF PROPERTY', [
          pdfPara('The Seller agrees to sell and the Buyer agrees to purchase the following '
              'immovable property: ${d.propType} situated at ${d.propAddress}, '
              '${d.propCity}, ${d.propState} - ${d.propPincode} '
              '(hereinafter referred to as the "Said Property").'),
        ]),

        pdfSection('SALE CONSIDERATION', [
          pdfPara('The total Sale Consideration mutually agreed for the Said Property is '
              '₹${moneyFmt.format(d.saleConsideration)} '
              '(Rupees ${inWords(d.saleConsideration)}).'),
          pdfPara('Token/Advance Amount: The Buyer has paid ₹${moneyFmt.format(d.tokenAmount)} '
              '(Rupees ${inWords(d.tokenAmount)}) as token/advance (Beana) on '
              '${dateFmt.format(d.tokenDate)} via ${d.paymentMode}. '
              'The Seller acknowledges receipt of the same.'),
          pdfPara('Balance Amount: The remaining balance of '
              '₹${moneyFmt.format(d.balanceAmount)} '
              '(Rupees ${inWords(d.balanceAmount)}) shall be paid on or before '
              '${dateFmt.format(d.balanceDate)}.'),
        ]),

        pdfSection('POSSESSION & REGISTRATION', [
          pdfPara('The Seller shall hand over vacant possession of the Said Property to the Buyer on '
              'or before ${dateFmt.format(d.possessionDate)}.'),
          pdfPara('The Sale Deed shall be executed and registered at the Office of the Sub-Registrar '
              'of Assurances upon receipt of the full Sale Consideration by the Seller.'),
          pdfPara('All stamp duty and registration charges shall be borne by the Buyer.'),
        ]),

        pdfSection('SELLER\'S OBLIGATIONS', [
          pdfPara('1. The Seller declares that the Said Property is free from all encumbrances, '
              'mortgages, charges, liens, court attachments, government acquisition, and litigation.'),
          pdfPara('2. The Seller shall clear all outstanding dues including property tax, '
              'society maintenance, electricity, and water charges up to the date of possession.'),
          pdfPara('3. The Seller shall hand over all original title documents at the time of registration.'),
          pdfPara('4. The Seller has the lawful right to sell the Said Property and there are no '
              'co-owners or other parties whose consent is required, or if there are, such consent '
              'has already been obtained.'),
        ]),

        pdfSection('DEFAULT AND REMEDIES', [
          pdfPara('If the Buyer fails to complete the transaction within the stipulated time without '
              'valid reason, the Seller shall be entitled to forfeit the token/advance amount paid.'),
          pdfPara('If the Seller fails to complete the transaction or backs out without valid reason, '
              'the Seller shall be liable to refund double the token/advance amount to the Buyer.'),
        ]),

        pdfSection('TERMS AND CONDITIONS', [pdfPara(d.additionalTerms)]),

        pdfSection('GENERAL CONDITIONS', [
          pdfPara('1. This Agreement shall be governed by the Transfer of Property Act, 1882 and laws of India.'),
          pdfPara('2. Any dispute shall be subject to the jurisdiction of courts at ${d.propCity}.'),
          pdfPara('3. This Agreement does not by itself create any right, title, or interest in the Said Property.'),
          pdfPara('4. Both parties have read and understood the contents of this Agreement.'),
        ]),

        pw.SizedBox(height: 40),
        pdfSignatureRow('Seller', d.sellerName, 'Buyer', d.buyerName),
        pdfFooter(d.propCity),
      ],
    ));
    return pdf;
  }

  static Widget buildPreview(SaleAgreementData d) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Center(child: Text('AGREEMENT FOR SALE',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
      const Center(child: Text('(Beana / Memorandum of Understanding)',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      const SizedBox(height: 4),
      Center(child: Text('Made at ${d.propCity} on ${dateFmt.format(d.tokenDate)}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      const Divider(height: 24),

      previewSection('BETWEEN THE PARTIES'),
      previewPara('VENDOR (Seller): ${d.sellerName}, residing at ${d.sellerAddress}, '
          'bearing ${d.sellerIdType} No. ${d.sellerIdNo}.'),
      const SizedBox(height: 6),
      previewPara('PURCHASER (Buyer): ${d.buyerName}, residing at ${d.buyerAddress}, '
          'bearing ${d.buyerIdType} No. ${d.buyerIdNo}.'),

      previewSection('SCHEDULE OF PROPERTY'),
      previewPara('${d.propType} at ${d.propAddress}, ${d.propCity}, ${d.propState} - ${d.propPincode}'),

      previewSection('SALE CONSIDERATION'),
      previewKV('Total Sale Price', '₹ ${moneyFmt.format(d.saleConsideration)} (${inWords(d.saleConsideration)})'),
      previewKV('Token/Advance (Beana)', '₹ ${moneyFmt.format(d.tokenAmount)} paid on ${dateFmt.format(d.tokenDate)}'),
      previewKV('Payment Mode', d.paymentMode),
      previewKV('Balance Amount', '₹ ${moneyFmt.format(d.balanceAmount)} payable by ${dateFmt.format(d.balanceDate)}'),

      previewSection('POSSESSION & REGISTRATION'),
      previewKV('Possession Date', dateFmt.format(d.possessionDate)),
      previewPara('Sale Deed to be registered upon receipt of full consideration. '
          'Stamp duty & registration charges to be borne by Buyer.'),

      previewSection('TERMS & CONDITIONS'),
      previewPara(d.additionalTerms),

      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),
      previewSignatureRow('Seller', d.sellerName, 'Buyer', d.buyerName),
      const SizedBox(height: 16),
      const Center(child: Text('Witness 1: ___________________    Witness 2: ___________________',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary))),
    ]);
  }
}

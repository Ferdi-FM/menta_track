import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../generated/l10n.dart';

class BarcodeScannerSimple extends StatefulWidget {

  const BarcodeScannerSimple({
    super.key,
  });

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;
  bool codeFound = false;

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return Text(
        S.of(context).qr_desc,
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      S.of(context).qr_success,
      //value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }


  Future<void> _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted && !codeFound) {
        codeFound = true; //Hier, damit der Barcode nicht mehrmals gescannt wird was zu crashes führt im Zusammenhang mit dem 1sekunden delay
        _barcode = barcodes.barcodes.firstOrNull;
        setState(() {
          _barcode;
        });
        await Future.delayed(const Duration(seconds: 1)); //Warte 1 Sekunde
        returnToPage();
    }
  }

  void returnToPage(){
    if (mounted) Navigator.of(context).pop(_barcode!.displayValue!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR-Scanner")),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _buildBarcode(_barcode))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
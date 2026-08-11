import 'package:flutter/material.dart';

class VisaCardDisplay extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;

  const VisaCardDisplay({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    String formattedNumber = cardNumber.replaceAll(' ', '').padRight(16, '*');
    if (formattedNumber.length > 16) formattedNumber = formattedNumber.substring(0, 16);
    formattedNumber = '${formattedNumber.substring(0,4)} ${formattedNumber.substring(4,8)} ${formattedNumber.substring(8,12)} ${formattedNumber.substring(12,16)}';

    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
              ),
              Container(
                width: 45,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.amber.shade300,
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade200, Colors.amber.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              formattedNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 4,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      expiryDate.isEmpty ? 'MM/YY' : expiryDate,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cardHolder.isEmpty ? 'NAME ON CARD' : cardHolder.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

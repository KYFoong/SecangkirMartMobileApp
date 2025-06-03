import 'package:flutter/material.dart';

final ButtonStyle payButton = ElevatedButton.styleFrom(
  minimumSize: const Size(110, 70),
  backgroundColor: const Color(0xFFC59D54),
  elevation: 0,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(0))
  )
);

final ButtonStyle roundedButton = ElevatedButton.styleFrom(
  minimumSize: const Size(370, 50),
  backgroundColor: const Color(0xFFC59D54),
  elevation: 5,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
  )
);

final ButtonStyle rectangleRoundCorner = ElevatedButton.styleFrom(
  minimumSize: const Size(165, 45),
  backgroundColor: const Color(0xFFC59D54),
  elevation: 5,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
  )
);

const TextStyle orderStatusButton = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
  color: Colors.white
);

const TextStyle orderCardText = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 18,
);
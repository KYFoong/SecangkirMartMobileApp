import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
            )
          ),
        backgroundColor: const Color(0xFFC59D54),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined
          ),
          iconSize: 32,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Image(
              image: AssetImage('lib/assets/logo.png'),
              width: 200,
              fit: BoxFit.contain,
            ),
        
            const SizedBox(height: 10,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align all text widgets to the left
              children: [
                Text(
                  'Secangkir Coopitiam are located in Taman Universiti, Parit Raja. Near to Universiti Tun Hussein Onn Malaysia, this cafe serves the perfect coffee for those who seek an exclusive and conducive environment! If you have questions or comments, please get a hold of us in whichever way is most convenient. Ask away. There is no reasonable question that our team cannot answer.',
                  style: text(),
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.justify, // Allow text to expand as needed
                ),
                const SizedBox(height: 20), // Add spacing between description and next texts
                Text('Version 1.0.0', style: text().copyWith(fontWeight: FontWeight.bold)),
                Text('05 / 01 / 2025', style: text().copyWith(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  TextStyle text(){
    return const TextStyle(
      fontSize: 16,
    );
  }
}
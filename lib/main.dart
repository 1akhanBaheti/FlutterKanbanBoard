import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/inputs.dart';

import 'custom/board.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    KanbanBoard(
      [
        BoardListsData(title: 'Pending', items: []),
        BoardListsData(title: 'Todo', items: []),
        BoardListsData(
            title: 'In Progress',
            items: List.generate(
              3,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(12),
                child: Text("In Progress $index",
                    style: GoogleFonts.firaSans(
                        fontSize: 16,
                        height: 1.3,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500)),
              ),
            )),
        BoardListsData(
            title: 'Completed',
            items: List.generate(
              1,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
          
                padding: const EdgeInsets.all(12),
                child: Text("Completed $index",
                    style: GoogleFonts.firaSans(
                        fontSize: 16,
                        height: 1.3,
                        color: const Color.fromRGBO(22, 163, 74, 1),
                        fontWeight: FontWeight.w500)),
              ),
            )),
         BoardListsData(
            title: 'Rejected',
            items: List.generate(
              1,
              (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade200),
                ),
              
                padding: const EdgeInsets.all(12),
                child: Text("Rejected $index",
                    style: GoogleFonts.firaSans(
                        fontSize: 16,
                        height: 1.3,
                        color: const Color.fromRGBO(239, 68, 68, 1),
                        fontWeight: FontWeight.w500)),
              ),
            )),
      
      ],
  
      backgroundColor: Colors.white,
      listScrollConfig: ScrollConfig(
          offset: 65,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear),
      listTransitionDuration: const Duration(milliseconds: 200),
      cardTransitionDuration: const Duration(milliseconds: 400),
      textStyle: GoogleFonts.firaSans(
          fontSize: 17,
          color: Colors.black,
          fontWeight: FontWeight.w500),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    BoardListsData(items: []);

    return Scaffold(
        body: Container(
            color: Colors.black,
            //  margin: const EdgeInsets.only(top: 24),
            child: Container()));
  }
}

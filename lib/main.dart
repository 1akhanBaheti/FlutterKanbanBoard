import 'package:boardview/a.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './custom/reorder.dart';

void main() {
  runApp(
    const ProviderScope(
      child: 
     MaterialApp(debugShowCheckedModeBanner: false,home:  MyApp()))
  );
   
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    return  Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            elevation: 0,
            title: const Text('Play Ground'),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const Reorder()));
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 10),
                  child: const Text("TESTING",style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                   fontWeight: FontWeight.w500
                  ),)
                ),
              )
            ],
          ),
          body: Container(
            color: Colors.black,
          //  margin: const EdgeInsets.only(top: 24),
             padding: const EdgeInsets.only(top: 24,left: 25),
            child: MyApp1())
       
    );
  }
}

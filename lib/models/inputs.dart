import 'package:flutter/material.dart';

class BoardListsData {
  final String? title;
  Widget? header;
  Color? headerBackgroundColor;
  Color? footerBackgroundColor;
  Widget? footer;
  final List<Widget> items;
  Color? backgroundColor;
  double width;
  BoardListsData({
    this.title,
    this.header,
    this.footer,
    required this.items,
    this.footerBackgroundColor=const Color.fromRGBO(247, 248, 252, 1),
    this.headerBackgroundColor=const Color.fromARGB(255,247, 248, 252),
    this.backgroundColor=const Color.fromARGB(255,247, 248, 252,),
    this.width = 300,
  }) {
    footer = footer ??
        Container(
          padding: const EdgeInsets.only(left: 15),
          height: 45,
          width: 300,
          color: footerBackgroundColor,
          child: Row(
            children: const [
              Icon(
                Icons.add,
                color: Colors.black,
                size: 22,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'NEW',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
    header = header ??
        Container(
          width: 250,
          color: headerBackgroundColor,
          padding: const EdgeInsets.only(left: 0, bottom: 12, top: 12),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title ?? '',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                child: const SizedBox(
                    // padding: const EdgeInsets.all(5),
                    child:  Icon(Icons.more_vert)),
              ),
            ],
          ),
        );
  }
}

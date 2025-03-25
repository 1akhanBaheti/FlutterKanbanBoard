import 'package:flutter/material.dart';

Map<String, dynamic> kanbanData = {
  'Blocked': {
    'color': const Color.fromRGBO(239, 147, 148, 1),
    'items': [
      {
        'title': 'Making A New Trend In Poster',
        'date': '17 Dec 2022',
        'tasks': '30/48'
      },
      {'title': 'Create Remarkable', 'date': '17 Nov 2022', 'tasks': '15/56'},
    ]
  },
  'Pending': {
    'color': const Color.fromRGBO(239, 147, 148, 1),
    'items': [
      {
        'title': 'Making A New Trend In Poster',
        'date': '17 Dec 2022',
        'tasks': '30/48'
      },
      {'title': 'Create Remarkable', 'date': '17 Nov 2022', 'tasks': '15/56'},
      {
        'title': 'Advertisers Embrace Rich Media',
        'date': '22 Oct 2022',
        'tasks': '18/67'
      },
      {
        'title': 'Meet the People Who Train',
        'date': '15 Dec 2022',
        'tasks': '24/46'
      }
    ]
  },
  'In progress': {
    'color': const Color.fromRGBO(255, 230, 168, 1),
    'items': [
      {
        'title': 'Advertising Outdoors',
        'date': '17 Dec 2022',
        'tasks': '53/70'
      },
      {'title': 'Create Remarkable', 'date': '17 Nov 2022', 'tasks': '15/56'},
      {
        'title': 'Manufacturing Equipment',
        'date': '17 Dec 2022',
        'tasks': '35/65'
      },
      {
        'title': 'Advertising Outdoors',
        'date': '17 Dec 2022',
        'tasks': '13/29'
      },
      {
        'title': 'Truck Side Advertising Time',
        'date': '17 Dec 2022',
        'tasks': '39/50'
      },
      {
        'title': 'Importance of The Custom',
        'date': '17 Dec 2022',
        'tasks': '30/90'
      },
    ]
  },
  'Done': {
    'color': const Color.fromRGBO(148, 235, 168, 1),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20'
      },
      {
        'title': 'Promotional Advertising Speciality',
        'date': '17 Nov 2022',
        'tasks': '15/15'
      },
      {
        'title': 'Search Engine OPtimization',
        'date': '22 Oct 2022',
        'tasks': '67/67'
      },
    ]
  },
};

  List<String> persons = [
    'assets/person1.jpg',
    'assets/person2.jpg',
    'assets/person3.jpg',
    'assets/person4.jpg',
  ];

import 'package:flutter/material.dart';
import 'package:kanban/models/kanban_group.dart';
import 'package:kanban_board/kanban_board.dart';

Map<String, dynamic> _kanbanData = {
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
        'tasks': '53/70',
      },
      {
        'title': 'Digital Marketing Campaign',
        'date': '21 Dec 2022',
        'tasks': '34/60',
      },
      {
        'title': 'Social Media Strategy',
        'date': '15 Dec 2022',
        'tasks': '28/45',
      },
      {
        'title': 'Content Creation Plan',
        'date': '19 Dec 2022',
        'tasks': '41/65',
      },
      {
        'title': 'Email Newsletter Design',
        'date': '22 Dec 2022',
        'tasks': '37/50',
      },
      {
        'title': 'Brand Identity Update',
        'date': '18 Dec 2022',
        'tasks': '45/75',
      },
    ]
  },
  'Testing': {
    'color': const Color.fromARGB(255, 235, 235, 148),
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
  'Review': {
    'color': const Color.fromARGB(255, 250, 234, 89),
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
  'Staging': {
    'color': const Color.fromARGB(255, 8, 61, 232),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20'
      },
    ]
  },
  'Production': {
    'color': const Color.fromARGB(255, 0, 248, 58),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20'
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
  'Blocked': {
    'color': const Color.fromARGB(255, 0, 0, 0),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '17 Dec 2022',
        'tasks': '30/48'
      },
      {'title': 'Create Remarkable', 'date': '17 Nov 2022', 'tasks': '15/56'},
    ]
  },
  'Cancelled': {
    'color': const Color.fromARGB(255, 248, 41, 30),
    'items': [
      {
        'title': 'Creative Outdoor Ads',
        'date': '23 Dec 2022',
        'tasks': '20/20'
      },
    ]
  },
};

List<String> avatars = [
  'assets/person1.jpg',
  'assets/person2.jpg',
  'assets/person3.jpg',
  'assets/person4.jpg',
];

List<KanbanBoardGroup<KanbanGroup,KanbanGroupItem>> kanbanGroups = List.generate(
  _kanbanData.length,
  (index) => KanbanBoardGroup(
    customData: KanbanGroup(
      id: _kanbanData.keys.elementAt(index),
      title: _kanbanData.keys.elementAt(index),
      color: _kanbanData.values.elementAt(index)['color'],
    ),
    id: _kanbanData.keys.elementAt(index),
    name: _kanbanData.keys.elementAt(index),
    items: (_kanbanData.values.elementAt(index)['items'] as List).indexed
        .map<KanbanGroupItem>((item) {
          return KanbanGroupItem(
            itemId: item.$1.toString(),
            title: item.$2['title'],
            date: item.$2['date'],
            avatar: avatars[item.$1 % 4],
            completedTasks: int.parse(item.$2['tasks'].toString().split('/').first),
            totalTasks: int.parse(item.$2['tasks'].toString().split('/').last),
          );
        })
        .toList(),
  ),
);

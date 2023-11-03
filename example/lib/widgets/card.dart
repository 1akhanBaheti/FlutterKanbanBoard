import 'package:flutter/material.dart';

class KanbanCard extends StatelessWidget {
  const KanbanCard(
      {super.key,
      required this.title,
      required this.completedTasks,
      required this.totalTasks,
      required this.date, required this.tasks, required this.avatar});
  final String title;
  final int completedTasks;
  final int totalTasks;
  final String date;
  final String tasks;
  final String avatar;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            width: 1,
            color: const Color.fromRGBO(162, 163, 160, 1),
          )),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 3,
            width: 300,
            decoration: BoxDecoration(
                color: (completedTasks / totalTasks) < 0.5
                    ? const Color.fromRGBO(228, 160, 159, 1)
                    : (completedTasks / totalTasks) < 0.7
                        ? const Color.fromRGBO(245, 234, 163, 1)
                        : const Color.fromRGBO(152, 233, 182, 1)),
            child: Row(
              children: [
                Container(
                  width: 300 * (completedTasks / totalTasks),
                  color: (completedTasks / totalTasks) < 0.5
                      ? const Color.fromRGBO(168, 109, 113, 1)
                      : (completedTasks / totalTasks) < 0.7
                          ? const Color.fromRGBO(174, 168, 120, 1)
                          : const Color.fromRGBO(113, 164, 131, 1),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(width: 1, color: Colors.black),
                ),
                child: Text(date,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              const Icon(
                Icons.done_all,
                color: Colors.black,
                size: 18,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(tasks,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(left: 10),
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.asset(avatar).image),
                    color: const Color.fromRGBO(174, 122, 255, 1),
                    borderRadius: BorderRadius.circular(30)),
              )
            ],
          )
        ],
      ),
    );
  }
}

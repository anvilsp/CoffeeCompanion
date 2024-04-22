import 'package:flutter/material.dart';
import 'package:coffee_companion/components/roast_edit.dart';
import '../entity/roast.dart';
import 'package:intl/intl.dart';

class RoastEntry extends StatefulWidget {
  // this component takes in a Roast object and displays its properties - allows the user to edit
  final Roast roast;
  final f = DateFormat('MM-dd-yyyy');
  final VoidCallback? onRoastModified;

  RoastEntry({super.key, this.onRoastModified, required this.roast});
  
  @override
  State<RoastEntry> createState() => _RoastEntryState();
}

class _RoastEntryState extends State<RoastEntry> {

  void reloadModule() {
    print("roast edited!");
    widget.onRoastModified!();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 125,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget> [
                  Text(widget.roast.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department),
                      Text(widget.roast.roastLevel),
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month),
                      Text(widget.f.format(DateTime.fromMillisecondsSinceEpoch(widget.roast.date)).toString()),
                    ]
                  )
                ]
              ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  backgroundColor: Colors.black.withOpacity(0.0),
                  elevation: 0,
                ),
                onPressed: () {
                  print(widget.roast.id);
                  showDialog(
                    context: context,
                    builder: (context) => RoastEdit(
                      roast: widget.roast,
                      onRoastEdited: reloadModule,
                    )
                  );
                },
                child: const Icon(Icons.edit)
              )
            ]
          )
        ]
      ),
    );
  }
}
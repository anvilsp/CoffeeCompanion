import 'package:coffee_companion/app_database.dart';
import 'package:flutter/material.dart';
import 'package:coffee_companion/entity/roast.dart';
import 'package:intl/intl.dart';

class RoastEdit extends StatefulWidget {

  final VoidCallback? onRoastEdited;
  final Roast roast;
  final f = DateFormat('MM-dd-yyyy');

  RoastEdit({Key? key, this.onRoastEdited, required this.roast}) : super(key: key);

  @override
  State<RoastEdit> createState() => _RoastEditState();
}

class _RoastEditState extends State<RoastEdit> {

  Future<void> saveUpdate(Roast newRoast) async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return await db.roastDao.updateRoast(widget.roast.id as int, newRoast.name, newRoast.roastLevel, newRoast.origin, newRoast.date);
  }

  Future<void> deleteRoast(Roast roast) async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    await db.roastDao.deleteRoast(roast);
    widget.onRoastEdited!();
  }

  // Controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController roastLevelController;
  late TextEditingController originController;
  late TextEditingController dateController;
  DateTime storedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.roast.name);
    roastLevelController = TextEditingController(text: widget.roast.roastLevel);
    originController = TextEditingController(text: widget.roast.origin);
    storedDate = DateTime.fromMillisecondsSinceEpoch(widget.roast.date);
    dateController = TextEditingController(text: widget.f.format(storedDate).toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text("New Roast Entry"),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Name",
                    icon: Icon(Icons.coffee),
                  ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                }
              ),
              TextFormField(
                controller: roastLevelController,
                decoration: const InputDecoration(
                  labelText: "Roast Level",
                  icon: Icon(Icons.local_fire_department),
                ),
                validator: (value) {
                  if(value == null || value.isEmpty)
                  {
                    return 'Please enter a roast level';
                  }
                  return null;
                }
              ),
              const Divider(),
              TextFormField(
                controller: dateController,
                readOnly: true, // Make the text field read-only
                decoration: const InputDecoration(
                  labelText: "Roast Date",
                  icon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // Show date picker and update text field value
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2900),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      storedDate = selectedDate;
                      dateController.text = widget.f.format(selectedDate).toString();
                    });
                  }
                },
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                }
              ),
              TextFormField(
                controller: originController,
                decoration: const InputDecoration(
                  labelText: "Origin",
                  icon: Icon(Icons.public)
                ),
                validator: (value) {
                  if(value == null || value.isEmpty)
                  {
                    return 'Please enter an origin.';
                  }
                  return null;
                }
              ),
              const Text(""),
              Text("Entry ID: ${widget.roast.id}")
            ] 
          ),
        )
      ),
      actions: [
        ElevatedButton(
          child: const Icon(Icons.delete),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Are you sure?"),
                content: Text("Are you sure you want to delete the '${widget.roast.name}' entry?"),
                actions: [
                  ElevatedButton(
                    child: const Text("Yes"),
                    onPressed: () {
                      deleteRoast(widget.roast);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.roast.name} successfully deleted.')));
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    }
                  ),
                  ElevatedButton(
                    child: const Text("No"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    }
                  ),
                ]
              ),
            );
          }
        ),
            //Navigator.of(context, rootNavigator: true).pop('dialog');
            //deleteRoast(widget.roast);
        ElevatedButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
          }
        ),
        ElevatedButton(
          child: const Text("Submit"),
          onPressed: () {
            if(_formKey.currentState!.validate()) {
              Roast newRoast = Roast(
                name: nameController.text,
                roastLevel: roastLevelController.text,
                origin: originController.text,
                date: storedDate.millisecondsSinceEpoch
              );
              // Push to database
              saveUpdate(newRoast).then((result) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Roast successfully updated!')));
                // notify parent widget
                widget.onRoastEdited!();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
              });
            }
          }
        )
      ]
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    roastLevelController.dispose();
    originController.dispose();
    dateController.dispose();
    super.dispose();
  }
}
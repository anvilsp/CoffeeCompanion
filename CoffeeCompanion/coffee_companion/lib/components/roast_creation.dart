import 'package:coffee_companion/app_database.dart';
import 'package:flutter/material.dart';
import 'package:coffee_companion/entity/roast.dart';
import 'package:intl/intl.dart';

class RoastCreation extends StatefulWidget {

  final VoidCallback? onRoastAdded;
  final f = DateFormat('MM-dd-yyyy');

  RoastCreation({Key? key, this.onRoastAdded}) : super(key: key);

  @override
  State<RoastCreation> createState() => _RoastCreationState();
}

class _RoastCreationState extends State<RoastCreation> {

  Future<List<int>> addRoast(Roast roast) async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return await db.roastDao.insertRoast([roast]);
  }

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roastLevelController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime storedDate = DateTime.now();

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
                controller: _nameController,
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
                controller: _roastLevelController,
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
                controller: _dateController,
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
                      _dateController.text = widget.f.format(storedDate).toString();
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
                controller: _originController,
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
            ] 
          ),
        )
      ),
      actions: [
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
                name: _nameController.text,
                roastLevel: _roastLevelController.text,
                origin: _originController.text,
                date: storedDate.millisecondsSinceEpoch
              );
              // Push to database
              addRoast(newRoast).then((result) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Roast successfully added!')));
                // notify parent widget
                widget.onRoastAdded!();
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
    _nameController.dispose();
    _roastLevelController.dispose();
    _originController.dispose();
    super.dispose();
  }
}
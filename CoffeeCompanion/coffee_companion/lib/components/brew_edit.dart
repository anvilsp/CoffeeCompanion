import 'package:coffee_companion/app_database.dart';
import 'package:flutter/material.dart';
import 'package:coffee_companion/entity/brew.dart';
import 'package:coffee_companion/entity/roast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrewEdit extends StatefulWidget {

  final VoidCallback? onBrewModified;
  final Brew brew;

  const BrewEdit({Key? key, this.onBrewModified, required this.brew}) : super(key: key);

  @override
  State<BrewEdit> createState() => _BrewEditState();
}

class _BrewEditState extends State<BrewEdit> {
  late SharedPreferences prefs;
  late List<Brew> roasts;
  late List<String> roastNames = [];
  late List<int> roastIds;
  int currentlySelected = -1;
  int selectedBrew = 0;
  int grinder = 0;
  bool brewExists = false;

  List<String> brewList = ["Espresso", "Pourover", "French Press", "Moka Pot", "AeroPress", "Chemex", "Other"];

  // Controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController grindController;
  late TextEditingController timeController;

  @override
  initState() {
    super.initState();
    getPreferences().then((result) {
      currentlySelected = widget.brew.roastId;
      selectedBrew = widget.brew.brewType;
      grindController = TextEditingController(text: widget.brew.grindSetting.toString());
      timeController = TextEditingController(text: widget.brew.time.toString());
    });
    validateBrewExists();
  }

  Future<Brew?> findBrewExists() async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final brew = await db.brewDao.findExactMatch(selectedBrew, currentlySelected);
    return brew;
  }

  Future<void> validateBrewExists() async {
    Brew? existingBrew = await findBrewExists();
    setState(() {
      brewExists = (existingBrew != null && existingBrew.id != widget.brew.id);
    });
  }

  Future<void> saveUpdate(Brew newBrew) async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return await db.brewDao.updateBrew(
      widget.brew.id!,
      newBrew.roastId,
      newBrew.brewType,
      newBrew.time,
      newBrew.grindSetting
    );
  }

  Future<void> deleteBrew(Brew brew) async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    await db.brewDao.deleteBrew(brew);
    widget.onBrewModified!();
  }

Future<void> getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    final int? loadGrinder = prefs.getInt('grinder');
    if(loadGrinder != null) {
      grinder = loadGrinder;
    }
    setState((){});
  }

  Future<List<int>> addBrew(Brew brew) async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return await db.brewDao.insertBrew([brew]);
  }

  Future<List<Roast>> fetchRoasts() async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final roasts = await db.roastDao.findAllRoasts();
    roastNames = roasts.map((roast) => roast.name).toList();
    roastIds = roasts.map((roast) => roast.id!).toSet().toList();
    return await db.roastDao.findAllRoasts();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchRoasts(),
      builder: (BuildContext context, AsyncSnapshot<List<Roast>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter some roast data first!')));
          });
          Navigator.of(context, rootNavigator: true).pop('dialog');
          return Container();
        } else {
          //validateBrewExists();
          if(currentlySelected == -1 || !roastIds.contains(currentlySelected)) {
            currentlySelected = roastIds[0];
          }
          return AlertDialog(
            scrollable: true,
            title: const Text("Edit Brew Entry"),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Roast"),
                      ]
                    ),
                    DropdownButtonFormField<int>(
                      value: currentlySelected != -1 ? currentlySelected : roastIds[0],
                      onChanged: (int? newValue) {
                        setState(() {
                          //print(newValue);
                          currentlySelected = newValue ?? 0;
                          validateBrewExists();
                        });
                      },
                      items: roastIds.map((int value) {
                        final index = roastIds.indexOf(value);
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(roastNames[index]),
                        );
                      }).toList(),
                      validator: (_) {
                        if(brewExists) {
                          return 'Brew/roast combo already exists.';
                        }
                      }
                    ),
                    const Text(" "),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Brew Method"),
                      ],
                    ),
                    DropdownButtonFormField<int>(
                      value: selectedBrew,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedBrew = newValue!;
                          validateBrewExists();
                        });
                      },
                      items: List.generate(
                        brewList.length,
                        (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(brewList[index])
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: grindController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Grind Level",
                        icon: Icon(Icons.snowing)
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty || double.tryParse(value) == null)
                        {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      }
                    ),
                    ElevatedButton(
                      child: const Text("Set to current grind"),
                      onPressed: () {
                        grindController.text = grinder.toString();
                      }
                    ),
                    TextFormField(
                      controller: timeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Brew Time (seconds)",
                        icon: Icon(Icons.timer)
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty || double.tryParse(value) == null)
                        {
                          return 'Please enter a valid number.';
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
                child: const Icon(Icons.delete),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Are you sure?"),
                      content: const Text("Are you sure you want to delete this entry?"),
                      actions: [
                        ElevatedButton(
                          child: const Text("Yes"),
                          onPressed: () {
                            deleteBrew(widget.brew).then((result) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry successfully deleted.')));
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                            });
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
                    Brew newBrew = Brew(
                      roastId: currentlySelected,
                      brewType: selectedBrew,
                      time: int.parse(timeController.text),
                      grindSetting: int.parse(grindController.text)
                    );
                    // put it in the database
                    saveUpdate(newBrew).then((result) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brew successfully updated!')));
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      // notify parent widget
                      widget.onBrewModified!();
                    });
                  }
                }
              )
            ]
          );
        }
      }
    );
  }
  /*
  @override
  void dispose() {
    _nameController.dispose();
    _roastLevelController.dispose();
    _originController.dispose();
    super.dispose();
  }
  */
}
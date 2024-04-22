import 'package:coffee_companion/app_database.dart';
import 'package:flutter/material.dart';
import 'package:coffee_companion/entity/roast.dart';
import 'package:coffee_companion/entity/brew.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrewCreation extends StatefulWidget {

  final VoidCallback? onRoastAdded;

  const BrewCreation({Key? key, this.onRoastAdded}) : super(key: key);

  @override
  State<BrewCreation> createState() => _BrewCreationState();
}

class _BrewCreationState extends State<BrewCreation> {
  late SharedPreferences prefs;
  late List<Roast> roasts;
  late List<String> roastNames;
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
  
  @override initState() {
    super.initState();
    getPreferences().then((result) {
      grindController = TextEditingController(text: grinder.toString());
      timeController = TextEditingController();
    });
    validateBrewExists();
  }

  Future<void> getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    final int? loadGrinder = prefs.getInt('grinder');
    if(loadGrinder != null) {
      grinder = loadGrinder;
    }
    setState((){});
  }

  Future<Brew?> findBrewExists() async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final brew = await db.brewDao.findExactMatch(selectedBrew, currentlySelected);
    return brew;
  }

  Future<void> validateBrewExists() async {
    Brew? existingBrew = await findBrewExists();
    setState(() {
      brewExists = (existingBrew != null);
    });
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
          if(currentlySelected == -1) {
            currentlySelected = roastIds[0];
            validateBrewExists();
          }
          return AlertDialog(
            scrollable: true,
            title: const Text("New Brew Entry"),
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
                    const Text(""),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Brew Method"),
                      ]
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
                    addBrew(newBrew).then((result) {
                      prefs.setInt('lastBrewType', selectedBrew);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brew successfully added!')));
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
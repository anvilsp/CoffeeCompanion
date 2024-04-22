import 'package:coffee_companion/app_database.dart';
import 'package:coffee_companion/entity/brew.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'nav_drawer.dart';
import 'navbar.dart';
import 'components/brew_creation.dart';
import 'components/brew_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBrewsPage extends StatefulWidget {
  const MyBrewsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyBrewsPage> createState() => _MyBrewsPageState();
}

class _MyBrewsPageState extends State<MyBrewsPage> {
  late int grind;

  @override
  void initState() {
    super.initState();
    getGrindSetting().then((result) {
      grind = result;
    });
    //retrieveBrews(0);
  }

  Future<int> getGrindSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? loadGrinder = prefs.getInt('grinder');
    return loadGrinder ?? 0;
  }

  Future<void> addTestRecord() async {
    Brew newBrew = Brew(roastId: 5, brewType: 0, time: 30, grindSetting: 0);
    await db.brewDao.insertBrew([newBrew]);
  }

  late AppDatabase db;
  bool ordering = true;

  Map<String, int> brewTypes = {
    "Espresso": 0,
    "Pourover": 1,
    "French Press": 2,
    "Moka Pot": 3,
    "AeroPress": 4,
    "Chemex": 5,
    "Other": 6,
    "All": 7
  };

  List<String> brewList = ["Espresso", "Pourover", "French Press", "Moka Pot", "AeroPress", "Chemex", "Other", "All"];

  String selectedValue = "Espresso";
  int currentSort = 0;

  Future<List<Brew>> retrieveBrews(int sorting) async {
    db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    if(currentSort != brewTypes["All"])
    {
      return await db.brewDao.findBrewByTypeIdOrderDesc(currentSort);
    }
    else
    {
      return await db.brewDao.findAllBrew();
    }
  }

  void reloadPage() {
    //print("page should reload");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const Navbar(),
      drawer: const NavDrawer(),
      body: Column(
        children: <Widget>[
          // header w/ dropdown menu
          Text('My Brews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35, color: Theme.of(context).colorScheme.primaryContainer)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  DropdownButton<String> (
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                        currentSort = brewTypes[selectedValue] ?? 0;
                      });
                    },
                    items: brewList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              /*ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Colors.black.withOpacity(0.0),
                  elevation: 0,
                ),
                onPressed: () {
                  setState((){
                    ordering = !ordering;
                  });
                },
                child: const Icon(Icons.sort)
              )*/ 
            ]
          ),
          const Text(''),
          // list of Brews from database
          Expanded(
            child: FutureBuilder(
              future: retrieveBrews(currentSort),
              builder: (BuildContext context, AsyncSnapshot<List<Brew>> snapshot) {
                if(snapshot.hasData) {
                  if(snapshot.data!.isEmpty) { return const Center(child: Text("No brews for this method yet! Press + to add one.")); }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, index) {
                      return Column(
                        children: <Widget> [
                          BrewEntry(
                            brew: snapshot.data![index],
                            onBrewModified: reloadPage,
                            userGrind: grind
                          ),
                          const Text(""),
                        ]
                      );
                    }
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => BrewCreation(
              onRoastAdded: reloadPage,
            )
          );
        },
        child: const Icon(Icons.add),
      )
    );
  }
}
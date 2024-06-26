import 'package:coffee_companion/app_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'nav_drawer.dart';
import 'navbar.dart';
import 'components/roast_entry.dart';
import 'components/roast_creation.dart';
import 'entity/roast.dart';

class MyRoastsPage extends StatefulWidget {
  const MyRoastsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyRoastsPage> createState() => _MyRoastsPageState();
}

class _MyRoastsPageState extends State<MyRoastsPage> {

  late AppDatabase db;
  bool ordering = true;
  String selectedValue = "Sort by date added";

  Future<List<Roast>> retrieveRoasts(String sorting) async {
    db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    switch(sorting) {
      case "Sort by date added":
        if(ordering) {
          return await db.roastDao.findAllRoastsDesc();
        }else{
          return await db.roastDao.findAllRoasts();
        }
      case "Sort by roast date":
        if(ordering) {
          return await db.roastDao.findAllRoastsDateDesc();
        }
        else
        {
          return await db.roastDao.findAllRoastsDate();
        }
    }
    return await db.roastDao.findAllRoastsDesc();
  }

  void reloadPage() {
    print("page should reload");
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
          Text('My Roasts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35, color: Theme.of(context).colorScheme.primaryContainer)),
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
                      });
                    },
                    items: <String>["Sort by date added", "Sort by roast date"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              ElevatedButton(
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
              ) 
            ]
          ),
          const Text(''),
          // list of roasts from database
          Expanded(
            child: FutureBuilder(
              future: retrieveRoasts(selectedValue),
              builder: (BuildContext context, AsyncSnapshot<List<Roast>> snapshot) {
                if(snapshot.hasData) {
                  if(snapshot.data!.isEmpty) { return const Center(child: Text("No roasts yet! Press + to add one.")); }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (BuildContext context, index) {
                      return Column(
                        children: <Widget> [
                          RoastEntry(roast:snapshot.data![index],
                          onRoastModified: reloadPage),
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
            builder: (context) => RoastCreation(
              onRoastAdded: reloadPage,
            ),
          );
        },
        child: const Icon(Icons.add),
      )
    );
  }
}
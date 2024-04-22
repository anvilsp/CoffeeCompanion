import 'package:flutter/material.dart';
import '../entity/brew.dart';
import 'package:coffee_companion/app_database.dart';
import 'package:coffee_companion/components/brew_edit.dart';

class BrewEntry extends StatefulWidget {
  // this component takes in a Brew object and displays its properties - allows the user to edit
  final Brew brew;
  final int userGrind;
  final VoidCallback? onBrewModified;


  const BrewEntry({super.key, this.onBrewModified, required this.brew, required this.userGrind});
  
  @override
  State<BrewEntry> createState() => _BrewEntryState();
}

class _BrewEntryState extends State<BrewEntry> {

  List<String> brewList = ["Espresso", "Pourover", "French Press", "Moka Pot", "AeroPress", "Chemex", "Other", "All"];

  void reloadModule() {
    widget.onBrewModified!();
    setState(() {});
  }

  Future<String> findRoastName() async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final roast = await db.roastDao.findRoastById(widget.brew.roastId);
    return roast?.name ?? 'Unknown';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder( // fetch the corresponding roast name before loading the container
      future: findRoastName(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if(snapshot.hasData) { // load the container if data is found
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
                        // display title
                        Text(snapshot.data ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.snowing),
                            Text("${widget.brew.grindSetting.toString()} (${(widget.brew.grindSetting - widget.userGrind) <= 0 ? '' : '+'}${(widget.brew.grindSetting - widget.userGrind)})"),
                            const Text("   "),
                            const Icon(Icons.timer),
                            Text(widget.brew.time.toString()),
                          ]
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.coffee_maker),
                            Text(brewList[widget.brew.brewType]),
                          ]
                        )
                      ]
                    ),
                ),
                Column( // edit button column
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    ElevatedButton( // edit button
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        backgroundColor: Colors.black.withOpacity(0.0),
                        elevation: 0,
                      ),
                      onPressed: () { // show edit dialogue
                        //print(widget.brew.id);
                        showDialog(
                          context: context,
                          builder: (context) => BrewEdit(
                            brew: widget.brew,
                            onBrewModified: reloadModule
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
        } else { // if the data isn't found then display a loading icon
          return const Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}
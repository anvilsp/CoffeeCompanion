import 'package:flutter/material.dart';
import 'package:coffee_companion/entity/brew.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrewInfo extends StatefulWidget {

  final VoidCallback? onRoastAdded;
  final Brew brew;

  const BrewInfo({Key? key, this.onRoastAdded, required this.brew}) : super(key: key);

  @override
  State<BrewInfo> createState() => _BrewInfoState();
}

class _BrewInfoState extends State<BrewInfo> {

  late SharedPreferences prefs;
  late int grindSetting;

  @override initState() {
    super.initState();
    getGrind();
  }

  Future<int> getGrind() async {
    prefs = await SharedPreferences.getInstance();
    final int? loadGrinder = prefs.getInt('grinder');
    if(loadGrinder != null) {
      grindSetting = loadGrinder;
    }
    return grindSetting;
  }

  Future<void> setGrind(int grind) async {
    await prefs.setInt('grinder', grind);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGrind(),
      builder: (context, AsyncSnapshot<int> snapshot) {
        if(snapshot.hasData) {
          return AlertDialog(
            scrollable: true,
            title: const Text("Brew Info"),
            content: Column(
              children: [
                Text("Grind setting: ${widget.brew.grindSetting}"),
                Text("Time: ${widget.brew.time}"),
                const Text(""),
                Text("Adjust the grinder's position ${(widget.brew.grindSetting - grindSetting).abs()} clicks ${(widget.brew.grindSetting - grindSetting <= 0) ? 'counter-clockwise' : 'clockwise'}."),
              ]
            ),
            actions: [
              ElevatedButton(
                child: const Text("Set Grinder"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                  showDialog (
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Are you sure?"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("This will update your saved grinder position. Please ensure that you've first adjusted your grinder so that you do not lose your position."),
                          const Text(""),
                          Text("Adjust the grinder's position ${(widget.brew.grindSetting - grindSetting).abs()} clicks ${(widget.brew.grindSetting - grindSetting <= 0) ? 'counter-clockwise' : 'clockwise'}."),
                        ]
                      ),
                      actions: [
                        ElevatedButton(
                          child: const Text("Confirm"),
                          onPressed: () {
                            setGrind(widget.brew.grindSetting).then((result) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grinder position updated.')));
                              Navigator.of(context, rootNavigator: true).pop('dialog');
                            });
                          }
                        ),
                        ElevatedButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop('dialog');
                          }
                        )
                      ]
                    )
                  );
                }
              ),
              ElevatedButton(
                child: const Text("Done"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }
              )
            ]
          );
        } else {
          return const Center(child: CircularProgressIndicator());
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
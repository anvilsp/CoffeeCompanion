import 'package:flutter/material.dart';
import 'nav_drawer.dart';
import 'navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyGrinderPage extends StatefulWidget {
  const MyGrinderPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyGrinderPage> createState() => _MyGrinderPageState();
}

class _MyGrinderPageState extends State<MyGrinderPage> {

  late SharedPreferences prefs;
  int grinder = 0;

  Future<void> getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    final int? loadGrinder = prefs.getInt('grinder');
    if(loadGrinder != null) {
      grinder = loadGrinder;
    }
    setState((){});
  }

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  Future<void> updateGrindSetting(int val) async {
    grinder += val;
    await prefs.setInt('grinder', grinder);
    setState((){});
  }

  Future<void> resetGrindSetting() async {
    grinder = 0;
    await prefs.setInt('grinder', grinder);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      drawer: const NavDrawer(),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('My Grinder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35, color: Theme.of(context).colorScheme.primaryContainer)),
            Column(
              children: [
                const Text('\n\n\n'),
                Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: 10.0 
                    ),
                  ),
                  child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(grinder <= 0 ? "$grinder" : "+$grinder",
                            style: const TextStyle(
                              fontSize: 75,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                            ),
                          ),
                        ]
                      ),
                  ),
                  const Text(''),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          minimumSize: const Size(100, 65),
                        ),
                        onPressed: () { 
                          updateGrindSetting(-1);
                        },
                        child: const Icon(Icons.remove, size: 45)
                      ),
                      const Text('   '),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          minimumSize: const Size(50, 65)
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Reset grinder?"),
                              content: Text("Current setting: $grinder"),
                              actions: [
                                ElevatedButton(
                                  child: const Text("Yes"),
                                  onPressed: () {
                                    resetGrindSetting();
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                  }
                                ),
                                ElevatedButton(
                                  child: const Text("No"),
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pop('dialog');
                                  }
                                )
                              ]
                            )

                          );
                        },
                        child: const Icon(Icons.refresh, size: 25)
                      ),
                      const Text('   '),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                          ),
                          minimumSize: const Size(100, 65),
                        ),
                        onPressed: () { 
                          updateGrindSetting(1);
                        },
                        child: const Icon(Icons.add, size: 45)
                      ),
                    ]
                  ),
              ]
            ),
            ]
          ),
        ),
        //floatingActionButton: FloatingActionButton(
        //  onPressed: _incrementCounter,
        //  tooltip: 'Increment',
        //  child: const Icon(Icons.add),
        //), // This trailing comma makes auto-formatting nicer for build methods.
      );
  }
}

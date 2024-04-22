import 'package:coffee_companion/components/brewInfo.dart';
import 'package:coffee_companion/nav_drawer.dart';
import "dart:async";
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:coffee_companion/app_database.dart';
import 'package:coffee_companion/entity/roast.dart';
import 'package:coffee_companion/entity/brew.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:floor/floor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoffeeCompanion',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        scaffoldBackgroundColor: ColorScheme.fromSeed(seedColor: Colors.brown).secondary,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Timer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  Stopwatch stopwatch = Stopwatch();
  late Timer _timer;
  static const List<String> defaultTimes = ["0", "00", "000"];
  List<String> formatTime = List.from(defaultTimes);
  Function eq = const ListEquality().equals;
  
  List<String> brewList = ["Espresso", "Pourover", "French Press", "Moka Pot", "AeroPress", "Chemex", "Other"];
  int selectedRoast = -1;
  int selectedBrew = 0;
  late List<int> brewIds;
  late List<int> roastIds;
  late Brew brew;
  List<String> roastNames = [];
  var enableInfo = false;
  int currTime = 30;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    if(stopwatch.isRunning) {
      setState(() {
        formatTime = getStopwatchText();
      });
    }
  }

  void resetTimerText() {
    formatTime = List.from(defaultTimes);
  }
  
  void toggleState() {
    if(stopwatch.isRunning) {
      stopwatch.stop();
    }
    else {
      stopwatch.start();
    }
  }

  List<String> getStopwatchText() {
    var mils = stopwatch.elapsedMilliseconds;
    String milliseconds = (mils % 1000).toString().padLeft(3, "0");
    String seconds = ((mils ~/ 1000) % 60).toString().padLeft(2, "0");
    String minutes = ((mils ~/ 1000) ~/ 60).toString().padLeft(1, "0");

    return [minutes, seconds, milliseconds];
  }

  Future<List<Brew>> findRoastsByBrew() async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    final brews = await db.brewDao.findBrewByTypeRoastOrderDesc(selectedBrew);
    brewIds = brews.map((brew) => brew.id!).toSet().toList();
    roastIds = brews.map((brew) => brew.roastId!).toSet().toList();
    roastNames = [];
    for(var brew in roastIds) {
      final roast = await db.roastDao.findRoastById(brew);
      roastNames.add(roast?.name ?? "Unknown");
    }
    return brews;
  }

  Future<void> getBrewInfo() async {
    AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    brew = (await db.brewDao.findById(selectedRoast))!;
    currTime = brew.time;
  }

  void handleBrewInfo() {
    if (enableInfo) {
      getBrewInfo().then((_) {
          showDialog(
            context: context,
            builder: (context) => BrewInfo(
              brew: brew,
            ),
          );
        });
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a brew and roast for more info!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      drawer: const NavDrawer(),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container( // timer container
              width: 300.0,
              height: 300.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 10.0
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Column( // timer content
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(formatTime.elementAt(0) == "0" ? formatTime.elementAt(1) : "${formatTime.elementAt(0)}:${formatTime.elementAt(1)}",
                        style: GoogleFonts.robotoMono(
                          textStyle: const TextStyle(
                            fontSize: 75,
                            fontWeight: FontWeight.w600,
                            color: Colors.white
                          )
                        )
                      ),
                      Text(".${formatTime.elementAt(2)}",
                        style: GoogleFonts.robotoMono(
                          textStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: (enableInfo ? ((stopwatch.elapsedMilliseconds/1000) > currTime ? Colors.red : Colors.white) : Colors.white)
                          )
                        )
                      ),
                    ]
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundColor: Colors.black.withOpacity(0.0),
                          disabledBackgroundColor: Colors.black.withOpacity(0.0),
                          elevation: 0
                        ),
                        onPressed: eq(formatTime, defaultTimes) ? null : () { 
                          setState(() {
                            stopwatch.stop();
                            stopwatch.reset();
                            resetTimerText();
                          });
                        },
                        child: !eq(formatTime, defaultTimes) ? const Icon(Icons.refresh) : null
                      ),
                      const Text("")
                    ]
                  )
                ]
              ),
            ),
              const Text(''),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  minimumSize: const Size(250, 85),
                ),
                onPressed: () {
                    setState(() {
                      toggleState();
                    });
                  },
                child: Icon(stopwatch.isRunning ? Icons.pause : Icons.play_arrow, size: 45)
              ),
              const Text(''),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  children: [
                    DropdownButtonFormField<int> (
                      value: selectedBrew,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedBrew = newValue!;
                          selectedRoast = -1;
                        });
                      },
                      items: List.generate(
                        brewList.length,
                        (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(brewList[index])
                        )
                      ),
                    ),
                    FutureBuilder(
                      future: findRoastsByBrew(),
                      builder: (BuildContext context, AsyncSnapshot<List<Brew>> snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          if(!stopwatch.isRunning) {
                            return const Center(child: CircularProgressIndicator());
                          }else{
                            return const Text("");
                          }
                        }
                        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          enableInfo = false;
                          return const Center(child: Text('No brews for this roast method!'));
                        }
                        else {
                          enableInfo = true;
                          if(selectedRoast == -1)
                          {
                            selectedRoast = brewIds[0];
                          }
                          return DropdownButtonFormField<int> (
                            value: selectedRoast,
                            onChanged: (int? newValue) {
                              //print(newValue);
                              setState(() {
                                selectedRoast = newValue!;
                                getBrewInfo();
                              });
                            },
                            items: List.generate(
                              snapshot.data!.length,
                              (index) => DropdownMenuItem<int> (
                                value: brewIds[index],
                                child: Text(roastNames[index])
                              )
                            )
                          );
                        }
                      }
                    ),
                  ]
                )
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Colors.black.withOpacity(0.0),
                  elevation: 0,
                ),
                onPressed: () {
                  handleBrewInfo();
                },
                child: const Icon(Icons.info),
              )
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

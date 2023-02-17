import 'dart:collection';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:mysecretary/business/business_ui.dart';
import 'package:mysecretary/class/class_ui.dart';
import 'package:mysecretary/configuration/configuration_ui.dart';
import 'package:mysecretary/debugger/debugger_ui.dart';
import 'package:mysecretary/gradienticon.dart';
import 'package:mysecretary/homescreen/homescreen_logic.dart';
import 'package:mysecretary/newtask/newtask_ui.dart';
import 'package:mysecretary/personal/personal_ui.dart';
import 'package:mysecretary/settings/settings.dart';
import 'package:mysecretary/tasksdetails/tasksdetails_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // variable to store the main color
  Color mainColor = const Color.fromARGB(255, 41, 143, 174);
  // variable to store the color for uncompleted task
  Color uncompletedTaskColor = Colors.transparent;
  // variable to store the color for completed tasks
  Color completedTaskColor = const Color.fromARGB(255, 41, 143, 174);

  // varaibles to store the main screen gradient colors
  Color color1 = Colors.purple;
  Color color2 = Colors.orange;

  // variable to store the username
  String userName = "";

  // variable to store the date for today
  String todayDate = "";

  /// this varibale is used to store the status of the initial value at index 0 (null or not null)
  String initialValueStatus = "";

  /// boolean variable to store the status of configuration
  bool isConfigured = false;

  // a list to define the dates of the month
  List dates = [];

  // variable to store the deleted tasks
  List<int> deletedTasks = [];

  // variables to hold different types of tasks
  HashMap<int, List<String>> tasksForDateTappedHashMap = HashMap();
  HashMap<int, List<String>> tasksHashMap = HashMap();
  HashMap<int, List<String>> todaysTasksHashMap = HashMap();

  /// function to get username
  /// achieved through shared preferences
  /// stored in the local storage
  void getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final userNameStorage = sharedPreferences.getString("Username");
    setState(() {
      userName = userNameStorage.toString();
    });
  }

  // function to display a toast message
  void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  /// function to show the predefine initial value snackbar if there is no initial value predefined (null)
  void checkStatusOfInitialValue_NewTask() {
    /// get the initial value status
    initialValueStatus = HomeScreenLogic().checkInitialValueStatus();

    /// if the initial status of the value is null execute this
    if (initialValueStatus == "null") {
      predefineInitialValueSnackbar();
    }

    /// if the initial status is not null execute this
    else {
      addNewTask();
    }
  }

  /// function to show the predefine initial value snackbar if there is no initial value predefined (null)
  void checkStatusOfInitialValue_Refresh() {
    /// get the initial value status
    initialValueStatus = HomeScreenLogic().checkInitialValueStatus();

    /// if the initial status of the value is null execute this
    if (initialValueStatus == "null") {
      predefineInitialValueSnackbar();
    }

    /// if the initial status is not null execute this
    else {
      setState(() {
        deletedTasks = HomeScreenLogic().loadedDeletedTasks();
        displayToast(deletedTasks.toString());
        tasksHashMap = HomeScreenLogic().readAllTasksData(deletedTasks);
        todaysTasksHashMap = HomeScreenLogic().readTodaysData();
      });
    }
  }

  /// this snackbar gets displayed when the initial index has not defined
  /// the user must first predefine the initial value before even loading the data
  /// it also gets displayed when the user tries to add a task without predefining the the initia  value
  /// gets displayed when any tasks requiring predefining of initial value attempts to be done without predefining the value
  void predefineInitialValueSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      margin: const EdgeInsets.only(right: 3, left: 3),
      duration: const Duration(days: 365),
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      elevation: 40,
      content: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 1,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Operation cannot be perfomed",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            const Text("Initialize the database first",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300)),
            const SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: ElevatedButton(
                  onPressed: () {
                    HomeScreenLogic().predefineKeyValue();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.grey,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                  child: const Text(
                    "INITIALIZE",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  )),
            )
          ],
        ),
      ),
    ));
  }

  /// function to show the snackbar
  /// the snackbar contains tasks specific for the pressed date
  void showSnackbBar(String dateClicked) {
    final snackBar = SnackBar(
      showCloseIcon: true,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.only(right: 3, left: 3),
      duration: const Duration(days: 365),
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      elevation: 40,
      content: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 1,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.07,
                width: MediaQuery.of(context).size.width * 1,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Center(
                  child: Text(
                    "Tasks for:  $dateClicked",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                )),
            Container(
              height: MediaQuery.of(context).size.height * 0.43,
              width: MediaQuery.of(context).size.width * 1,
              decoration: const BoxDecoration(color: Colors.transparent),
              child: ListView.builder(
                  itemCount: tasksForDateTappedHashMap.length,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () {
                        String name = tasksHashMap[index + 1]![0].toString();
                        String definition =
                            tasksHashMap[index + 1]![1].toString();
                        String start = tasksHashMap[index + 1]![2].toString();
                        String end = tasksHashMap[index + 1]![3].toString();
                        String group = tasksHashMap[index + 1]![4].toString();
                        String taskKey = tasksHashMap[index + 1]![5].toString();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TaskDetailsUI(name,
                                    definition, start, end, group, taskKey)));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: const EdgeInsets.only(top: 15),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.purple, Colors.orange]),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.04,
                              width: MediaQuery.of(context).size.width * 0.08,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: const Icon(
                                Icons.notifications_active,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.08,
                              width: MediaQuery.of(context).size.width * 0.35,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Center(
                                  child: Text(
                                    tasksForDateTappedHashMap[index + 1]![0]
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.03,
                              width: MediaQuery.of(context).size.width * 0.05,
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 7,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  })),
            ),
          ],
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // function to show the lower container
  Widget upperContainer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.width * 1,
      margin: const EdgeInsets.only(right: 1, left: 1),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.orange]),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          safeContainer(),
          firstContainer(),
          secondContainer(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          scrollingDates(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01)
        ],
      ),
    );
  }

  // Widget to show the upper container
  Widget lowerContainer(TabController tabController) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [thirdContainer(tabController), fourthContainer()],
      ),
    );
  }

  // function to display safe container
  Widget safeContainer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
    );
  }

  // function to display the first container
  Widget firstContainer() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 1,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: profile());
  }

  // function to display the first container
  Widget secondContainer() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 1,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Center(child: groupings()));
  }

  // function to display the third container
  Widget thirdContainer(TabController tabController) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.47,
      width: MediaQuery.of(context).size.width * 1,
      padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [todaysTasksTitle(tabController), todaysTasks(tabController)],
      ),
    );
  }

  // function to display the fourth container
  Widget fourthContainer() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width * 1,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: floatingButton());
  }

  // function to display the profile
  Widget profile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.08,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Text(
                    "Hello $userName",
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  )),
              Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Text(
                    todayDate,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 12),
                  )),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DebuggerUI()));
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage("assets/steve.jpg"), fit: BoxFit.fill),
            ),
          ),
        ),
      ],
    );
  }

  // function to display the add button
  Widget groupings() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.17,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.04,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: const Center(
              child: Text(
                "GROUPINGS",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Class()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple, Colors.orange]),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 1,
                            spreadRadius: 1)
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.25,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Image.asset("assets/class.png")),
                        const Text(
                          "Class",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Personal()));
                  }),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple, Colors.orange]),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 1,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.25,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Image.asset("assets/personal.png")),
                        const Text(
                          "Personal",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Business()));
                  }),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.purple, Colors.orange]),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 1,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.25,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Image.asset("assets/business.png")),
                        const Text(
                          "Business",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01)
        ],
      ),
    );
  }

  /// function to show scrolling dates
  Widget scrollingDates() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.08,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: ListView.builder(
              itemCount: dates.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: ((context, index) {
                return GestureDetector(
                  onTap: (() {
                    String date_clicked = HomeScreenLogic()
                        .buildScrollingDate(dates[index].toString());
                    displayToast(date_clicked);
                    tasksForDateTappedHashMap = HomeScreenLogic()
                        .readTasksForDayTapped(
                            date_clicked); // initialize tasks for date tapped
                    showSnackbBar(date_clicked);
                  }),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.13,
                    margin: const EdgeInsets.only(
                        right: 5, left: 5, top: 5, bottom: 5),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          "Date",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 13),
                        ),
                        Text(
                          dates[index].toString(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              })),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.08,
          width: MediaQuery.of(context).size.width * 0.1,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Settings()));
            },
            child: const Icon(
              Icons.settings,
              color: Colors.black,
              size: 30,
            ),
          ),
        )
      ],
    );
  }

  // function to display today's tasks
  Widget todaysTasksTitle(TabController tabController) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width * 0.6,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                controller: tabController,
                indicator: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    gradient: LinearGradient(colors: [
                      color1,
                      color2,
                    ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
                tabs: const [
                  Tab(
                    child: Text(
                      "ALL TASKS",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "TODAY",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ]),
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width * 0.15,
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: GestureDetector(
                onTap: () {
                  checkStatusOfInitialValue_Refresh();
                },
                child: Opacity(
                  opacity: 0.9,
                  child: GradientIcon(
                    Icons.refresh,
                    40,
                    const LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.orange,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  // function to display the today's tasks container
  Widget todaysTasks(TabController tabController) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.37,
      width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: TabBarView(
        controller: tabController,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: ListView.builder(
                itemCount: tasksHashMap.length,
                itemBuilder: ((context, index) {
                  return GestureDetector(
                    onTap: (() {
                      String name = tasksHashMap[index + 1]![0].toString();
                      String definition =
                          tasksHashMap[index + 1]![1].toString();
                      String start = tasksHashMap[index + 1]![2].toString();
                      String end = tasksHashMap[index + 1]![3].toString();
                      String group = tasksHashMap[index + 1]![4].toString();
                      String taskKey = tasksHashMap[index + 1]![5].toString();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaskDetailsUI(name,
                                  definition, start, end, group, taskKey)));
                    }),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin:
                          const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1, 1),
                              blurRadius: 1,
                              spreadRadius: 1)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.08,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: GradientIcon(
                              Icons.notifications_active,
                              20,
                              const LinearGradient(
                                colors: [
                                  Colors.purple,
                                  Colors.orange,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                tasksHashMap[index + 1]![0].toString(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.07,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.orange,
                              child: GestureDetector(
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.white,
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: Icon(Icons.star,
                                        color: uncompletedTaskColor, size: 13),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                })),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 1,
            decoration: const BoxDecoration(color: Colors.transparent),
            child: ListView.builder(
                itemCount: todaysTasksHashMap.length,
                itemBuilder: ((context, index) {
                  return GestureDetector(
                    onTap: (() {
                      String name =
                          todaysTasksHashMap[index + 1]![0].toString();
                      String definition =
                          todaysTasksHashMap[index + 1]![1].toString();
                      String start =
                          todaysTasksHashMap[index + 1]![2].toString();
                      String end = todaysTasksHashMap[index + 1]![3].toString();
                      String group = tasksHashMap[index + 1]![4].toString();
                      String taskKey = tasksHashMap[index + 1]![5].toString();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TaskDetailsUI(name,
                                  definition, start, end, group, taskKey)));
                    }),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin:
                          const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(1, 1),
                              blurRadius: 1,
                              spreadRadius: 1)
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.04,
                            width: MediaQuery.of(context).size.width * 0.08,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: GradientIcon(
                              Icons.notifications_active,
                              20,
                              const LinearGradient(
                                colors: [
                                  Colors.purple,
                                  Colors.orange,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.width * 0.5,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                todaysTasksHashMap[index + 1]![0].toString(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.width * 0.05,
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.orange,
                              child: CircleAvatar(
                                radius: 7,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                })),
          ),
        ],
      ),
    );
  }

  // function to display the add button
  Widget floatingButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width * 1,
      padding: const EdgeInsets.only(right: 30, left: 30),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Align(
        alignment: Alignment.center,
        child: GestureDetector(
            onTap: () {
              checkStatusOfInitialValue_NewTask();
            },
            child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      color1,
                      color2,
                    ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.white,
                  ),
                ))),
      ),
    );
  }

  // function to add new task
  void addNewTask() async {
    /// set the configuration status by reading the value stored locally
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isConfigured = sharedPreferences.getBool("isConfigured")!;
    });

    if (isConfigured == false) {
      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ConfigurationScreen()));
    } else {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const NewTask()));
    }
  }

  @override
  void initState() {
    /// initialize the username
    getUsername();

    /// initiliaze today's date
    todayDate = HomeScreenLogic().getTodaysDate();

    /// get the initial value status
    initialValueStatus = HomeScreenLogic().checkInitialValueStatus();

    /// load deleted tasks
    deletedTasks = HomeScreenLogic().loadedDeletedTasks();
    displayToast(deletedTasks.toString());

    /// initialize today's tasks hashmap
    todaysTasksHashMap = HomeScreenLogic().readTodaysData();

    /// initialize all the tasks hashmap
    tasksHashMap = HomeScreenLogic().readAllTasksData(deletedTasks);

    dates = HomeScreenLogic().generateScrollingDates();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height * 1,
      width: MediaQuery.of(context).size.width * 1,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          upperContainer(),
          lowerContainer(tabController),
        ],
      ),
    ));
  }
}

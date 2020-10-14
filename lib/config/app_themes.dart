import 'package:flutter/material.dart';

class ThemeItem {
  int id;
  String name, slug;
  ThemeData themeData;

  ThemeItem(this.id, this.name, this.slug, this.themeData);

  static List<ThemeItem> getThemeItems() {
    return <ThemeItem>[
      ThemeItem(
          1,
          'Dark Orange',
          'dark-orange',
          ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFFDC804F),
            secondaryHeaderColor: Colors.black,
            scaffoldBackgroundColor: Colors.grey[1000],
            splashColor: Colors.grey[1000],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            primaryTextTheme: TextTheme(
              headline6: TextStyle(color: Colors.black),
              bodyText1: TextStyle(color: Colors.black),
              bodyText2: TextStyle(color: Colors.black),
            ),
            appBarTheme: AppBarTheme(
              color: Colors.black45,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            ),
            cardTheme: CardTheme(color: Colors.black),
            cardColor: Colors.black45,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFDC804F),
            ),
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.black),
            bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.black45,
            ),
            tabBarTheme: TabBarTheme(
              unselectedLabelColor: Colors.grey[400],
              labelColor: Color(0xFFDC804F),
            ),
            indicatorColor: Color(0xFFDC804F),
          )),
      ThemeItem(
          2,
          'Dark Purple',
          'dark-purple',
          ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFF7C79A5),
            secondaryHeaderColor: Colors.black,
            scaffoldBackgroundColor: Colors.grey[1000],
            splashColor: Colors.grey[1000],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            primaryTextTheme: TextTheme(
              headline6: TextStyle(color: Colors.black),
              bodyText1: TextStyle(color: Colors.black),
              bodyText2: TextStyle(color: Colors.black),
            ),
            appBarTheme: AppBarTheme(
              color: Colors.black45,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            ),
            cardTheme: CardTheme(color: Colors.black),
            cardColor: Colors.black45,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF7C79A5),
            ),
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.black),
            bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.black45,
            ),
            tabBarTheme: TabBarTheme(
              unselectedLabelColor: Colors.grey[400],
              labelColor: Color(0xFF7C79A5),
            ),
            indicatorColor: Color(0xFF7C79A5),
          )),
      ThemeItem(
          3,
          'Light Purple',
          'light-purple',
          ThemeData(
            brightness: Brightness.light,
            primaryColor: Color(0xFF7C79A5),
            secondaryHeaderColor: Colors.black,
            scaffoldBackgroundColor: Colors.grey[200],
            splashColor: Colors.grey[200],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            primaryTextTheme: TextTheme(
              headline6: TextStyle(color: Colors.black),
              bodyText1: TextStyle(color: Colors.black),
              bodyText2: TextStyle(color: Colors.black),
            ),
            appBarTheme: AppBarTheme(
              color: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            ),
            cardTheme: CardTheme(color: Colors.white),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF7C79A5),
            ),
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.white),
            bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.white,
            ),
            tabBarTheme: TabBarTheme(
              unselectedLabelColor: Colors.black,
              labelColor: Color(0xFF7C79A5),
            ),
            indicatorColor: Color(0xFF7C79A5),
          )),
      ThemeItem(
          4,
          'Light Orange',
          'light-Orange',
          ThemeData(
            brightness: Brightness.light,
            primaryColor: Color(0xFFDC804F),
            secondaryHeaderColor: Colors.black,
            scaffoldBackgroundColor: Colors.grey[200],
            splashColor: Colors.grey[200],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            primaryTextTheme: TextTheme(
              headline6: TextStyle(color: Colors.black),
              bodyText1: TextStyle(color: Colors.black),
              bodyText2: TextStyle(color: Colors.black),
            ),
            appBarTheme: AppBarTheme(
              color: Colors.white,
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            ),
            cardTheme: CardTheme(color: Colors.white),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFDC804F),
            ),
            bottomSheetTheme:
                BottomSheetThemeData(backgroundColor: Colors.white),
            bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.white,
            ),
            tabBarTheme: TabBarTheme(
              unselectedLabelColor: Colors.black,
              labelColor: Color(0xFFDC804F),
            ),
            indicatorColor: Color(0xFFDC804F),
          )),
    ];
  }
}

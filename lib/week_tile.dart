import 'package:flutter/material.dart';
import 'package:menta_track/week_tile_data.dart';

//CustomTile fürs Display der Wochenpläne, beinhaltet Callbacks für Tap und Delete
//Kann in späteren Iterationen leicht angepasst werden

class WeekTile extends StatelessWidget {
  final VoidCallback onItemTap;
  final VoidCallback onDeleteTap;
  final WeekTileData item;

  const WeekTile({
    required this.item,
    required this.onItemTap,
    required this.onDeleteTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 10,
        child: Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.cyan, width: 6)),
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            minTileHeight: 72,
            leading: Icon(item.icon),
            title: Text(item.title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)), //w400 is normal, w700 is bold
            trailing: IconButton(onPressed: () {
              onDeleteTap();
            },
            icon: Icon(Icons.delete),),
            onTap: () {
              onItemTap();
            },
          ),
        ),
    );
  }
}

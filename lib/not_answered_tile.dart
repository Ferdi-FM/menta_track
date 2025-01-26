import 'package:flutter/material.dart';
import 'package:menta_track/not_answered_data.dart';

class NotAnsweredTile extends StatelessWidget {
  final VoidCallback onItemTap;
  final NotAnsweredData item;

  const NotAnsweredTile({
    required this.item,
    required this.onItemTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Theme.of(context).primaryColor, width: 6)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white60
            ),
            child: ListTile(
              onTap: (){
                print("tapping");
                onItemTap();
              },
              minTileHeight: 72,
              leading: Icon(item.icon),
              title: Text(
                item.title,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ),
          ),
        );
  }
}
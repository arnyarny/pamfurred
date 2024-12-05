import 'package:flutter/material.dart';
import 'package:pamfurred/components/empty_list_widget.dart';

Widget somethingWentWrong() {
  return emptyListWidget(Icons.error, 'Oops!', 'Something went wrong');
}

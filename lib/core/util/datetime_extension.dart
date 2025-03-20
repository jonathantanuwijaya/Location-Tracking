import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get formalDate =>
      "${DateFormat('EEEE').format(this)}, $day ${DateFormat('MMMM').format(this)} $year";

  DateTime get toDMYFormatted =>
      DateFormat('dd-MM-yyyy').parse(DateFormat('dd-MM-yyyy').format(this));
}

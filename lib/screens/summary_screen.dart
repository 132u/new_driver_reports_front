
import 'package:flutter/widgets.dart';

class SummaryScreen
    extends StatefulWidget {
  final String token;
  final String role;

  const SummaryScreen({
    super.key,
    required this.token,
    required this.role,
  });

  @override
  State<SummaryScreen>
      createState() =>
          _SummaryScreenState();
}

class _SummaryScreenState
    extends State<SummaryScreen> {
      @override
      Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
      }}
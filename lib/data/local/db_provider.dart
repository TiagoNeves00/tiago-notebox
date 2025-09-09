import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notebox/data/local/db.dart';

final dbProvider = Provider<AppDb>((_) => AppDb());

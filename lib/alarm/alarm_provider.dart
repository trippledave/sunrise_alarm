import 'package:flutter/widgets.dart';
import 'package:sunrise_alarm/alarm/alarm_bloc.dart';

/// This merely solves the "passing reference down the tree" problem for us.
/// You can solve this in other ways, like through dependency injection.
///
/// Also note that this does not call [CartBloc.dispose]. If your app
/// ever doesn't need to access the cart, you should make sure it's
/// disposed of properly.
class AlarmProvider extends InheritedWidget {
  final AlarmBloc alarmBloc;

  AlarmProvider({
    Key key,
    AlarmBloc alarmBloc,
    Widget child,
  })  : alarmBloc = alarmBloc ?? AlarmBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static AlarmBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(AlarmProvider) as AlarmProvider)
          .alarmBloc;
}
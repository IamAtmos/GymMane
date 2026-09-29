import 'package:flutter_test/flutter_test.dart';
import 'package:gymmane/models/workout.dart';
import 'package:gymmane/services/local_store.dart';
import 'package:gymmane/state/fit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.instance.init();
    fit.resetAllData();
    fit.setUnits('kg');
  });

  const bench = 'EIeI8Vf';

  LoggedSession logged(DateTime at, List<LoggedSet> sets, {String id = bench}) =>
      LoggedSession(at, 1800, [LoggedExercise(id, 'Barbell Bench Press', 'chest', sets)]);

  group('#138 una semana por columna', () {
    test('cada columna empieza el primer día de la semana y hoy cae en su fila', () {
      for (final start in [DateTime.monday, DateTime.sunday]) {
        fit.setWeekStart(start);
        final cells = fit.heatmapWeeks;
        expect(cells.length % 7, 0);
        expect(fit.heatmapWeekDate(0).weekday, start);
        final today = DateTime.now();
        final i = cells.length - 7 + fit.todayIndex;
        final d = fit.heatmapWeekDate(i);
        expect((d.year, d.month, d.day), (today.year, today.month, today.day));
        expect(cells.skip(i + 1).every((l) => l == -1), isTrue);
      }
    });

    test('un entreno de hoy se pinta en la casilla de hoy', () {
      fit.sessions.add(logged(DateTime.now(), [LoggedSet(8, 60)]));
      final cells = fit.heatmapWeeks;
      expect(cells[cells.length - 7 + fit.todayIndex], greaterThan(0));
    });

    test('los días y meses vienen encendidos y apagarlos se guarda', () {
      expect(fit.heatmapLabels, isTrue);
      fit.toggleHeatmapLabels();
      fit.persistNow();
      fit.loadFromStore();
      expect(fit.heatmapLabels, isFalse);
    });
  });
}

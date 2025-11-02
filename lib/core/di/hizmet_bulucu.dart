import 'package:get_it/get_it.dart';

typedef ModulKaydedici = void Function();

final GetIt hizmetBulucu = GetIt.instance;

bool _kurulumTamamlandi = false;

void kurHizmetBulucu({required List<ModulKaydedici> moduller}) {
  if (_kurulumTamamlandi) {
    return;
  }
  for (final ModulKaydedici kaydedici in moduller) {
    kaydedici();
  }
  _kurulumTamamlandi = true;
}

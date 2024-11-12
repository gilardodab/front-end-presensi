import 'package:presensi/data/repositories/cuti_repository.dart';
import 'package:presensi/data/models/cuti_model.dart';

class GetCuti {
  final CutiRepository repository;

  GetCuti(this.repository);

  Future<List<CutiModel>> execute() async {
    return await repository.getCutiData();
  }
}

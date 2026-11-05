import '../entities/detected_object.dart';
import '../repositories/detection_repository.dart';

class DetectObjects {
  const DetectObjects(this._repository);

  final DetectionRepository _repository;

  Future<Stream<List<DetectedObject>>> call() => _repository.startDetection();
}

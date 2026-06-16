enum InspectionType { before, after }

enum InspectionAngle { front, back, left, right, other }

class InspectionImageSlot {
  final InspectionType type;
  final InspectionAngle angle;
  final String? localPath;
  final String? remoteUrl;

  const InspectionImageSlot({
    required this.type,
    required this.angle,
    this.localPath,
    this.remoteUrl,
  });

  String get angleLabel {
    switch (angle) {
      case InspectionAngle.front:
        return 'Front';
      case InspectionAngle.back:
        return 'Back';
      case InspectionAngle.left:
        return 'Left';
      case InspectionAngle.right:
        return 'Right';
      case InspectionAngle.other:
        return 'Other';
    }
  }

  String get typeDb => type == InspectionType.before ? 'before' : 'after';

  String get angleDb {
    switch (angle) {
      case InspectionAngle.front:
        return 'front';
      case InspectionAngle.back:
        return 'back';
      case InspectionAngle.left:
        return 'left';
      case InspectionAngle.right:
        return 'right';
      case InspectionAngle.other:
        return 'other';
    }
  }
}

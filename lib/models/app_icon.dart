/// AR에서 사용할 아이콘 데이터 모델
class AppIcon {
  final String name;
  final String assetPath;
  final bool isDirtyMode;
  final String description;
  
  const AppIcon({
    required this.name,
    required this.assetPath,
    required this.isDirtyMode,
    required this.description,
  });
  
  /// 더러운 모드 아이콘 생성
  factory AppIcon.dirty(String name, String description) {
    return AppIcon(
      name: name,
      assetPath: 'assets/images/dirty-icons/$name.png',
      isDirtyMode: true,
      description: description,
    );
  }
  
  /// 깨끗한 모드 아이콘 생성
  factory AppIcon.clean(String name, String description) {
    return AppIcon(
      name: name,
      assetPath: 'assets/images/clean-icons/$name.png',
      isDirtyMode: false,
      description: description,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppIcon &&
        other.name == name &&
        other.isDirtyMode == isDirtyMode;
  }
  
  @override
  int get hashCode => name.hashCode ^ isDirtyMode.hashCode;
  
  @override
  String toString() {
    return 'AppIcon(name: $name, isDirtyMode: $isDirtyMode)';
  }
}
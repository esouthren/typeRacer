enum TextCategory {
  shakespeare,
  famousSpeeches,
  drSeuss,
  poetry,
  carnage;

  String get displayName {
    switch (this) {
      case TextCategory.shakespeare:
        return 'Shakespeare';
      case TextCategory.famousSpeeches:
        return 'Famous Speeches';
      case TextCategory.drSeuss:
        return 'Dr Seuss';
      case TextCategory.poetry:
        return 'Poetry';
      case TextCategory.carnage:
        return 'Carnage';
    }
  }
}

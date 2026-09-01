class ProStatus {
  const ProStatus({
    this.isPro = false,
    this.isLoading = false,
  });

  final bool isPro;
  final bool isLoading;

  ProStatus copyWith({
    bool? isPro,
    bool? isLoading,
  }) {
    return ProStatus(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() => {
        'isPro': isPro,
        'isLoading': isLoading,
      };

  factory ProStatus.fromJson(Map<String, dynamic> json) {
    return ProStatus(
      isPro: json['isPro'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }
}

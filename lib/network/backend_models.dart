enum PhotoUploadState {
  pending,
  uploading,
  uploaded,
  failed,
}

class SessionPhotoItem {
  final String localPath;
  final bool isSelected;
  final PhotoUploadState uploadState;
  final String? backendPhotoId;
  final String? errorMessage;

  const SessionPhotoItem({
    required this.localPath,
    this.isSelected = true,
    this.uploadState = PhotoUploadState.pending,
    this.backendPhotoId,
    this.errorMessage,
  });

  SessionPhotoItem copyWith({
    String? localPath,
    bool? isSelected,
    PhotoUploadState? uploadState,
    String? backendPhotoId,
    String? errorMessage,
  }) {
    return SessionPhotoItem(
      localPath: localPath ?? this.localPath,
      isSelected: isSelected ?? this.isSelected,
      uploadState: uploadState ?? this.uploadState,
      backendPhotoId: backendPhotoId ?? this.backendPhotoId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localPath': localPath,
      'isSelected': isSelected,
      'uploadState': uploadState.name,
      'backendPhotoId': backendPhotoId,
      'errorMessage': errorMessage,
    };
  }

  factory SessionPhotoItem.fromJson(Map<String, dynamic> json) {
    return SessionPhotoItem(
      localPath: json['localPath'] as String,
      isSelected: json['isSelected'] as bool? ?? true,
      uploadState: PhotoUploadState.values.firstWhere(
        (e) => e.name == json['uploadState'],
        orElse: () => PhotoUploadState.pending,
      ),
      backendPhotoId: json['backendPhotoId'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  String toString() {
    return 'SessionPhotoItem(localPath: $localPath, isSelected: $isSelected, uploadState: $uploadState, backendPhotoId: $backendPhotoId, errorMessage: $errorMessage)';
  }
}

enum ShareSessionStatus {
  idle,
  uploadingPhotos,
  creatingDownloadSession,
  ready,
  failed,
}

class ShareSessionState {
  final ShareSessionStatus status;
  final int uploadedCount;
  final int totalCount;
  final String? downloadToken;
  final String? downloadUrl;
  final DateTime? expiresAt;
  final String? errorMessage;

  const ShareSessionState({
    this.status = ShareSessionStatus.idle,
    this.uploadedCount = 0,
    this.totalCount = 0,
    this.downloadToken,
    this.downloadUrl,
    this.expiresAt,
    this.errorMessage,
  });

  ShareSessionState copyWith({
    ShareSessionStatus? status,
    int? uploadedCount,
    int? totalCount,
    String? downloadToken,
    String? downloadUrl,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    return ShareSessionState(
      status: status ?? this.status,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      totalCount: totalCount ?? this.totalCount,
      downloadToken: downloadToken ?? this.downloadToken,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'uploadedCount': uploadedCount,
      'totalCount': totalCount,
      'downloadToken': downloadToken,
      'downloadUrl': downloadUrl,
      'expiresAt': expiresAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory ShareSessionState.fromJson(Map<String, dynamic> json) {
    return ShareSessionState(
      status: ShareSessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShareSessionStatus.idle,
      ),
      uploadedCount: (json['uploadedCount'] as int?) ?? (json['uploaded_count'] as int?) ?? 0,
      totalCount: (json['totalCount'] as int?) ?? (json['total_count'] as int?) ?? 0,
      downloadToken: (json['token'] as String?) ?? (json['download_token'] as String?) ?? (json['downloadToken'] as String?),
      downloadUrl: (json['download_url'] as String?) ?? (json['downloadUrl'] as String?),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : json['expires_at'] != null
              ? DateTime.tryParse(json['expires_at'] as String)
              : null,
      errorMessage: (json['errorMessage'] as String?) ?? (json['error_message'] as String?),
    );
  }

  @override
  String toString() {
    return 'ShareSessionState(status: $status, uploadedCount: $uploadedCount, totalCount: $totalCount, downloadToken: $downloadToken, downloadUrl: $downloadUrl, expiresAt: $expiresAt, errorMessage: $errorMessage)';
  }
}

class StickerItem {
  final String id;
  final String name;

  const StickerItem({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory StickerItem.fromJson(Map<String, dynamic> json) {
    return StickerItem(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? json['id'].toString(),
    );
  }

  @override
  String toString() {
    return 'StickerItem(id: $id, name: $name)';
  }
}


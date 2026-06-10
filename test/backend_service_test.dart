import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nexthouse_instant/network/backend_config.dart';
import 'package:nexthouse_instant/network/backend_models.dart';
import 'package:nexthouse_instant/network/backend_service.dart';

void main() {
  group('BackendConfig Tests', () {
    test('getUri should correctly combine base URL and paths', () {
      const config = BackendConfig(baseUrl: 'http://192.168.33.124:8080');

      expect(
        config.getUri('/api/sessions/upload').toString(),
        'http://192.168.33.124:8080/api/sessions/upload',
      );

      // Testing without leading slash
      expect(
        config.getUri('api/sessions/upload').toString(),
        'http://192.168.33.124:8080/api/sessions/upload',
      );

      // Testing query parameters
      expect(
        config.getUri('/api/sessions/download', {'expires': '10'}).toString(),
        'http://192.168.33.124:8080/api/sessions/download?expires=10',
      );
    });
  });

  group('SessionPhotoItem Model Tests', () {
    test('SessionPhotoItem serialization & copyWith', () {
      const item = SessionPhotoItem(
        localPath: '/path/to/photo.jpg',
        isSelected: true,
        uploadState: PhotoUploadState.pending,
      );

      expect(item.localPath, '/path/to/photo.jpg');
      expect(item.isSelected, true);
      expect(item.uploadState, PhotoUploadState.pending);
      expect(item.backendPhotoId, isNull);
      expect(item.errorMessage, isNull);

      final updated = item.copyWith(
        uploadState: PhotoUploadState.uploaded,
        backendPhotoId: 'photo_123',
      );

      expect(updated.localPath, '/path/to/photo.jpg');
      expect(updated.isSelected, true);
      expect(updated.uploadState, PhotoUploadState.uploaded);
      expect(updated.backendPhotoId, 'photo_123');

      final json = updated.toJson();
      expect(json['uploadState'], 'uploaded');
      expect(json['backendPhotoId'], 'photo_123');

      final fromJson = SessionPhotoItem.fromJson(json);
      expect(fromJson.localPath, '/path/to/photo.jpg');
      expect(fromJson.uploadState, PhotoUploadState.uploaded);
      expect(fromJson.backendPhotoId, 'photo_123');
    });
  });

  group('ShareSessionState Model Tests', () {
    test('ShareSessionState serialization & copyWith', () {
      final now = DateTime.now();
      final state = ShareSessionState(
        status: ShareSessionStatus.ready,
        uploadedCount: 3,
        totalCount: 3,
        downloadToken: 'token_abc',
        downloadUrl: 'http://test.com/download',
        expiresAt: now,
      );

      expect(state.status, ShareSessionStatus.ready);
      expect(state.uploadedCount, 3);
      expect(state.downloadToken, 'token_abc');
      expect(state.expiresAt, now);

      final updated = state.copyWith(
        status: ShareSessionStatus.failed,
        errorMessage: 'Connection lost',
      );

      expect(updated.status, ShareSessionStatus.failed);
      expect(updated.errorMessage, 'Connection lost');
      expect(updated.downloadToken, 'token_abc'); // preserved

      final json = updated.toJson();
      expect(json['status'], 'failed');
      expect(json['errorMessage'], 'connection lost'.toUpperCase() == 'CONNECTION LOST' ? 'Connection lost' : '');

      final fromJson = ShareSessionState.fromJson(json);
      expect(fromJson.status, ShareSessionStatus.failed);
      expect(fromJson.errorMessage, 'Connection lost');
      expect(fromJson.uploadedCount, 3);
    });
  });

  group('BackendService HTTP Tests with MockClient', () {
    test('testHealth returns true when response is successful', () async {
      final mockClient = MockClient((request) async {
        return http.Response('OK', 200);
      });

      final service = BackendService(
        config: const BackendConfig(baseUrl: 'http://localhost:8080'),
        client: mockClient,
      );

      final healthy = await service.testHealth();
      expect(healthy, isTrue);
    });

    test('testHealth returns false when network throws exception', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection failed');
      });

      final service = BackendService(
        config: const BackendConfig(baseUrl: 'http://localhost:8080'),
        client: mockClient,
      );

      final healthy = await service.testHealth();
      expect(healthy, isFalse);
    });

    test('createDownloadSession parses response correctly when status is 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/download-sessions');
        
        final Map<String, dynamic> responsePayload = {
          'status': 'ready',
          'uploaded_count': 2,
          'total_count': 2,
          'token': 'token_xyz',
          'download_url': 'http://localhost:8080/api/download-sessions/token_xyz/zip',
          'expires_at': '2026-06-08T15:00:00.000Z',
          'error_message': null,
        };
        return http.Response(jsonEncode(responsePayload), 200);
      });

      final service = BackendService(
        config: const BackendConfig(baseUrl: 'http://localhost:8080'),
        client: mockClient,
      );

      final result = await service.createDownloadSession([1, 2]);
      expect(result.status, ShareSessionStatus.ready);
      expect(result.downloadToken, 'token_xyz');
      expect(result.uploadedCount, 2);
      expect(result.downloadUrl, 'http://localhost:8080/api/download-sessions/token_xyz/zip');
    });

    test('createDownloadSession returns fallback mock when status is 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = BackendService(
        config: const BackendConfig(baseUrl: 'http://localhost:8080'),
        client: mockClient,
      );

      final result = await service.createDownloadSession([1, 2, 3], expiresInMinutes: 15);
      expect(result.status, ShareSessionStatus.ready);
      expect(result.uploadedCount, 3);
      expect(result.totalCount, 3);
      expect(result.downloadToken, startsWith('mock_token_'));
      expect(result.downloadUrl, contains('mock_session/download'));
      expect(result.errorMessage, contains('404'));
    });

    test('uploadPhotos sends multiple files using multipart and returns response', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file1 = File('${tempDir.path}/test1.jpg')..writeAsStringSync('dummy content 1');
      final file2 = File('${tempDir.path}/test2.jpg')..writeAsStringSync('dummy content 2');

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/photos/upload');
        expect(request.headers['content-type'], contains('multipart/form-data'));
        expect(request.headers['X-Upload-Key'], 'nh_upload_9f3a9e22db83ec4a689cf91283d73bfe5a6f8b9d');
        
        final responsePayload = {
          'session_id': 'abc_session',
          'share_url': 'http://localhost:8080/share/abc_session',
          'code': 'abc_session',
          'files': ['photo_1.jpg', 'photo_2.jpg']
        };
        return http.Response(jsonEncode(responsePayload), 200);
      });

      final service = BackendService(
        config: const BackendConfig(baseUrl: 'http://localhost:8080'),
        client: mockClient,
      );

      final response = await service.uploadPhotos([file1, file2]);
      expect(response['session_id'], 'abc_session');
      expect(response['share_url'], 'http://localhost:8080/share/abc_session');
      expect(response['files'], contains('photo_1.jpg'));

      tempDir.deleteSync(recursive: true);
    });

    test('uploadPhoto sends a single file using multipart key "file" and returns response', () async {
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/test.jpg')..writeAsStringSync('dummy content');

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/photos/upload');
        expect(request.headers['content-type'], contains('multipart/form-data'));
        expect(request.headers['X-Upload-Key'], 'nh_upload_9f3a9e22db83ec4a689cf91283d73bfe5a6f8b9d');
        
        final responsePayload = {
          'id': '123',
          'session_id': 'abc_session',
          'share_url': 'http://localhost:8080/share/abc_session',
          'code': 'abc_session',
          'files': ['photo_1.jpg']
        };
        return http.Response(jsonEncode(responsePayload), 200);
      });

      final service = BackendService(
        config: const BackendConfig(baseUrl: 'http://localhost:8080'),
        client: mockClient,
      );

      final response = await service.uploadPhoto(file);
      expect(response['id'], '123');
      expect(response['share_url'], 'http://localhost:8080/share/abc_session');

      tempDir.deleteSync(recursive: true);
    });
  });
}

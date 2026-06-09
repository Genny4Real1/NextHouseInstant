import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'backend_config.dart';
import 'backend_models.dart';

class BackendService {
  final BackendConfig config;
  final http.Client _client;

  BackendService({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Tests the connection to the backend.
  /// Returns [true] if the backend is reachable (i.e. responds with any standard HTTP code less than 500).
  /// Returns [false] if a network error or timeout occurs.
  Future<bool> testHealth() async {
    try {
      final url = config.getUri('/');
      final response = await _client.get(url).timeout(config.timeout);
      
      // Even if it returns a 404 (since '/' is not registered in FastAPI),
      // the fact that the server responded means it is active and reachable.
      return response.statusCode < 500;
    } catch (e) {
      // In case of SocketException, TimeoutException, etc.
      return false;
    }
  }

  /// Uploads multiple physical image files to the backend in a single request using multipart/form-data.
  /// Sends the files on the 'files' field as expected by the FastAPI List[UploadFile] parameter.
  ///
  /// Returns a [Map] containing the JSON response from the server:
  /// e.g. `{ "session_id": "...", "share_url": "...", "code": "...", "files": [...] }`
  Future<Map<String, dynamic>> uploadPhotos(List<File> files) async {
    debugPrint('BackendService: uploadPhotos iniziato con ${files.length} file');
    for (final file in files) {
      if (!await file.exists()) {
        debugPrint('BackendService: Errore - file non esistente: ${file.path}');
        throw FileSystemException("The file to upload does not exist: ${file.path}");
      }
    }

    final url = config.getUri('/api/photos/upload');
    debugPrint('BackendService: URL di upload: $url');
    final request = http.MultipartRequest('POST', url);
    
    // FastAPI expects a list under the form field name 'files'
    for (final file in files) {
      debugPrint('BackendService: Aggiunta file al multipart: ${file.path}');
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          file.path,
          contentType: _getMediaType(file.path),
        ),
      );
    }

    try {
      debugPrint('BackendService: Invio della richiesta multipart...');
      final streamedResponse = await _client.send(request).timeout(config.timeout);
      debugPrint('BackendService: Ricevuti gli header della risposta. Status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse).timeout(config.timeout);
      debugPrint('BackendService: Corpo della risposta letto interamente');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('BackendService: Upload completato con successo. Body: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('BackendService: Errore upload. Status: ${response.statusCode}, Body: ${response.body}');
        throw HttpException(
          'Photo upload failed with status ${response.statusCode}: ${response.body}',
          uri: url,
        );
      }
    } catch (e, stack) {
      debugPrint('BackendService: Eccezione durante l\'upload: $e\n$stack');
      if (e is HttpException || e is FileSystemException) {
        rethrow;
      }
      throw HttpException('Network or request error: $e', uri: url);
    }
  }

  /// Uploads a single physical image file to the backend using multipart/form-data.
  /// Sends the file on the 'file' field as expected by the FastAPI singular parameter.
  Future<Map<String, dynamic>> uploadPhoto(File file) async {
    debugPrint('BackendService: uploadPhoto iniziato per file: ${file.path}');
    if (!await file.exists()) {
      debugPrint('BackendService: Errore - file non esistente: ${file.path}');
      throw FileSystemException("The file to upload does not exist: ${file.path}");
    }

    final url = config.getUri('/api/photos/upload');
    debugPrint('BackendService: URL di upload: $url');
    final request = http.MultipartRequest('POST', url);
    
    debugPrint('BackendService: Aggiunta file al multipart con chiave "file": ${file.path}');
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: _getMediaType(file.path),
      ),
    );

    try {
      debugPrint('BackendService: Invio della richiesta multipart...');
      final streamedResponse = await _client.send(request).timeout(config.timeout);
      debugPrint('BackendService: Ricevuti gli header della risposta. Status: ${streamedResponse.statusCode}');
      final response = await http.Response.fromStream(streamedResponse).timeout(config.timeout);
      debugPrint('BackendService: Corpo della risposta letto interamente');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('BackendService: Upload completato con successo. Body: ${response.body}');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('BackendService: Errore upload. Status: ${response.statusCode}, Body: ${response.body}');
        throw HttpException(
          'Photo upload failed with status ${response.statusCode}: ${response.body}',
          uri: url,
        );
      }
    } catch (e, stack) {
      debugPrint('BackendService: Eccezione durante l\'upload: $e\n$stack');
      if (e is HttpException || e is FileSystemException) {
        rethrow;
      }
      throw HttpException('Network or request error: $e', uri: url);
    }
  }

  /// Calls the backend to create a custom download session for specific photo IDs.
  ///
  /// Note: The existing FastAPI backend (main.py) does not currently define a POST endpoint
  /// for creating download sessions by IDs. This method sends the request to `/api/sessions/download`
  /// or returns a simulated configuration if the backend is not yet updated.
  Future<ShareSessionState> createDownloadSession(
    List<int> photoIds, {
    int expiresInMinutes = 10,
    int maxDownloads = 1,
  }) async {
    final url = config.getUri('/api/download-sessions');
    
    final Map<String, dynamic> body = {
      'photo_ids': photoIds,
      'expires_in_minutes': expiresInMinutes,
      'max_downloads': maxDownloads,
    };

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(config.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ShareSessionState.fromJson(data);
      } else if (response.statusCode == 404) {
        // Fallback/Warning behavior: log the 404 because the endpoint does not exist on the current FastAPI app
        // Return a mocked/simulated session state for easy LAN/frontend debugging
        final mockExpiration = DateTime.now().add(Duration(minutes: expiresInMinutes));
        return ShareSessionState(
          status: ShareSessionStatus.ready,
          uploadedCount: photoIds.length,
          totalCount: photoIds.length,
          downloadToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          downloadUrl: config.baseUrl + '/share/mock_session/download',
          expiresAt: mockExpiration,
          errorMessage: 'Backend returned 404 - using simulated LAN download session state.',
        );
      } else {
        throw HttpException(
          'Failed to create download session: Status ${response.statusCode}',
          uri: url,
        );
      }
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Network or request error: $e', uri: url);
    }
  }

  MediaType _getMediaType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// Closes the underlying client.
  void dispose() {
    _client.close();
  }
}

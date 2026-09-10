import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleDriveService {
  static const _scopes = [drive.DriveApi.driveFileScope];
  static const _credentialsKey = 'google_drive_credentials';

  static const String _defaultFolderId = '1I9nkwCKp9JNPgBS9cyF3JfwR34RYZPEl';

  Future<String?> uploadFile(
    File file,
    String fileName, {
    String? driveFolderId,
  }) async {
    try {
      final client = await _getAuthClient();
      final driveApi = drive.DriveApi(client);

      String extension = '';
      final pathParts = file.path.split('.');
      if (pathParts.length > 1) {
        extension = pathParts.last;
      }

      String finalName = fileName;
      if (extension.isNotEmpty &&
          !fileName.toLowerCase().endsWith('.$extension')) {
        finalName = '$fileName.$extension';
      }

      final driveFile = drive.File();
      driveFile.name = finalName;

      final mimeType = lookupMimeType(finalName) ?? 'text/plain';
      driveFile.mimeType = mimeType;

      if (driveFolderId != null && driveFolderId.isNotEmpty) {
        driveFile.parents = [driveFolderId];
      } else {
        driveFile.parents = [_defaultFolderId];
      }

      final length = await file.length();
      final media = drive.Media(file.openRead(), length);

      final response = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
        $fields: 'id, webViewLink',
      );

      if (response.id != null) {
        final permission = drive.Permission()
          ..type = 'anyone'
          ..role = 'reader';
        await driveApi.permissions.create(permission, response.id!);
      }

      return response.webViewLink;
    } catch (e) {
      print('Drive upload error: $e');
      rethrow;
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      final client = await _getAuthClient();
      final driveApi = drive.DriveApi(client);
      await driveApi.files.delete(fileId);
    } catch (e) {
      print('Drive delete error: $e');
      rethrow;
    }
  }

  Future<AuthClient> _getAuthClient() async {
    final credentialsString = await rootBundle.loadString(
      'assets/client_secret.json',
    );
    final json = jsonDecode(credentialsString);
    final installed = json['installed'] ?? json['web'];
    final clientId = ClientId(
      installed['client_id'],
      installed['client_secret'],
    );

    final prefs = await SharedPreferences.getInstance();
    final savedCreds = prefs.getString(_credentialsKey);

    if (savedCreds != null) {
      try {
        final credsJson = jsonDecode(savedCreds);
        final credentials = AccessCredentials.fromJson(credsJson);
        return autoRefreshingClient(clientId, credentials, http.Client());
      } catch (e) {
        // Fallthrough if parsing fails
      }
    }

    final credentials = await _authenticateWithLoopback(clientId, _scopes);

    await prefs.setString(_credentialsKey, jsonEncode(credentials.toJson()));

    return autoRefreshingClient(clientId, credentials, http.Client());
  }

  Future<AccessCredentials> _authenticateWithLoopback(
    ClientId clientId,
    List<String> scopes,
  ) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final redirectUri = 'http://localhost:${server.port}';

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId.identifier,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'prompt': 'consent',
    });

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl);
    } else {
      server.close(force: true);
      throw Exception('Could not launch browser for authentication.');
    }

    final request = await server.first;
    final code = request.uri.queryParameters['code'];

    if (code == null) {
      request.response
        ..statusCode = 400
        ..write('Authentication failed. No code found.');
      await request.response.close();
      await server.close(force: true);
      throw Exception('Authentication failed.');
    }

    request.response
      ..statusCode = 200
      ..headers.set('Content-Type', 'text/html; charset=utf-8')
      ..write(
        '<html><body><h1>Authentication successful!</h1><p>You can close this tab and return to the app.</p></body></html>',
      );
    await request.response.close();
    await server.close(force: true);

    // Exchange code for token
    final tokenResponse = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      body: {
        'client_id': clientId.identifier,
        'client_secret': clientId.secret,
        'code': code,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Failed to exchange code: ${tokenResponse.body}');
    }

    final tokenJson = jsonDecode(tokenResponse.body);
    return AccessCredentials(
      AccessToken(
        'Bearer',
        tokenJson['access_token'],
        DateTime.now().toUtc().add(Duration(seconds: tokenJson['expires_in'])),
      ),
      tokenJson['refresh_token'],
      scopes,
    );
  }
}

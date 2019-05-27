library appium_dart;

import 'dart:collection';

import 'package:webdriver/src/common/request_client.dart';
import 'package:webdriver/src/common/utils.dart';
import 'package:webdriver/src/common/session.dart';
import 'package:webdriver/src/request/sync_http_request_client.dart';

import 'package:webdriver/sync_core.dart';


class AppiumDart extends WebDriver {
  AppiumDart(Uri uri, String id, Map<String, dynamic> capabilities, SyncRequestClient client, WebDriverSpec spec) : super(uri, id, capabilities, client, spec);
}


AppiumDart createDriver(
    {Uri uri,
      Map<String, dynamic> desired,
      WebDriverSpec spec = WebDriverSpec.Auto}) =>
    createDriverCore((prefix) => SyncHttpRequestClient(prefix),
        uri: uri, desired: desired, spec: spec);

AppiumDart fromExistingSession(String sessionId,
    {Uri uri,
      WebDriverSpec spec = WebDriverSpec.Auto,
      Map<String, dynamic> capabilities}) =>
    fromExistingSessionCore(
        sessionId, (prefix) => SyncHttpRequestClient(prefix),
        uri: uri, spec: spec, capabilities: capabilities);


final Uri defaultUri = Uri.parse('http://127.0.0.1:4444/wd/hub/');

/// Creates a new sync WebDriver.
///
/// This is intended for internal use! Please use [createDriver] from
/// sync_io.dart.
AppiumDart createDriverCore(
    SyncRequestClient Function(Uri prefix) createRequestClient,
    {Uri uri,
      Map<String, dynamic> desired,
      WebDriverSpec spec = WebDriverSpec.Auto}) {
  uri ??= defaultUri;

  // This client's prefix at root, it has no session prefix in it.
  final client = createRequestClient(uri);

  final handler = getHandler(spec);

  var w3cCapabilities = [
    'browserName',
    'browserVersion',
    'platformName',
    'acceptInsecureCerts',
    'pageLoadStrategy',
    'proxy',
    'setWindowRect',
    'timeouts',
    'unhandledPromptBehavior',
    'strictFileInteractability'
  ];

  final desiredCapabilities = new Map<String, dynamic>();
  desired.forEach((k, v) {
    if(w3cCapabilities.contains(k) && k.contains(':')) {
      desiredCapabilities.addAll({k: v});
    } else {
      desiredCapabilities.addAll({'appium:$k': v});
    }
  });

  final session = client.send(
      handler.session.buildCreateRequest(desired: desiredCapabilities),
      handler.session.parseCreateResponse);

  if (session.spec != WebDriverSpec.JsonWire &&
      session.spec != WebDriverSpec.W3c) {
    throw 'Unexpected spec: ${session.spec}';
  }

  return AppiumDart(uri, session.id, UnmodifiableMapView(session.capabilities),
      createRequestClient(uri.resolve('session/${session.id}/')), session.spec);
}

/// Creates a sync WebDriver from existing session.
///
/// This is intended for internal use! Please use [fromExistingSession] from
/// sync_io.dart.
AppiumDart fromExistingSessionCore(String sessionId,
    SyncRequestClient Function(Uri prefix) createRequestClient,
    {Uri uri,
      WebDriverSpec spec = WebDriverSpec.Auto,
      Map<String, dynamic> capabilities}) {
  uri ??= defaultUri;

  var session = SessionInfo(sessionId, spec, capabilities);

  // Update session info if not all is provided.
  if (spec == WebDriverSpec.Auto || capabilities == null) {
    // This client's prefix at root, it has no session prefix in it.
    final client = createRequestClient(uri);

    final handler = getHandler(spec);

    session = client.send(handler.session.buildInfoRequest(sessionId),
        handler.session.parseInfoResponse);
  }

  if (session.spec != WebDriverSpec.JsonWire &&
      session.spec != WebDriverSpec.W3c) {
    throw 'Unexpected spec: ${session.spec}';
  }

  return AppiumDart(uri, session.id, UnmodifiableMapView(session.capabilities),
      createRequestClient(uri.resolve('session/${session.id}/')), session.spec);
}

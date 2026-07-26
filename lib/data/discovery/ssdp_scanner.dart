import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SsdpResponse {
  final String ipAddress;
  final int port;
  final String location;
  final String server;
  final String usn;
  final String st;
  final Map<String, String> headers;

  const SsdpResponse({
    required this.ipAddress,
    required this.port,
    required this.location,
    required this.server,
    required this.usn,
    required this.st,
    required this.headers,
  });

  @override
  String toString() =>
      'SsdpResponse(IP: $ipAddress, Location: $location, Server: $server, USN: $usn)';
}

class SsdpScanner {
  static const String multicastAddress = '239.255.255.250';
  static const int multicastPort = 1900;

  static const List<String> searchTargets = [
    'ssdp:all',
    'upnp:rootdevice',
    'urn:dial-multiscreen-org:service:dial:1',
  ];

  static Map<String, String> parseHeaders(String rawResponse) {
    final headers = <String, String>{};
    final lines = LineSplitter.split(rawResponse);
    for (final line in lines) {
      final parts = line.split(':');
      if (parts.length >= 2) {
        final key = parts[0].trim().toUpperCase();
        final value = parts.sublist(1).join(':').trim();
        headers[key] = value;
      }
    }
    return headers;
  }

  Stream<SsdpResponse> scan({Duration timeout = const Duration(seconds: 4)}) async* {
    RawDatagramSocket? socket;
    try {
      socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      socket.multicastHops = 4;

      final targetAddr = InternetAddress(multicastAddress);

      for (final st in searchTargets) {
        final request =
            'M-SEARCH * HTTP/1.1\r\n'
            'HOST: $multicastAddress:$multicastPort\r\n'
            'MAN: "ssdp:discover"\r\n'
            'MX: 3\r\n'
            'ST: $st\r\n'
            'USER-AGENT: Unimote/1.0 UPnP/1.1\r\n'
            '\r\n';

        final bytes = utf8.encode(request);
        socket.send(bytes, targetAddr, multicastPort);
      }

      final controller = StreamController<SsdpResponse>();

      final subscription = socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket?.receive();
          if (datagram != null) {
            try {
              final raw = utf8.decode(datagram.data);
              final headers = parseHeaders(raw);

              final location = headers['LOCATION'] ?? '';
              final server = headers['SERVER'] ?? '';
              final usn = headers['USN'] ?? '';
              final st = headers['ST'] ?? headers['NT'] ?? '';

              final response = SsdpResponse(
                ipAddress: datagram.address.address,
                port: datagram.port,
                location: location,
                server: server,
                usn: usn,
                st: st,
                headers: headers,
              );
              controller.add(response);
            } catch (_) {
              // Ignore malformed UDP datagrams gracefully
            }
          }
        }
      });

      // Stream responses until timeout
      final stopWatch = Stopwatch()..start();
      while (stopWatch.elapsed < timeout) {
        await Future.delayed(const Duration(milliseconds: 100));
        // Flush available stream events
      }

      await subscription.cancel();
      await controller.close();

      yield* controller.stream;
    } catch (_) {
      // Return empty stream if network socket binding fails
    } finally {
      socket?.close();
    }
  }
}

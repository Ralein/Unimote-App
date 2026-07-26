import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';

class MdnsResponse {
  final String serviceName;
  final String hostName;
  final String ipAddress;
  final int port;
  final Map<String, String> txtRecords;

  const MdnsResponse({
    required this.serviceName,
    required this.hostName,
    required this.ipAddress,
    required this.port,
    required this.txtRecords,
  });

  @override
  String toString() =>
      'MdnsResponse(Service: $serviceName, Host: $hostName, IP: $ipAddress:$port, TXT: $txtRecords)';
}

class MdnsScanner {
  static const List<String> targetServices = [
    '_googlecast._tcp.local',
    '_roku-ecp._tcp.local',
    '_airplay._tcp.local',
    '_ssap._tcp.local',
    '_http._tcp.local',
  ];

  Stream<MdnsResponse> scan({Duration timeout = const Duration(seconds: 4)}) async* {
    MDnsClient? client;
    try {
      client = MDnsClient();
      await client.start();

      for (final serviceType in targetServices) {
        await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer(serviceType),
        ).timeout(timeout, onTimeout: (sink) => sink.close())) {
          final String domainName = ptr.domainName;

          await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(domainName),
          ).timeout(const Duration(seconds: 1), onTimeout: (sink) => sink.close())) {
            final String target = srv.target;
            final int port = srv.port;

            final txtRecords = <String, String>{};
            try {
              await for (final TxtResourceRecord txt in client.lookup<TxtResourceRecord>(
                ResourceRecordQuery.text(domainName),
              ).timeout(const Duration(milliseconds: 500), onTimeout: (sink) => sink.close())) {
                final lines = txt.text.split('\n');
                for (final line in lines) {
                  final parts = line.split('=');
                  if (parts.length >= 2) {
                    txtRecords[parts[0].trim()] = parts.sublist(1).join('=').trim();
                  }
                }
              }
            } catch (_) {}

            await for (final IPAddressResourceRecord ip in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(target),
            ).timeout(const Duration(seconds: 1), onTimeout: (sink) => sink.close())) {
              yield MdnsResponse(
                serviceName: serviceType,
                hostName: target,
                ipAddress: ip.address.address,
                port: port,
                txtRecords: txtRecords,
              );
            }
          }
        }
      }
    } catch (_) {
      // Gracefully handle socket/network exceptions
    } finally {
      client?.stop();
    }
  }
}

enum DeviceBrand {
  samsung,
  lg,
  roku,
  fireTv,
  androidTv,
  vizio,
  sony,
  genericIr,
  mock,
}

class Device {
  final String id;
  final String name;
  final DeviceBrand brand;
  final String ipAddress;
  final String? macAddress;
  final int port;
  final String? pairedToken;

  const Device({
    required this.id,
    required this.name,
    required this.brand,
    required this.ipAddress,
    this.macAddress,
    required this.port,
    this.pairedToken,
  });

  Device copyWith({
    String? id,
    String? name,
    DeviceBrand? brand,
    String? ipAddress,
    String? macAddress,
    int? port,
    String? pairedToken,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      port: port ?? this.port,
      pairedToken: pairedToken ?? this.pairedToken,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ipAddress == other.ipAddress;

  @override
  int get hashCode => id.hashCode ^ ipAddress.hashCode;
}

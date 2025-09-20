class UserModel {
  final int id;
  final String role;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String status;
  final String? latitude;
  final String? longitude;
  final String walletBalance;
  final String? vehicleType;
  final String? licenseNumber;
  final String? lastSeenAt;
  final String? fcmToken;
  final String? emailVerifiedAt;
  final String region;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.status,
    this.latitude,
    this.longitude,
    required this.walletBalance,
    this.vehicleType,
    this.licenseNumber,
    this.lastSeenAt,
    this.fcmToken,
    this.emailVerifiedAt,
    required this.region,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    role: json['role'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    avatar: json['avatar'] as String?,
    status: json['status'] as String,
    latitude: json['latitude']?.toString(),
    longitude: json['longitude']?.toString(),
    walletBalance: json['wallet_balance']?.toString() ?? '0.00',
    vehicleType: json['vehicle_type'] as String?,
    licenseNumber: json['license_number'] as String?,
    lastSeenAt: json['last_seen_at'] as String?,
    fcmToken: json['fcm_token'] as String?,
    emailVerifiedAt: json['email_verified_at'] as String?,
    region: json['region'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

class DataItem {
  final int id;
  final String pelapor;
  final String kendala;
  final int kategoriId;
  final String tingkat;
  final int lokasiId;
  final String status;
  final String? keterangan;
  final String? solusi;
  final int userId;
  final String? userName;
  final String createdAt;
  final String updatedAt;
  final String createdAtFormated;
  final Lokasi? lokasi; // Make Lokasi nullable
  final Kategori? kategori; // Make Kategori nullable
  final User user;

  DataItem({
    required this.id,
    required this.pelapor,
    required this.kendala,
    required this.kategoriId,
    required this.tingkat,
    required this.lokasiId,
    required this.status,
    this.keterangan,
    this.solusi,
    required this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
    required this.createdAtFormated,
    this.lokasi, // Allow null
    this.kategori, // Allow null
    required this.user,
  });

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      id: json['id'],
      pelapor: json['pelapor'],
      kendala: json['kendala'],
      kategoriId: json['kategori_id'],
      tingkat: json['tingkat'],
      lokasiId: json['lokasi_id'],
      status: json['status'],
      keterangan: json['keterangan'],
      solusi: json['solusi'],
      userId: json['user_id'],
      userName: json['user_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdAtFormated: json['created_at_formatted'],
      lokasi: json['lokasi'] != null ? Lokasi.fromJson(json['lokasi']) : null,
      kategori: json['kategori'] != null ? Kategori.fromJson(json['kategori']) : null,
      user: User.fromJson(json['user']),
    );
  }
}

class Lokasi {
  final int id;
  final String locationName;
  final int userId;
  final int floorId;
  final String createdAt;
  final String updatedAt;

  Lokasi({
    required this.id,
    required this.locationName,
    required this.userId,
    required this.floorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lokasi.fromJson(Map<String, dynamic> json) {
    return Lokasi(
      id: json['id'],
      locationName: json['locationname'],
      userId: json['user_id'],
      floorId: json['floor_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Kategori {
  final int id;
  final String categoryName;
  final int userId;
  final String hashtag;
  final String createdAt;
  final String updatedAt;

  Kategori({
    required this.id,
    required this.categoryName,
    required this.userId,
    required this.hashtag,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      categoryName: json['categoryname'],
      userId: json['user_id'],
      hashtag: json['hashtag'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

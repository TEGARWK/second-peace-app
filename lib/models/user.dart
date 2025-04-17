class Address {
  final int id;
  final String nama;
  final String telepon;
  final String alamat;
  final String kota;
  final String kodePos;
  final bool isPrimary;

  Address({
    required this.id,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.kota,
    required this.kodePos,
    this.isPrimary = false,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      nama: map['nama'] ?? '',
      telepon: map['telepon'] ?? '',
      alamat: map['alamat'] ?? '',
      kota: map['kota'] ?? '',
      kodePos: map['kodePos'] ?? '',
      isPrimary: map['utama'] ?? false, // Laravel pakai `utama`
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'telepon': telepon,
      'alamat': alamat,
      'kota': kota,
      'kodePos': kodePos,
      'utama': isPrimary,
    };
  }
}

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
      id: map['id'] ?? 0,
      nama: map['nama'] ?? '',
      telepon: map['no_whatsapp'] ?? '', // Sesuai dengan Laravel
      alamat: map['alamat'] ?? '',
      kota: map['kota'] ?? '',
      kodePos: map['kode_pos'] ?? '',
      isPrimary: map['utama'] ?? false, // Laravel menggunakan `utama` (boolean)
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_whatsapp': telepon,
      'alamat': alamat,
      'kota': kota,
      'kode_pos': kodePos,
      'utama': isPrimary,
    };
  }
}

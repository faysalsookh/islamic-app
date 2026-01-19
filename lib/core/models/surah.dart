/// Model representing a Surah (chapter) of the Quran
class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final String nameBengali; // Bengali name
  final int ayahCount;
  final String revelationType; // 'Meccan' or 'Medinan'
  final String revelationTypeBengali; // মক্কী or মাদানী
  final int juzStart;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    this.nameBengali = '',
    required this.ayahCount,
    required this.revelationType,
    this.revelationTypeBengali = '',
    required this.juzStart,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: json['name_arabic'] as String,
      nameEnglish: json['name_english'] as String,
      nameTransliteration: json['name_transliteration'] as String,
      nameBengali: json['name_bengali'] as String? ?? '',
      ayahCount: json['ayah_count'] as int,
      revelationType: json['revelation_type'] as String,
      revelationTypeBengali: json['revelation_type_bengali'] as String? ?? '',
      juzStart: json['juz_start'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'name_transliteration': nameTransliteration,
      'name_bengali': nameBengali,
      'ayah_count': ayahCount,
      'revelation_type': revelationType,
      'revelation_type_bengali': revelationTypeBengali,
      'juz_start': juzStart,
    };
  }
}

/// Complete data for all 114 Surahs of the Quran
class SurahData {
  static const List<Surah> surahs = [
    Surah(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'The Opening', nameTransliteration: 'Al-Fatihah', nameBengali: 'আল-ফাতিহা', ayahCount: 7, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 1),
    Surah(number: 2, nameArabic: 'البقرة', nameEnglish: 'The Cow', nameTransliteration: 'Al-Baqarah', nameBengali: 'আল-বাকারা', ayahCount: 286, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 1),
    Surah(number: 3, nameArabic: 'آل عمران', nameEnglish: 'The Family of Imran', nameTransliteration: "Ali 'Imran", nameBengali: 'আলে ইমরান', ayahCount: 200, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 3),
    Surah(number: 4, nameArabic: 'النساء', nameEnglish: 'The Women', nameTransliteration: 'An-Nisa', nameBengali: 'আন-নিসা', ayahCount: 176, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 4),
    Surah(number: 5, nameArabic: 'المائدة', nameEnglish: 'The Table Spread', nameTransliteration: "Al-Ma'idah", nameBengali: 'আল-মায়িদাহ', ayahCount: 120, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 6),
    Surah(number: 6, nameArabic: 'الأنعام', nameEnglish: 'The Cattle', nameTransliteration: "Al-An'am", nameBengali: 'আল-আনআম', ayahCount: 165, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 7),
    Surah(number: 7, nameArabic: 'الأعراف', nameEnglish: 'The Heights', nameTransliteration: "Al-A'raf", nameBengali: 'আল-আরাফ', ayahCount: 206, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 8),
    Surah(number: 8, nameArabic: 'الأنفال', nameEnglish: 'The Spoils of War', nameTransliteration: 'Al-Anfal', nameBengali: 'আল-আনফাল', ayahCount: 75, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 9),
    Surah(number: 9, nameArabic: 'التوبة', nameEnglish: 'The Repentance', nameTransliteration: 'At-Tawbah', nameBengali: 'আত-তওবা', ayahCount: 129, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 10),
    Surah(number: 10, nameArabic: 'يونس', nameEnglish: 'Jonah', nameTransliteration: 'Yunus', nameBengali: 'ইউনুস', ayahCount: 109, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 11),
    Surah(number: 11, nameArabic: 'هود', nameEnglish: 'Hud', nameTransliteration: 'Hud', nameBengali: 'হুদ', ayahCount: 123, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 11),
    Surah(number: 12, nameArabic: 'يوسف', nameEnglish: 'Joseph', nameTransliteration: 'Yusuf', nameBengali: 'ইউসুফ', ayahCount: 111, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 12),
    Surah(number: 13, nameArabic: 'الرعد', nameEnglish: 'The Thunder', nameTransliteration: "Ar-Ra'd", nameBengali: 'আর-রাদ', ayahCount: 43, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 13),
    Surah(number: 14, nameArabic: 'إبراهيم', nameEnglish: 'Abraham', nameTransliteration: 'Ibrahim', nameBengali: 'ইবরাহীম', ayahCount: 52, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 13),
    Surah(number: 15, nameArabic: 'الحجر', nameEnglish: 'The Rocky Tract', nameTransliteration: 'Al-Hijr', nameBengali: 'আল-হিজর', ayahCount: 99, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 14),
    Surah(number: 16, nameArabic: 'النحل', nameEnglish: 'The Bee', nameTransliteration: 'An-Nahl', nameBengali: 'আন-নাহল', ayahCount: 128, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 14),
    Surah(number: 17, nameArabic: 'الإسراء', nameEnglish: 'The Night Journey', nameTransliteration: "Al-Isra'", nameBengali: 'আল-ইসরা', ayahCount: 111, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 15),
    Surah(number: 18, nameArabic: 'الكهف', nameEnglish: 'The Cave', nameTransliteration: 'Al-Kahf', nameBengali: 'আল-কাহফ', ayahCount: 110, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 15),
    Surah(number: 19, nameArabic: 'مريم', nameEnglish: 'Mary', nameTransliteration: 'Maryam', nameBengali: 'মারইয়াম', ayahCount: 98, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 16),
    Surah(number: 20, nameArabic: 'طه', nameEnglish: 'Ta-Ha', nameTransliteration: 'Ta-Ha', nameBengali: 'তা-হা', ayahCount: 135, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 16),
    Surah(number: 21, nameArabic: 'الأنبياء', nameEnglish: 'The Prophets', nameTransliteration: "Al-Anbiya'", nameBengali: 'আল-আম্বিয়া', ayahCount: 112, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 17),
    Surah(number: 22, nameArabic: 'الحج', nameEnglish: 'The Pilgrimage', nameTransliteration: 'Al-Hajj', nameBengali: 'আল-হজ্জ', ayahCount: 78, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 17),
    Surah(number: 23, nameArabic: 'المؤمنون', nameEnglish: 'The Believers', nameTransliteration: "Al-Mu'minun", nameBengali: 'আল-মুমিনুন', ayahCount: 118, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 18),
    Surah(number: 24, nameArabic: 'النور', nameEnglish: 'The Light', nameTransliteration: 'An-Nur', nameBengali: 'আন-নূর', ayahCount: 64, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 18),
    Surah(number: 25, nameArabic: 'الفرقان', nameEnglish: 'The Criterion', nameTransliteration: 'Al-Furqan', nameBengali: 'আল-ফুরকান', ayahCount: 77, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 18),
    Surah(number: 26, nameArabic: 'الشعراء', nameEnglish: 'The Poets', nameTransliteration: "Ash-Shu'ara'", nameBengali: 'আশ-শুআরা', ayahCount: 227, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 19),
    Surah(number: 27, nameArabic: 'النمل', nameEnglish: 'The Ant', nameTransliteration: 'An-Naml', nameBengali: 'আন-নামল', ayahCount: 93, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 19),
    Surah(number: 28, nameArabic: 'القصص', nameEnglish: 'The Stories', nameTransliteration: 'Al-Qasas', nameBengali: 'আল-কাসাস', ayahCount: 88, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 20),
    Surah(number: 29, nameArabic: 'العنكبوت', nameEnglish: 'The Spider', nameTransliteration: "Al-'Ankabut", nameBengali: 'আল-আনকাবুত', ayahCount: 69, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 20),
    Surah(number: 30, nameArabic: 'الروم', nameEnglish: 'The Romans', nameTransliteration: 'Ar-Rum', nameBengali: 'আর-রূম', ayahCount: 60, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 21),
    Surah(number: 31, nameArabic: 'لقمان', nameEnglish: 'Luqman', nameTransliteration: 'Luqman', nameBengali: 'লুকমান', ayahCount: 34, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 21),
    Surah(number: 32, nameArabic: 'السجدة', nameEnglish: 'The Prostration', nameTransliteration: 'As-Sajdah', nameBengali: 'আস-সাজদাহ', ayahCount: 30, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 21),
    Surah(number: 33, nameArabic: 'الأحزاب', nameEnglish: 'The Combined Forces', nameTransliteration: 'Al-Ahzab', nameBengali: 'আল-আহযাব', ayahCount: 73, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 21),
    Surah(number: 34, nameArabic: 'سبأ', nameEnglish: 'Sheba', nameTransliteration: "Saba'", nameBengali: 'সাবা', ayahCount: 54, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 22),
    Surah(number: 35, nameArabic: 'فاطر', nameEnglish: 'Originator', nameTransliteration: 'Fatir', nameBengali: 'ফাতির', ayahCount: 45, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 22),
    Surah(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', nameTransliteration: 'Ya-Sin', nameBengali: 'ইয়াসীন', ayahCount: 83, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 22),
    Surah(number: 37, nameArabic: 'الصافات', nameEnglish: 'Those Who Set The Ranks', nameTransliteration: 'As-Saffat', nameBengali: 'আস-সাফফাত', ayahCount: 182, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 23),
    Surah(number: 38, nameArabic: 'ص', nameEnglish: 'Sad', nameTransliteration: 'Sad', nameBengali: 'সাদ', ayahCount: 88, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 23),
    Surah(number: 39, nameArabic: 'الزمر', nameEnglish: 'The Troops', nameTransliteration: 'Az-Zumar', nameBengali: 'আয-যুমার', ayahCount: 75, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 23),
    Surah(number: 40, nameArabic: 'غافر', nameEnglish: 'The Forgiver', nameTransliteration: 'Ghafir', nameBengali: 'গাফির', ayahCount: 85, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 24),
    Surah(number: 41, nameArabic: 'فصلت', nameEnglish: 'Explained In Detail', nameTransliteration: 'Fussilat', nameBengali: 'ফুসসিলাত', ayahCount: 54, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 24),
    Surah(number: 42, nameArabic: 'الشورى', nameEnglish: 'The Consultation', nameTransliteration: 'Ash-Shura', nameBengali: 'আশ-শূরা', ayahCount: 53, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 25),
    Surah(number: 43, nameArabic: 'الزخرف', nameEnglish: 'The Ornaments Of Gold', nameTransliteration: 'Az-Zukhruf', nameBengali: 'আয-যুখরুফ', ayahCount: 89, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 25),
    Surah(number: 44, nameArabic: 'الدخان', nameEnglish: 'The Smoke', nameTransliteration: 'Ad-Dukhan', nameBengali: 'আদ-দুখান', ayahCount: 59, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 25),
    Surah(number: 45, nameArabic: 'الجاثية', nameEnglish: 'The Crouching', nameTransliteration: 'Al-Jathiyah', nameBengali: 'আল-জাসিয়া', ayahCount: 37, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 25),
    Surah(number: 46, nameArabic: 'الأحقاف', nameEnglish: 'The Wind-Curved Sandhills', nameTransliteration: 'Al-Ahqaf', nameBengali: 'আল-আহকাফ', ayahCount: 35, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 26),
    Surah(number: 47, nameArabic: 'محمد', nameEnglish: 'Muhammad', nameTransliteration: 'Muhammad', nameBengali: 'মুহাম্মাদ', ayahCount: 38, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 26),
    Surah(number: 48, nameArabic: 'الفتح', nameEnglish: 'The Victory', nameTransliteration: 'Al-Fath', nameBengali: 'আল-ফাতহ', ayahCount: 29, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 26),
    Surah(number: 49, nameArabic: 'الحجرات', nameEnglish: 'The Rooms', nameTransliteration: 'Al-Hujurat', nameBengali: 'আল-হুজুরাত', ayahCount: 18, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 26),
    Surah(number: 50, nameArabic: 'ق', nameEnglish: 'Qaf', nameTransliteration: 'Qaf', nameBengali: 'কাফ', ayahCount: 45, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 26),
    Surah(number: 51, nameArabic: 'الذاريات', nameEnglish: 'The Winnowing Winds', nameTransliteration: 'Adh-Dhariyat', nameBengali: 'আয-যারিয়াত', ayahCount: 60, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 26),
    Surah(number: 52, nameArabic: 'الطور', nameEnglish: 'The Mount', nameTransliteration: 'At-Tur', nameBengali: 'আত-তূর', ayahCount: 49, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 27),
    Surah(number: 53, nameArabic: 'النجم', nameEnglish: 'The Star', nameTransliteration: 'An-Najm', nameBengali: 'আন-নাজম', ayahCount: 62, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 27),
    Surah(number: 54, nameArabic: 'القمر', nameEnglish: 'The Moon', nameTransliteration: 'Al-Qamar', nameBengali: 'আল-কামার', ayahCount: 55, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 27),
    Surah(number: 55, nameArabic: 'الرحمن', nameEnglish: 'The Most Merciful', nameTransliteration: 'Ar-Rahman', nameBengali: 'আর-রাহমান', ayahCount: 78, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 27),
    Surah(number: 56, nameArabic: 'الواقعة', nameEnglish: 'The Inevitable', nameTransliteration: "Al-Waqi'ah", nameBengali: 'আল-ওয়াকিয়া', ayahCount: 96, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 27),
    Surah(number: 57, nameArabic: 'الحديد', nameEnglish: 'The Iron', nameTransliteration: 'Al-Hadid', nameBengali: 'আল-হাদীদ', ayahCount: 29, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 27),
    Surah(number: 58, nameArabic: 'المجادلة', nameEnglish: 'The Pleading Woman', nameTransliteration: 'Al-Mujadilah', nameBengali: 'আল-মুজাদালা', ayahCount: 22, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 59, nameArabic: 'الحشر', nameEnglish: 'The Exile', nameTransliteration: 'Al-Hashr', nameBengali: 'আল-হাশর', ayahCount: 24, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 60, nameArabic: 'الممتحنة', nameEnglish: 'She That Is To Be Examined', nameTransliteration: 'Al-Mumtahanah', nameBengali: 'আল-মুমতাহিনা', ayahCount: 13, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 61, nameArabic: 'الصف', nameEnglish: 'The Ranks', nameTransliteration: 'As-Saff', nameBengali: 'আস-সফ', ayahCount: 14, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 62, nameArabic: 'الجمعة', nameEnglish: 'Friday', nameTransliteration: "Al-Jumu'ah", nameBengali: 'আল-জুমুআ', ayahCount: 11, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 63, nameArabic: 'المنافقون', nameEnglish: 'The Hypocrites', nameTransliteration: 'Al-Munafiqun', nameBengali: 'আল-মুনাফিকুন', ayahCount: 11, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 64, nameArabic: 'التغابن', nameEnglish: 'The Mutual Disillusion', nameTransliteration: 'At-Taghabun', nameBengali: 'আত-তাগাবুন', ayahCount: 18, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 65, nameArabic: 'الطلاق', nameEnglish: 'The Divorce', nameTransliteration: 'At-Talaq', nameBengali: 'আত-তালাক', ayahCount: 12, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 66, nameArabic: 'التحريم', nameEnglish: 'The Prohibition', nameTransliteration: 'At-Tahrim', nameBengali: 'আত-তাহরীম', ayahCount: 12, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 28),
    Surah(number: 67, nameArabic: 'الملك', nameEnglish: 'The Sovereignty', nameTransliteration: 'Al-Mulk', nameBengali: 'আল-মুলক', ayahCount: 30, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 68, nameArabic: 'القلم', nameEnglish: 'The Pen', nameTransliteration: 'Al-Qalam', nameBengali: 'আল-কলম', ayahCount: 52, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 69, nameArabic: 'الحاقة', nameEnglish: 'The Reality', nameTransliteration: 'Al-Haqqah', nameBengali: 'আল-হাক্কা', ayahCount: 52, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 70, nameArabic: 'المعارج', nameEnglish: 'The Ascending Stairways', nameTransliteration: "Al-Ma'arij", nameBengali: 'আল-মাআরিজ', ayahCount: 44, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 71, nameArabic: 'نوح', nameEnglish: 'Noah', nameTransliteration: 'Nuh', nameBengali: 'নূহ', ayahCount: 28, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 72, nameArabic: 'الجن', nameEnglish: 'The Jinn', nameTransliteration: 'Al-Jinn', nameBengali: 'আল-জিন', ayahCount: 28, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 73, nameArabic: 'المزمل', nameEnglish: 'The Enshrouded One', nameTransliteration: 'Al-Muzzammil', nameBengali: 'আল-মুযযাম্মিল', ayahCount: 20, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 74, nameArabic: 'المدثر', nameEnglish: 'The Cloaked One', nameTransliteration: 'Al-Muddaththir', nameBengali: 'আল-মুদ্দাসসির', ayahCount: 56, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 75, nameArabic: 'القيامة', nameEnglish: 'The Resurrection', nameTransliteration: 'Al-Qiyamah', nameBengali: 'আল-কিয়ামা', ayahCount: 40, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 76, nameArabic: 'الإنسان', nameEnglish: 'The Man', nameTransliteration: 'Al-Insan', nameBengali: 'আল-ইনসান', ayahCount: 31, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 29),
    Surah(number: 77, nameArabic: 'المرسلات', nameEnglish: 'The Emissaries', nameTransliteration: 'Al-Mursalat', nameBengali: 'আল-মুরসালাত', ayahCount: 50, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 29),
    Surah(number: 78, nameArabic: 'النبأ', nameEnglish: 'The Tidings', nameTransliteration: "An-Naba'", nameBengali: 'আন-নাবা', ayahCount: 40, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 79, nameArabic: 'النازعات', nameEnglish: 'Those Who Drag Forth', nameTransliteration: "An-Nazi'at", nameBengali: 'আন-নাযিআত', ayahCount: 46, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 80, nameArabic: 'عبس', nameEnglish: 'He Frowned', nameTransliteration: 'Abasa', nameBengali: 'আবাসা', ayahCount: 42, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 81, nameArabic: 'التكوير', nameEnglish: 'The Overthrowing', nameTransliteration: 'At-Takwir', nameBengali: 'আত-তাকভীর', ayahCount: 29, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 82, nameArabic: 'الانفطار', nameEnglish: 'The Cleaving', nameTransliteration: 'Al-Infitar', nameBengali: 'আল-ইনফিতার', ayahCount: 19, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 83, nameArabic: 'المطففين', nameEnglish: 'The Defrauding', nameTransliteration: 'Al-Mutaffifin', nameBengali: 'আল-মুতাফফিফীন', ayahCount: 36, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 84, nameArabic: 'الانشقاق', nameEnglish: 'The Sundering', nameTransliteration: 'Al-Inshiqaq', nameBengali: 'আল-ইনশিকাক', ayahCount: 25, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 85, nameArabic: 'البروج', nameEnglish: 'The Mansions Of The Stars', nameTransliteration: 'Al-Buruj', nameBengali: 'আল-বুরূজ', ayahCount: 22, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 86, nameArabic: 'الطارق', nameEnglish: 'The Morning Star', nameTransliteration: 'At-Tariq', nameBengali: 'আত-তারিক', ayahCount: 17, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 87, nameArabic: 'الأعلى', nameEnglish: 'The Most High', nameTransliteration: "Al-A'la", nameBengali: 'আল-আলা', ayahCount: 19, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 88, nameArabic: 'الغاشية', nameEnglish: 'The Overwhelming', nameTransliteration: 'Al-Ghashiyah', nameBengali: 'আল-গাশিয়া', ayahCount: 26, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 89, nameArabic: 'الفجر', nameEnglish: 'The Dawn', nameTransliteration: 'Al-Fajr', nameBengali: 'আল-ফাজর', ayahCount: 30, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 90, nameArabic: 'البلد', nameEnglish: 'The City', nameTransliteration: 'Al-Balad', nameBengali: 'আল-বালাদ', ayahCount: 20, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 91, nameArabic: 'الشمس', nameEnglish: 'The Sun', nameTransliteration: 'Ash-Shams', nameBengali: 'আশ-শামস', ayahCount: 15, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 92, nameArabic: 'الليل', nameEnglish: 'The Night', nameTransliteration: 'Al-Layl', nameBengali: 'আল-লাইল', ayahCount: 21, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 93, nameArabic: 'الضحى', nameEnglish: 'The Morning Hours', nameTransliteration: 'Ad-Dhuha', nameBengali: 'আদ-দুহা', ayahCount: 11, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 94, nameArabic: 'الشرح', nameEnglish: 'The Relief', nameTransliteration: 'Ash-Sharh', nameBengali: 'আশ-শারহ', ayahCount: 8, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 95, nameArabic: 'التين', nameEnglish: 'The Fig', nameTransliteration: 'At-Tin', nameBengali: 'আত-তীন', ayahCount: 8, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 96, nameArabic: 'العلق', nameEnglish: 'The Clot', nameTransliteration: "Al-'Alaq", nameBengali: 'আল-আলাক', ayahCount: 19, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 97, nameArabic: 'القدر', nameEnglish: 'The Power', nameTransliteration: 'Al-Qadr', nameBengali: 'আল-কদর', ayahCount: 5, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 98, nameArabic: 'البينة', nameEnglish: 'The Clear Proof', nameTransliteration: 'Al-Bayyinah', nameBengali: 'আল-বাইয়্যিনাহ', ayahCount: 8, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 30),
    Surah(number: 99, nameArabic: 'الزلزلة', nameEnglish: 'The Earthquake', nameTransliteration: 'Az-Zalzalah', nameBengali: 'আয-যিলযাল', ayahCount: 8, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 30),
    Surah(number: 100, nameArabic: 'العاديات', nameEnglish: 'The Courser', nameTransliteration: "Al-'Adiyat", nameBengali: 'আল-আদিয়াত', ayahCount: 11, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 101, nameArabic: 'القارعة', nameEnglish: 'The Calamity', nameTransliteration: "Al-Qari'ah", nameBengali: 'আল-কারিয়া', ayahCount: 11, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 102, nameArabic: 'التكاثر', nameEnglish: 'The Rivalry In World Increase', nameTransliteration: 'At-Takathur', nameBengali: 'আত-তাকাসুর', ayahCount: 8, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 103, nameArabic: 'العصر', nameEnglish: 'The Declining Day', nameTransliteration: "Al-'Asr", nameBengali: 'আল-আসর', ayahCount: 3, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 104, nameArabic: 'الهمزة', nameEnglish: 'The Traducer', nameTransliteration: 'Al-Humazah', nameBengali: 'আল-হুমাযা', ayahCount: 9, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 105, nameArabic: 'الفيل', nameEnglish: 'The Elephant', nameTransliteration: 'Al-Fil', nameBengali: 'আল-ফীল', ayahCount: 5, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 106, nameArabic: 'قريش', nameEnglish: 'Quraysh', nameTransliteration: 'Quraysh', nameBengali: 'কুরাইশ', ayahCount: 4, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 107, nameArabic: 'الماعون', nameEnglish: 'The Small Kindnesses', nameTransliteration: "Al-Ma'un", nameBengali: 'আল-মাউন', ayahCount: 7, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 108, nameArabic: 'الكوثر', nameEnglish: 'The Abundance', nameTransliteration: 'Al-Kawthar', nameBengali: 'আল-কাওসার', ayahCount: 3, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 109, nameArabic: 'الكافرون', nameEnglish: 'The Disbelievers', nameTransliteration: 'Al-Kafirun', nameBengali: 'আল-কাফিরুন', ayahCount: 6, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 110, nameArabic: 'النصر', nameEnglish: 'The Divine Support', nameTransliteration: 'An-Nasr', nameBengali: 'আন-নাসর', ayahCount: 3, revelationType: 'Medinan', revelationTypeBengali: 'মাদানী', juzStart: 30),
    Surah(number: 111, nameArabic: 'المسد', nameEnglish: 'The Palm Fiber', nameTransliteration: 'Al-Masad', nameBengali: 'আল-মাসাদ', ayahCount: 5, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'The Sincerity', nameTransliteration: 'Al-Ikhlas', nameBengali: 'আল-ইখলাস', ayahCount: 4, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 113, nameArabic: 'الفلق', nameEnglish: 'The Daybreak', nameTransliteration: 'Al-Falaq', nameBengali: 'আল-ফালাক', ayahCount: 5, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
    Surah(number: 114, nameArabic: 'الناس', nameEnglish: 'Mankind', nameTransliteration: 'An-Nas', nameBengali: 'আন-নাস', ayahCount: 6, revelationType: 'Meccan', revelationTypeBengali: 'মক্কী', juzStart: 30),
  ];

  /// Get surah by number
  static Surah? getSurahByNumber(int number) {
    if (number < 1 || number > 114) return null;
    return surahs.firstWhere((s) => s.number == number);
  }

  /// Get surahs by Juz number
  static List<Surah> getSurahsByJuz(int juz) {
    return surahs.where((s) => s.juzStart == juz).toList();
  }

  /// Get surahs by revelation type
  static List<Surah> getMeccanSurahs() {
    return surahs.where((s) => s.revelationType == 'Meccan').toList();
  }

  static List<Surah> getMedinanSurahs() {
    return surahs.where((s) => s.revelationType == 'Medinan').toList();
  }

  /// Search surahs by name
  static List<Surah> searchSurahs(String query) {
    final lowerQuery = query.toLowerCase();
    return surahs.where((s) =>
        s.nameArabic.contains(query) ||
        s.nameEnglish.toLowerCase().contains(lowerQuery) ||
        s.nameTransliteration.toLowerCase().contains(lowerQuery) ||
        s.nameBengali.contains(query)).toList();
  }
}

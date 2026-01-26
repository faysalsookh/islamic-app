/// Model representing a single word in the Quran with its translation and grammar
class QuranWord {
  final int id;
  final int position;
  final String textUthmani;
  final String textSimple;
  final String? transliteration;
  final String? translationEn;
  final String? translationBn;
  final String? charTypeName; // word, end, pause_mark
  final String? audioUrl; // Audio URL for word pronunciation
  final WordGrammar? grammar;

  const QuranWord({
    required this.id,
    required this.position,
    required this.textUthmani,
    required this.textSimple,
    this.transliteration,
    this.translationEn,
    this.translationBn,
    this.charTypeName,
    this.audioUrl,
    this.grammar,
  });

  factory QuranWord.fromJson(Map<String, dynamic> json) {
    return QuranWord(
      id: json['id'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      textUthmani: json['text_uthmani'] as String? ?? json['text'] as String? ?? '',
      textSimple: json['text_imlaei'] as String? ?? json['text'] as String? ?? '',
      transliteration: _extractTransliteration(json),
      translationEn: _extractTranslation(json),
      translationBn: null,
      charTypeName: json['char_type_name'] as String?,
      audioUrl: _extractAudioUrl(json),
      grammar: _extractGrammar(json),
    );
  }

  /// Factory constructor for creating a word with both English and Bengali translations from API
  factory QuranWord.fromJsonWithBengali(
    Map<String, dynamic> englishJson,
    Map<String, dynamic>? bengaliJson,
  ) {
    return QuranWord(
      id: englishJson['id'] as int? ?? 0,
      position: englishJson['position'] as int? ?? 0,
      textUthmani: englishJson['text_uthmani'] as String? ?? englishJson['text'] as String? ?? '',
      textSimple: englishJson['text_imlaei'] as String? ?? englishJson['text'] as String? ?? '',
      transliteration: _extractTransliteration(englishJson),
      translationEn: _extractTranslation(englishJson),
      translationBn: bengaliJson != null ? _extractTranslation(bengaliJson) : null,
      charTypeName: englishJson['char_type_name'] as String?,
      audioUrl: _extractAudioUrl(englishJson),
      grammar: _extractGrammar(englishJson),
    );
  }

  /// Get full audio URL for word pronunciation
  String? get fullAudioUrl {
    if (audioUrl == null || audioUrl!.isEmpty) return null;
    return 'https://audio.qurancdn.com/$audioUrl';
  }

  static String? _extractTransliteration(Map<String, dynamic> json) {
    // Try different possible paths for transliteration
    if (json['transliteration'] != null) {
      final trans = json['transliteration'];
      if (trans is Map) {
        return trans['text'] as String?;
      }
      if (trans is String) {
        return trans;
      }
    }
    return null;
  }

  static String? _extractTranslation(Map<String, dynamic> json) {
    // Try different possible paths for translation
    // Path 1: translation.text (nested object)
    if (json['translation'] != null) {
      final trans = json['translation'];
      if (trans is Map) {
        return trans['text'] as String?;
      }
      if (trans is String) {
        return trans;
      }
    }

    // Path 2: word_translation (some API versions)
    if (json['word_translation'] != null) {
      return json['word_translation'] as String?;
    }

    return null;
  }

  static String? _extractAudioUrl(Map<String, dynamic> json) {
    if (json['audio_url'] != null) {
      return json['audio_url'] as String?;
    }
    return null;
  }

  static WordGrammar? _extractGrammar(Map<String, dynamic> json) {
    // Check for grammar data in various possible locations
    if (json['grammar'] != null) {
      return WordGrammar.fromJson(json['grammar'] as Map<String, dynamic>);
    }

    // Some API responses have grammar info at root level
    if (json['part_of_speech'] != null || json['root'] != null) {
      return WordGrammar.fromJson(json);
    }

    return null;
  }

  bool get isWord => charTypeName == 'word';
  bool get isEndMark => charTypeName == 'end';
  bool get isPauseMark => charTypeName == 'pause_mark';

  /// Get display translation (fallback to English if Bengali not available)
  String? get displayTranslation => translationBn ?? translationEn;
}

/// Grammar information for a Quran word
class WordGrammar {
  final String? partOfSpeech;
  final String? root;
  final String? lemma;
  final String? form;
  final String? mood;
  final String? person;
  final String? gender;
  final String? number;
  final String? voice;
  final String? aspect;
  final String? state;
  final String? case_;

  const WordGrammar({
    this.partOfSpeech,
    this.root,
    this.lemma,
    this.form,
    this.mood,
    this.person,
    this.gender,
    this.number,
    this.voice,
    this.aspect,
    this.state,
    this.case_,
  });

  factory WordGrammar.fromJson(Map<String, dynamic> json) {
    return WordGrammar(
      partOfSpeech: json['part_of_speech'] as String? ?? json['pos'] as String?,
      root: json['root'] as String?,
      lemma: json['lemma'] as String?,
      form: json['form'] as String?,
      mood: json['mood'] as String?,
      person: json['person'] as String?,
      gender: json['gender'] as String?,
      number: json['number'] as String?,
      voice: json['voice'] as String?,
      aspect: json['aspect'] as String?,
      state: json['state'] as String?,
      case_: json['case'] as String?,
    );
  }

  /// Get a human-readable description of the part of speech
  String get partOfSpeechDisplay {
    if (partOfSpeech == null) return 'Unknown';

    final posMap = {
      'N': 'Noun',
      'PN': 'Proper Noun',
      'ADJ': 'Adjective',
      'V': 'Verb',
      'IMPV': 'Imperative Verb',
      'PRP': 'Personal Pronoun',
      'DEM': 'Demonstrative Pronoun',
      'REL': 'Relative Pronoun',
      'CONJ': 'Conjunction',
      'P': 'Preposition',
      'INTG': 'Interrogative',
      'NEG': 'Negative Particle',
      'EMPH': 'Emphatic Particle',
      'SUB': 'Subordinate Conjunction',
      'ACC': 'Accusative Particle',
      'AMD': 'Amendment Particle',
      'ANS': 'Answer Particle',
      'AVR': 'Aversion Particle',
      'CERT': 'Certainty Particle',
      'CIRC': 'Circumstantial Particle',
      'COM': 'Comitative Particle',
      'COND': 'Conditional Particle',
      'EQ': 'Equalization Particle',
      'EXH': 'Exhortation Particle',
      'EXL': 'Explanation Particle',
      'EXP': 'Exceptive Particle',
      'FUT': 'Future Particle',
      'INC': 'Inceptive Particle',
      'INT': 'Interpretation Particle',
      'PREV': 'Preventive Particle',
      'PRO': 'Prohibition Particle',
      'REM': 'Resumption Particle',
      'RES': 'Restriction Particle',
      'RET': 'Retraction Particle',
      'RSLT': 'Result Particle',
      'SUP': 'Supplemental Particle',
      'SUR': 'Surprise Particle',
      'VOC': 'Vocative Particle',
      'INL': 'Initiation Particle',
      'T': 'Time Adverb',
      'LOC': 'Location Adverb',
    };

    return posMap[partOfSpeech?.toUpperCase()] ?? partOfSpeech ?? 'Unknown';
  }

  /// Get Bengali translation for part of speech
  String get partOfSpeechBengali {
    if (partOfSpeech == null) return 'অজানা';

    final posMapBn = {
      'N': 'বিশেষ্য',
      'PN': 'নামবাচক বিশেষ্য',
      'ADJ': 'বিশেষণ',
      'V': 'ক্রিয়া',
      'IMPV': 'আদেশসূচক ক্রিয়া',
      'PRP': 'ব্যক্তিবাচক সর্বনাম',
      'DEM': 'নির্দেশক সর্বনাম',
      'REL': 'সম্বন্ধবাচক সর্বনাম',
      'CONJ': 'সংযোজক',
      'P': 'অব্যয়',
      'INTG': 'প্রশ্নবোধক',
      'NEG': 'নেতিবাচক অব্যয়',
    };

    return posMapBn[partOfSpeech?.toUpperCase()] ?? partOfSpeechDisplay;
  }
}

/// Response wrapper for verse words API
class VerseWordsResponse {
  final List<QuranWord> words;
  final String verseKey;

  const VerseWordsResponse({
    required this.words,
    required this.verseKey,
  });

  factory VerseWordsResponse.fromJson(Map<String, dynamic> json, String verseKey) {
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    return VerseWordsResponse(
      words: wordsJson.map((w) => QuranWord.fromJson(w as Map<String, dynamic>)).toList(),
      verseKey: verseKey,
    );
  }

  /// Factory for creating response with both English and Bengali translations from API
  factory VerseWordsResponse.fromJsonWithDualLanguage(
    List<dynamic> englishWords,
    List<dynamic>? bengaliWords,
    String verseKey,
  ) {
    final words = <QuranWord>[];

    for (int i = 0; i < englishWords.length; i++) {
      final englishWord = englishWords[i] as Map<String, dynamic>;
      Map<String, dynamic>? bengaliWord;

      // Match Bengali word by position if available
      if (bengaliWords != null && i < bengaliWords.length) {
        bengaliWord = bengaliWords[i] as Map<String, dynamic>;
      }

      words.add(QuranWord.fromJsonWithBengali(englishWord, bengaliWord));
    }

    return VerseWordsResponse(
      words: words,
      verseKey: verseKey,
    );
  }
}

/// Common Arabic to Bengali word translations
/// This provides Bengali meanings for frequently used Quranic words
class ArabicBengaliDictionary {
  static const Map<String, String> _dictionary = {
    // Allah and attributes
    'Allah': 'আল্লাহ',
    '(of) Allah': 'আল্লাহর',
    'the Most Gracious': 'পরম করুণাময়',
    'the Most Merciful': 'অতি দয়ালু',
    'In (the) name': 'নামে',
    'In the name': 'নামে',
    'Lord': 'প্রভু',
    '(the) Lord': 'প্রভু',
    '(of) the worlds': 'জগতসমূহের',
    'the worlds': 'জগতসমূহ',

    // Common words
    'All praises': 'সমস্ত প্রশংসা',
    'All praise': 'সমস্ত প্রশংসা',
    'praise': 'প্রশংসা',
    'and': 'এবং',
    'or': 'অথবা',
    'not': 'না/নয়',
    'no': 'না',
    'is': 'হয়',
    'are': 'হয়',
    'was': 'ছিল',
    'were': 'ছিল',
    'will': 'হবে',
    'that': 'যে',
    'this': 'এই',
    'who': 'যে',
    'what': 'কি',
    'for': 'জন্য',
    'to': 'প্রতি',
    'from': 'থেকে',
    'in': 'মধ্যে',
    'on': 'উপর',
    'with': 'সাথে',
    'by': 'দ্বারা',
    'you': 'তুমি/তোমরা',
    'You': 'আপনি',
    'we': 'আমরা',
    'We': 'আমরা',
    'they': 'তারা',
    'he': 'সে',
    'He': 'তিনি',
    'she': 'সে',
    'it': 'এটা',
    'them': 'তাদের',
    'us': 'আমাদের',
    'your': 'তোমার',
    'Your': 'আপনার',
    'our': 'আমাদের',
    'their': 'তাদের',
    'his': 'তার',
    'His': 'তাঁর',

    // Verbs
    'worship': 'ইবাদত করি',
    'we worship': 'আমরা ইবাদত করি',
    'ask for help': 'সাহায্য চাই',
    'we ask for help': 'আমরা সাহায্য চাই',
    'Guide': 'পথ দেখান',
    'guide': 'পথ দেখান',
    'say': 'বলুন',
    'said': 'বলেছেন',
    'believe': 'বিশ্বাস করা',
    'believed': 'বিশ্বাস করেছে',
    'know': 'জানা',
    'fear': 'ভয় করা',
    'love': 'ভালোবাসা',
    'see': 'দেখা',
    'hear': 'শোনা',
    'do': 'করা',
    'did': 'করেছে',
    'make': 'তৈরি করা',
    'give': 'দেওয়া',
    'take': 'নেওয়া',
    'come': 'আসা',
    'go': 'যাওয়া',
    'send': 'পাঠানো',
    'create': 'সৃষ্টি করা',
    'created': 'সৃষ্টি করেছেন',

    // Religious terms
    'the path': 'পথ',
    'path': 'পথ',
    'the straight': 'সরল',
    'straight': 'সরল',
    'those who': 'যারা',
    'bestowed favor': 'অনুগ্রহ করেছেন',
    'upon them': 'তাদের উপর',
    'the ones': 'তারা',
    'anger': 'ক্রোধ',
    'angered': 'ক্রোধান্বিত',
    'astray': 'পথভ্রষ্ট',
    'gone astray': 'পথভ্রষ্ট',
    'those': 'তারা',
    'Day': 'দিন',
    'day': 'দিন',
    'Judgment': 'বিচার',
    'judgment': 'বিচার',
    '(of) the Judgment': 'বিচারের',
    'Master': 'মালিক',
    'master': 'মালিক',
    'King': 'রাজা',
    'Owner': 'মালিক',
    'Sovereign': 'সার্বভৌম',
    'only': 'শুধুমাত্র',
    'Alone': 'একাই',
    'alone': 'একাই',

    // More common Quranic terms
    'heaven': 'জান্নাত',
    'heavens': 'আসমানসমূহ',
    'earth': 'পৃথিবী',
    'book': 'কিতাব',
    'the Book': 'কিতাব',
    'people': 'মানুষ',
    'mankind': 'মানবজাতি',
    'soul': 'আত্মা',
    'heart': 'অন্তর',
    'messenger': 'রাসূল',
    'Messenger': 'রাসূল',
    'prophet': 'নবী',
    'Prophet': 'নবী',
    'sign': 'নিদর্শন',
    'signs': 'নিদর্শনসমূহ',
    'truth': 'সত্য',
    'the truth': 'সত্য',
    'light': 'আলো',
    'the light': 'আলো',
    'guidance': 'হেদায়েত',
    'the guidance': 'হেদায়েত',
    'mercy': 'রহমত',
    'the mercy': 'রহমত',
    'forgiveness': 'ক্ষমা',
    'prayer': 'সালাত',
    'the prayer': 'সালাত',
    'righteous': 'সৎকর্মশীল',
    'believers': 'মুমিনগণ',
    'disbelievers': 'কাফিরগণ',
    'reward': 'পুরস্কার',
    'punishment': 'শাস্তি',
    'fire': 'আগুন',
    'the Fire': 'জাহান্নাম',
    'paradise': 'জান্নাত',
    'Paradise': 'জান্নাত',
    'good': 'ভালো',
    'evil': 'মন্দ',
    'right': 'সঠিক',
    'wrong': 'ভুল',
  };

  /// Get Bengali translation for an English word
  static String? getBengali(String? englishWord) {
    if (englishWord == null || englishWord.isEmpty) return null;

    // Direct match
    if (_dictionary.containsKey(englishWord)) {
      return _dictionary[englishWord];
    }

    // Try lowercase
    final lower = englishWord.toLowerCase();
    for (final entry in _dictionary.entries) {
      if (entry.key.toLowerCase() == lower) {
        return entry.value;
      }
    }

    // Try removing parentheses
    final cleaned = englishWord.replaceAll(RegExp(r'[()]'), '').trim();
    if (_dictionary.containsKey(cleaned)) {
      return _dictionary[cleaned];
    }

    return null;
  }
}

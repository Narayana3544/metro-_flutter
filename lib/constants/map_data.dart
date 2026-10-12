import 'dart:ui';

class MapData {
  static const Map<String, List<String>> depotSections = {
    'Miyapur': ['TT', 'SBL', 'IBL', 'PW', 'WP'],
    'Uppal': ['TT', 'SBL', 'IBL', 'WL', 'MAIN'],
  };

  static const Map<String, Map<String, String>> sectionColors = {
    'Miyapur': {
      'TT': '#86D105', // Green
      'SBL': '#FFA633', // Orange
      'IBL': '#01E6FF', // Cyan
      'PW': '#8351F8', // Purple
      'WP': '#777177', // Grey
    },
    'Uppal': {
      'TT': '#86D105', // Green
      'SBL': '#FFA633', // Orange
      'IBL': '#01E6FF', // Cyan
      'WL': '#F15BEF', // Pink
      'MAIN': '#6C5BF1', // Violet
    },
  };

  /// Native SVG pixel bounding boxes for each section:
  /// Miyapur native size: 4076 x 2380
  /// Uppal native size: 2644 x 2112
  static const Map<String, Map<String, Rect>> sectionBounds = {
    'Miyapur': {
      'TT': Rect.fromLTWH(1722.59, 401.00, 643.26, 225.04),
      'SBL': Rect.fromLTWH(1593.69, 688.00, 582.69, 404.31),
      'IBL': Rect.fromLTWH(1467.69, 1131.90, 540.44, 262.60),
      'PW': Rect.fromLTWH(1760.67, 1129.21, 229.77, 115.89),
      'WP': Rect.fromLTWH(1809.69, 1032.58, 333.39, 109.62),
    },
    'Uppal': {
      'TT': Rect.fromLTWH(1766.47, 249.61, 702.12, 436.70),
      'SBL': Rect.fromLTWH(468.19, 847.00, 703.52, 422.30),
      'IBL': Rect.fromLTWH(1682.00, 431.00, 590.06, 398.57),
      'WL': Rect.fromLTWH(1355.48, 841.10, 447.00, 257.97),
      'MAIN': Rect.fromLTWH(1765.09, 760.89, 407.48, 306.87),
    },
  };

  /// Normalized centers (x / nativeWidth, y / nativeHeight)
  static const Map<String, Map<String, OffsetData>> sectionCenters = {
    'Miyapur': {
      'TT': OffsetData(0.502, 0.216),
      'SBL': OffsetData(0.462, 0.374),
      'IBL': OffsetData(0.426, 0.531),
      'PW': OffsetData(0.460, 0.499),
      'WP': OffsetData(0.485, 0.457),
    },
    'Uppal': {
      'TT': OffsetData(0.801, 0.222),
      'SBL': OffsetData(0.310, 0.501),
      'IBL': OffsetData(0.748, 0.298),
      'WL': OffsetData(0.597, 0.459),
      'MAIN': OffsetData(0.745, 0.433),
    },
  };

  static const Map<String, Map<String, double>> zoomLevels = {
    'Miyapur': {
      'TT': 1.6,
      'SBL': 1.5,
      'IBL': 1.6,
      'PW': 2.0,
      'WP': 2.0,
    },
    'Uppal': {
      'TT': 1.5,
      'SBL': 1.4,
      'IBL': 1.6,
      'WL': 2.0,
      'MAIN': 1.8,
    },
  };

  static const Map<String, Map<String, int>> sectionCapacity = {
    'Miyapur': {
      'TT': 1, // MPTT
      'SBL': 24, // MPSBL
      'IBL': 8, // MPIBL
      'PW': 2, // MPPW
      'WP': 1, // MPWP
    },
    'Uppal': {
      'TT': 1, // UPTT
      'SBL': 32, // UPSBL
      'IBL': 8, // UPLIBL
      'WL': 1, // UPLWL
      'MAIN': 4, // UPL Main
    },
  };

  static const Map<String, TrackBounds> trackBounds = {
    // Miyapur
    'MPSBL-1': TrackBounds(x: 259.00, y: 188.00, w: 68.00, h: 11.25),
    'MPSBL-2': TrackBounds(x: 337.00, y: 188.00, w: 68.00, h: 11.25),
    'MPSBL-3': TrackBounds(x: 337.00, y: 201.00, w: 68.00, h: 11.25),
    'MPSBL-4': TrackBounds(x: 337.00, y: 214.00, w: 68.00, h: 11.25),
    'MPSBL-5': TrackBounds(x: 337.00, y: 228.00, w: 68.00, h: 11.25),
    'MPSBL-6': TrackBounds(x: 337.00, y: 244.00, w: 68.00, h: 11.25),
    'MPSBL-7': TrackBounds(x: 337.00, y: 257.00, w: 68.00, h: 11.25),
    'MPSBL-8': TrackBounds(x: 337.00, y: 270.00, w: 68.00, h: 11.25),
    'MPSBL-9': TrackBounds(x: 337.00, y: 283.00, w: 68.00, h: 11.25),
    'MPSBL-10': TrackBounds(x: 337.00, y: 299.00, w: 68.00, h: 11.25),
    'MPSBL-11': TrackBounds(x: 337.00, y: 312.00, w: 68.00, h: 11.25),
    'MPSBL-12': TrackBounds(x: 337.00, y: 325.00, w: 68.00, h: 11.25),
    'MPSBL-13': TrackBounds(x: 337.00, y: 339.00, w: 68.00, h: 11.25),
    'MPSBL-14': TrackBounds(x: 259.00, y: 201.00, w: 68.00, h: 11.25),
    'MPSBL-15': TrackBounds(x: 259.00, y: 214.00, w: 68.00, h: 11.25),
    'MPSBL-16': TrackBounds(x: 259.00, y: 228.00, w: 68.00, h: 11.25),
    'MPSBL-17': TrackBounds(x: 259.00, y: 244.00, w: 68.00, h: 11.25),
    'MPSBL-18': TrackBounds(x: 259.00, y: 257.00, w: 68.00, h: 11.25),
    'MPSBL-19': TrackBounds(x: 259.00, y: 270.00, w: 68.00, h: 11.25),
    'MPSBL-20': TrackBounds(x: 259.00, y: 283.00, w: 68.00, h: 11.25),
    'MPSBL-21': TrackBounds(x: 259.00, y: 299.00, w: 68.00, h: 11.25),
    'MPSBL-22': TrackBounds(x: 259.00, y: 312.00, w: 68.00, h: 11.25),
    'MPSBL-23': TrackBounds(x: 259.00, y: 325.00, w: 68.00, h: 11.25),
    'MPSBL-24': TrackBounds(x: 259.00, y: 339.00, w: 68.00, h: 11.25),
    'MPTT-1': TrackBounds(x: 324.00, y: 46.00, w: 68.00, h: 11.25),
    'MPWP-1': TrackBounds(x: 297.00, y: 356.00, w: 68.00, h: 11.25),
    'MPPW-1': TrackBounds(x: 329.00, y: 390.00, w: 68.00, h: 11.25),
    'MPPW-2': TrackBounds(x: 329.00, y: 413.00, w: 68.00, h: 11.25),
    'MPIBL-1': TrackBounds(x: 242.00, y: 428.00, w: 68.00, h: 11.25),
    'MPIBL-2': TrackBounds(x: 242.00, y: 442.00, w: 68.00, h: 11.25),
    'MPIBL-3': TrackBounds(x: 242.00, y: 455.00, w: 68.00, h: 11.25),
    'MPIBL-4': TrackBounds(x: 242.00, y: 468.00, w: 68.00, h: 11.25),
    'MPIBL-5': TrackBounds(x: 329.00, y: 429.00, w: 68.00, h: 11.25),
    'MPIBL-6': TrackBounds(x: 329.00, y: 442.00, w: 68.00, h: 11.25),
    'MPIBL-7': TrackBounds(x: 329.00, y: 455.00, w: 68.00, h: 11.25),
    'MPIBL-8': TrackBounds(x: 329.00, y: 468.00, w: 68.00, h: 11.25),

    // Uppal
    'UPSBL-1': TrackBounds(x: 79.00, y: 240.00, w: 153.00, h: 11.25),
    'UPSBL-2': TrackBounds(x: 241.00, y: 240.00, w: 153.00, h: 11.25),
    'UPSBL-3': TrackBounds(x: 79.00, y: 253.00, w: 153.00, h: 11.25),
    'UPSBL-4': TrackBounds(x: 241.00, y: 253.00, w: 153.00, h: 11.25),
    'UPSBL-5': TrackBounds(x: 79.00, y: 266.00, w: 153.00, h: 11.25),
    'UPSBL-6': TrackBounds(x: 241.00, y: 266.00, w: 153.00, h: 11.25),
    'UPSBL-7': TrackBounds(x: 79.00, y: 279.00, w: 153.00, h: 11.25),
    'UPSBL-8': TrackBounds(x: 241.00, y: 279.00, w: 153.00, h: 11.25),
    'UPSBL-9': TrackBounds(x: 79.00, y: 292.00, w: 153.00, h: 11.25),
    'UPSBL-10': TrackBounds(x: 241.00, y: 292.00, w: 153.00, h: 11.25),
    'UPSBL-11': TrackBounds(x: 79.00, y: 304.00, w: 153.00, h: 11.25),
    'UPSBL-12': TrackBounds(x: 241.00, y: 304.00, w: 153.00, h: 11.25),
    'UPSBL-13': TrackBounds(x: 79.00, y: 317.00, w: 153.00, h: 11.25),
    'UPSBL-14': TrackBounds(x: 241.00, y: 317.00, w: 153.00, h: 11.25),
    'UPSBL-15': TrackBounds(x: 79.00, y: 330.00, w: 153.00, h: 11.25),
    'UPSBL-16': TrackBounds(x: 241.00, y: 330.00, w: 153.00, h: 11.25),
    'UPSBL-17': TrackBounds(x: 79.00, y: 343.00, w: 153.00, h: 11.25),
    'UPSBL-18': TrackBounds(x: 241.00, y: 343.00, w: 153.00, h: 11.25),
    'UPSBL-19': TrackBounds(x: 79.00, y: 355.00, w: 153.00, h: 11.25),
    'UPSBL-20': TrackBounds(x: 241.00, y: 355.00, w: 153.00, h: 11.25),
    'UPSBL-21': TrackBounds(x: 79.00, y: 368.00, w: 153.00, h: 11.25),
    'UPSBL-22': TrackBounds(x: 241.00, y: 368.00, w: 153.00, h: 11.25),
    'UPSBL-23': TrackBounds(x: 79.00, y: 381.00, w: 153.00, h: 11.25),
    'UPSBL-24': TrackBounds(x: 241.00, y: 381.00, w: 153.00, h: 11.25),
    'UPSBL-25': TrackBounds(x: 80.00, y: 394.00, w: 153.00, h: 11.25),
    'UPSBL-26': TrackBounds(x: 242.00, y: 394.00, w: 153.00, h: 11.25),
    'UPSBL-27': TrackBounds(x: 80.00, y: 407.00, w: 153.00, h: 11.25),
    'UPSBL-28': TrackBounds(x: 242.00, y: 407.00, w: 153.00, h: 11.25),
    'UPSBL-29': TrackBounds(x: 79.00, y: 438.00, w: 153.00, h: 11.25),
    'UPSBL-30': TrackBounds(x: 241.00, y: 438.00, w: 153.00, h: 11.25),
    'UPSBL-31': TrackBounds(x: 79.00, y: 452.00, w: 153.00, h: 11.25),
    'UPSBL-32': TrackBounds(x: 241.00, y: 452.00, w: 153.00, h: 11.25),
    'UPWL-1': TrackBounds(x: 218.00, y: 209.00, w: 153.00, h: 11.25),
    'UPTT-1': TrackBounds(x: 267.00, y: 36.00, w: 153.00, h: 11.25),
    'UPIBL-1': TrackBounds(x: 202.00, y: 76.00, w: 81.00, h: 11.25),
    'UPIBL-2': TrackBounds(x: 202.00, y: 90.00, w: 81.00, h: 11.25),
    'UPIBL-3': TrackBounds(x: 202.00, y: 102.00, w: 81.00, h: 11.25),
    'UPIBL-4': TrackBounds(x: 202.00, y: 115.00, w: 81.00, h: 11.25),
    'UPIBL-5': TrackBounds(x: 293.00, y: 76.00, w: 81.00, h: 11.25),
    'UPIBL-6': TrackBounds(x: 293.00, y: 89.00, w: 81.00, h: 11.25),
    'UPIBL-7': TrackBounds(x: 293.00, y: 102.00, w: 81.00, h: 11.25),
    'UPIBL-8': TrackBounds(x: 293.00, y: 115.00, w: 81.00, h: 11.25),
    'UPMAIN-1': TrackBounds(x: 293.00, y: 128.00, w: 81.00, h: 11.25),
    'UPMAIN-2': TrackBounds(x: 293.00, y: 141.00, w: 81.00, h: 11.25),
    'UPMAIN-3': TrackBounds(x: 293.00, y: 153.00, w: 81.00, h: 11.25),
    'UPMAIN-4': TrackBounds(x: 293.00, y: 166.00, w: 81.00, h: 11.25),
  };

  static List<String> getTracks(String depot, String section) {
    if (depot.isEmpty) return [];

    final depotPrefix = depot == 'Miyapur' ? 'MP' : 'UP';

    if (section.isEmpty) {
      final tracks = trackBounds.keys
          .where((track) => track.startsWith(depotPrefix))
          .toList();
      return tracks;
    }

    final prefix = '$depotPrefix$section-';
    final tracks = trackBounds.keys
        .where((track) => track.startsWith(prefix))
        .toList();

    tracks.sort((a, b) {
      final aNo = int.tryParse(a.split('-').last) ?? 0;
      final bNo = int.tryParse(b.split('-').last) ?? 0;
      return aNo.compareTo(bNo);
    });

    return tracks;
  }
}

class TrackBounds {
  final double x;
  final double y;
  final double w;
  final double h;

  const TrackBounds({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

class OffsetData {
  final double x;
  final double y;

  const OffsetData(this.x, this.y);
}

// Created: 2026-09-19
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// How far a folding device is open (iOS 27.1 `UIHinge.Status`).
enum CNHingeStatus {
  /// No hinge: not a folding device, not iOS, or iOS before 27.1.
  none,

  /// A hinge whose position the system doesn't know yet.
  unknown,

  /// Closed: the outer display.
  closed,

  /// Part-way open: a book, a laptop or a tent.
  partiallyOpen,

  /// Open as far as it goes: one flat display.
  fullyOpen,
}

/// The poses Apple names for iPhone Duo, read from the hinge and where the
/// fold runs. See "Designing for iPhone Duo" → Device poses.
enum CNDevicePose {
  /// Anything without a hinge.
  none,

  /// Closed, using the outer display (a tent, standing on its edges, reads
  /// as this too: the system shows the outer display).
  closed,

  /// Part-way open with the fold running down the screen — held like a book,
  /// two pages side by side.
  book,

  /// Part-way open with the fold running across — a laptop: screen above,
  /// desk below.
  laptop,

  /// Open flat.
  flat,
}

/// A snapshot of the fold: [status], [angle], and where on screen the fold
/// ([folds]) and the camera ([occlusions]) are, in logical pixels.
@immutable
class CNHinge {
  const CNHinge({
    this.status = CNHingeStatus.none,
    this.angle,
    this.folds = const <Rect>[],
    this.occlusions = const <Rect>[],
  });

  /// No hinge at all.
  static const CNHinge none = CNHinge();

  final CNHingeStatus status;

  /// The angle between the two halves, in radians (π is flat), when the
  /// system reports it.
  final double? angle;

  /// Where the fold is — the part of the display content should keep clear
  /// of while the device is part-way open. Empty when flat or closed.
  final List<Rect> folds;

  /// Regions content must not cover, such as the camera.
  final List<Rect> occlusions;

  /// The fold, if there is one to keep clear of.
  Rect? get fold => folds.isEmpty ? null : folds.first;

  /// Which pose this is, from the status and the fold's direction.
  CNDevicePose get pose {
    switch (status) {
      case CNHingeStatus.none:
      case CNHingeStatus.unknown:
        return CNDevicePose.none;
      case CNHingeStatus.closed:
        return CNDevicePose.closed;
      case CNHingeStatus.fullyOpen:
        return CNDevicePose.flat;
      case CNHingeStatus.partiallyOpen:
        final Rect? f = fold;
        if (f == null) return CNDevicePose.flat;
        return f.height >= f.width ? CNDevicePose.book : CNDevicePose.laptop;
    }
  }

  static CNHinge _decode(Object? raw) {
    if (raw is! Map) return none;
    List<Rect> rects(Object? list) => [
          if (list is List)
            for (final r in list)
              if (r is Map)
                Rect.fromLTWH(
                  (r['x'] as num).toDouble(),
                  (r['y'] as num).toDouble(),
                  (r['width'] as num).toDouble(),
                  (r['height'] as num).toDouble(),
                ),
        ];
    final CNHingeStatus status = switch (raw['status']) {
      'closed' => CNHingeStatus.closed,
      'partiallyOpen' => CNHingeStatus.partiallyOpen,
      'fullyOpen' => CNHingeStatus.fullyOpen,
      'unknown' => CNHingeStatus.unknown,
      _ => CNHingeStatus.none,
    };
    return CNHinge(
      status: status,
      angle: (raw['angle'] as num?)?.toDouble(),
      folds: rects(raw['folds']),
      occlusions: rects(raw['occlusions']),
    );
  }

  /// Updates as the device folds, unfolds or rotates. A single value of
  /// [CNHinge.none] anywhere without a hinge.
  static Stream<CNHinge> watch() {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return Stream<CNHinge>.value(none);
    }
    return const EventChannel('cupertino_native/hinge')
        .receiveBroadcastStream()
        .map(_decode)
        .handleError((Object _) {});
  }

  /// The state now.
  static Future<CNHinge> current() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return none;
    try {
      return _decode(
        await const MethodChannel('cupertino_native/hinge_query')
            .invokeMethod<Object?>('get'),
      );
    } catch (_) {
      return none;
    }
  }

  /// The nearest [CNHingeScope]'s state, or [none] without one. Rebuilds the
  /// caller when it changes.
  static CNHinge of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CNHingeData>()?.hinge ??
      none;

  @override
  bool operator ==(Object other) =>
      other is CNHinge &&
      other.status == status &&
      other.angle == angle &&
      listEquals(other.folds, folds) &&
      listEquals(other.occlusions, occlusions);

  @override
  int get hashCode => Object.hash(
        status,
        angle,
        Object.hashAll(folds),
        Object.hashAll(occlusions),
      );

  @override
  String toString() =>
      'CNHinge($status, pose: $pose, angle: $angle, folds: $folds)';
}

/// Puts the live [CNHinge] into the tree for [CNHinge.of]. Place once, above
/// the app.
class CNHingeScope extends StatefulWidget {
  const CNHingeScope({super.key, required this.child});

  final Widget child;

  @override
  State<CNHingeScope> createState() => _CNHingeScopeState();
}

class _CNHingeScopeState extends State<CNHingeScope> {
  CNHinge _hinge = CNHinge.none;
  StreamSubscription<CNHinge>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = CNHinge.watch().listen((h) {
      if (mounted && h != _hinge) setState(() => _hinge = h);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _CNHingeData(hinge: _hinge, child: widget.child);
}

class _CNHingeData extends InheritedWidget {
  const _CNHingeData({required this.hinge, required super.child});

  final CNHinge hinge;

  @override
  bool updateShouldNotify(_CNHingeData old) => old.hinge != hinge;
}

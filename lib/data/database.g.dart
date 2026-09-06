// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $InterventionEventsTable extends InterventionEvents
    with TableInfo<$InterventionEventsTable, InterventionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterventionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _appNameMeta =
      const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
      'app_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _outcomeMeta =
      const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
      'outcome', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _pauseSecondsMeta =
      const VerificationMeta('pauseSeconds');
  @override
  late final GeneratedColumn<int> pauseSeconds = GeneratedColumn<int>(
      'pause_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _riskScoreMeta =
      const VerificationMeta('riskScore');
  @override
  late final GeneratedColumn<double> riskScore = GeneratedColumn<double>(
      'risk_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hourOfDayMeta =
      const VerificationMeta('hourOfDay');
  @override
  late final GeneratedColumn<int> hourOfDay = GeneratedColumn<int>(
      'hour_of_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weekdayMeta =
      const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
      'weekday', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _opensBeforeMeta =
      const VerificationMeta('opensBefore');
  @override
  late final GeneratedColumn<int> opensBefore = GeneratedColumn<int>(
      'opens_before', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _minutesSinceLastOpenMeta =
      const VerificationMeta('minutesSinceLastOpen');
  @override
  late final GeneratedColumn<int> minutesSinceLastOpen = GeneratedColumn<int>(
      'minutes_since_last_open', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        timestamp,
        packageName,
        appName,
        reason,
        outcome,
        pauseSeconds,
        riskScore,
        hourOfDay,
        weekday,
        opensBefore,
        minutesSinceLastOpen
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intervention_events';
  @override
  VerificationContext validateIntegrity(Insertable<InterventionEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta,
          outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('pause_seconds')) {
      context.handle(
          _pauseSecondsMeta,
          pauseSeconds.isAcceptableOrUnknown(
              data['pause_seconds']!, _pauseSecondsMeta));
    } else if (isInserting) {
      context.missing(_pauseSecondsMeta);
    }
    if (data.containsKey('risk_score')) {
      context.handle(_riskScoreMeta,
          riskScore.isAcceptableOrUnknown(data['risk_score']!, _riskScoreMeta));
    }
    if (data.containsKey('hour_of_day')) {
      context.handle(
          _hourOfDayMeta,
          hourOfDay.isAcceptableOrUnknown(
              data['hour_of_day']!, _hourOfDayMeta));
    } else if (isInserting) {
      context.missing(_hourOfDayMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta,
          weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('opens_before')) {
      context.handle(
          _opensBeforeMeta,
          opensBefore.isAcceptableOrUnknown(
              data['opens_before']!, _opensBeforeMeta));
    } else if (isInserting) {
      context.missing(_opensBeforeMeta);
    }
    if (data.containsKey('minutes_since_last_open')) {
      context.handle(
          _minutesSinceLastOpenMeta,
          minutesSinceLastOpen.isAcceptableOrUnknown(
              data['minutes_since_last_open']!, _minutesSinceLastOpenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterventionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterventionEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
      appName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_name'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      outcome: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}outcome'])!,
      pauseSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pause_seconds'])!,
      riskScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}risk_score']),
      hourOfDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hour_of_day'])!,
      weekday: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      opensBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}opens_before'])!,
      minutesSinceLastOpen: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}minutes_since_last_open']),
    );
  }

  @override
  $InterventionEventsTable createAlias(String alias) {
    return $InterventionEventsTable(attachedDatabase, alias);
  }
}

class InterventionEvent extends DataClass
    implements Insertable<InterventionEvent> {
  final int id;
  final DateTime timestamp;
  final String packageName;
  final String appName;

  /// Which intention the user tapped (see `PauseReason`).
  final String reason;

  /// `home` (they backed out) or `openedAnyway`.
  final String outcome;

  /// How long the pause locked them out, in seconds (adaptive).
  final int pauseSeconds;

  /// What the risk model predicted just before showing the pause, if it had
  /// enough data to predict at all.
  final double? riskScore;
  final int hourOfDay;
  final int weekday;
  final int opensBefore;
  final int? minutesSinceLastOpen;
  const InterventionEvent(
      {required this.id,
      required this.timestamp,
      required this.packageName,
      required this.appName,
      required this.reason,
      required this.outcome,
      required this.pauseSeconds,
      this.riskScore,
      required this.hourOfDay,
      required this.weekday,
      required this.opensBefore,
      this.minutesSinceLastOpen});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    map['reason'] = Variable<String>(reason);
    map['outcome'] = Variable<String>(outcome);
    map['pause_seconds'] = Variable<int>(pauseSeconds);
    if (!nullToAbsent || riskScore != null) {
      map['risk_score'] = Variable<double>(riskScore);
    }
    map['hour_of_day'] = Variable<int>(hourOfDay);
    map['weekday'] = Variable<int>(weekday);
    map['opens_before'] = Variable<int>(opensBefore);
    if (!nullToAbsent || minutesSinceLastOpen != null) {
      map['minutes_since_last_open'] = Variable<int>(minutesSinceLastOpen);
    }
    return map;
  }

  InterventionEventsCompanion toCompanion(bool nullToAbsent) {
    return InterventionEventsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      packageName: Value(packageName),
      appName: Value(appName),
      reason: Value(reason),
      outcome: Value(outcome),
      pauseSeconds: Value(pauseSeconds),
      riskScore: riskScore == null && nullToAbsent
          ? const Value.absent()
          : Value(riskScore),
      hourOfDay: Value(hourOfDay),
      weekday: Value(weekday),
      opensBefore: Value(opensBefore),
      minutesSinceLastOpen: minutesSinceLastOpen == null && nullToAbsent
          ? const Value.absent()
          : Value(minutesSinceLastOpen),
    );
  }

  factory InterventionEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterventionEvent(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      reason: serializer.fromJson<String>(json['reason']),
      outcome: serializer.fromJson<String>(json['outcome']),
      pauseSeconds: serializer.fromJson<int>(json['pauseSeconds']),
      riskScore: serializer.fromJson<double?>(json['riskScore']),
      hourOfDay: serializer.fromJson<int>(json['hourOfDay']),
      weekday: serializer.fromJson<int>(json['weekday']),
      opensBefore: serializer.fromJson<int>(json['opensBefore']),
      minutesSinceLastOpen:
          serializer.fromJson<int?>(json['minutesSinceLastOpen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'reason': serializer.toJson<String>(reason),
      'outcome': serializer.toJson<String>(outcome),
      'pauseSeconds': serializer.toJson<int>(pauseSeconds),
      'riskScore': serializer.toJson<double?>(riskScore),
      'hourOfDay': serializer.toJson<int>(hourOfDay),
      'weekday': serializer.toJson<int>(weekday),
      'opensBefore': serializer.toJson<int>(opensBefore),
      'minutesSinceLastOpen': serializer.toJson<int?>(minutesSinceLastOpen),
    };
  }

  InterventionEvent copyWith(
          {int? id,
          DateTime? timestamp,
          String? packageName,
          String? appName,
          String? reason,
          String? outcome,
          int? pauseSeconds,
          Value<double?> riskScore = const Value.absent(),
          int? hourOfDay,
          int? weekday,
          int? opensBefore,
          Value<int?> minutesSinceLastOpen = const Value.absent()}) =>
      InterventionEvent(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
        packageName: packageName ?? this.packageName,
        appName: appName ?? this.appName,
        reason: reason ?? this.reason,
        outcome: outcome ?? this.outcome,
        pauseSeconds: pauseSeconds ?? this.pauseSeconds,
        riskScore: riskScore.present ? riskScore.value : this.riskScore,
        hourOfDay: hourOfDay ?? this.hourOfDay,
        weekday: weekday ?? this.weekday,
        opensBefore: opensBefore ?? this.opensBefore,
        minutesSinceLastOpen: minutesSinceLastOpen.present
            ? minutesSinceLastOpen.value
            : this.minutesSinceLastOpen,
      );
  InterventionEvent copyWithCompanion(InterventionEventsCompanion data) {
    return InterventionEvent(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      reason: data.reason.present ? data.reason.value : this.reason,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      pauseSeconds: data.pauseSeconds.present
          ? data.pauseSeconds.value
          : this.pauseSeconds,
      riskScore: data.riskScore.present ? data.riskScore.value : this.riskScore,
      hourOfDay: data.hourOfDay.present ? data.hourOfDay.value : this.hourOfDay,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      opensBefore:
          data.opensBefore.present ? data.opensBefore.value : this.opensBefore,
      minutesSinceLastOpen: data.minutesSinceLastOpen.present
          ? data.minutesSinceLastOpen.value
          : this.minutesSinceLastOpen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterventionEvent(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('reason: $reason, ')
          ..write('outcome: $outcome, ')
          ..write('pauseSeconds: $pauseSeconds, ')
          ..write('riskScore: $riskScore, ')
          ..write('hourOfDay: $hourOfDay, ')
          ..write('weekday: $weekday, ')
          ..write('opensBefore: $opensBefore, ')
          ..write('minutesSinceLastOpen: $minutesSinceLastOpen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      timestamp,
      packageName,
      appName,
      reason,
      outcome,
      pauseSeconds,
      riskScore,
      hourOfDay,
      weekday,
      opensBefore,
      minutesSinceLastOpen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterventionEvent &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.reason == this.reason &&
          other.outcome == this.outcome &&
          other.pauseSeconds == this.pauseSeconds &&
          other.riskScore == this.riskScore &&
          other.hourOfDay == this.hourOfDay &&
          other.weekday == this.weekday &&
          other.opensBefore == this.opensBefore &&
          other.minutesSinceLastOpen == this.minutesSinceLastOpen);
}

class InterventionEventsCompanion extends UpdateCompanion<InterventionEvent> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String> reason;
  final Value<String> outcome;
  final Value<int> pauseSeconds;
  final Value<double?> riskScore;
  final Value<int> hourOfDay;
  final Value<int> weekday;
  final Value<int> opensBefore;
  final Value<int?> minutesSinceLastOpen;
  const InterventionEventsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.reason = const Value.absent(),
    this.outcome = const Value.absent(),
    this.pauseSeconds = const Value.absent(),
    this.riskScore = const Value.absent(),
    this.hourOfDay = const Value.absent(),
    this.weekday = const Value.absent(),
    this.opensBefore = const Value.absent(),
    this.minutesSinceLastOpen = const Value.absent(),
  });
  InterventionEventsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required String packageName,
    required String appName,
    required String reason,
    required String outcome,
    required int pauseSeconds,
    this.riskScore = const Value.absent(),
    required int hourOfDay,
    required int weekday,
    required int opensBefore,
    this.minutesSinceLastOpen = const Value.absent(),
  })  : timestamp = Value(timestamp),
        packageName = Value(packageName),
        appName = Value(appName),
        reason = Value(reason),
        outcome = Value(outcome),
        pauseSeconds = Value(pauseSeconds),
        hourOfDay = Value(hourOfDay),
        weekday = Value(weekday),
        opensBefore = Value(opensBefore);
  static Insertable<InterventionEvent> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? reason,
    Expression<String>? outcome,
    Expression<int>? pauseSeconds,
    Expression<double>? riskScore,
    Expression<int>? hourOfDay,
    Expression<int>? weekday,
    Expression<int>? opensBefore,
    Expression<int>? minutesSinceLastOpen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (reason != null) 'reason': reason,
      if (outcome != null) 'outcome': outcome,
      if (pauseSeconds != null) 'pause_seconds': pauseSeconds,
      if (riskScore != null) 'risk_score': riskScore,
      if (hourOfDay != null) 'hour_of_day': hourOfDay,
      if (weekday != null) 'weekday': weekday,
      if (opensBefore != null) 'opens_before': opensBefore,
      if (minutesSinceLastOpen != null)
        'minutes_since_last_open': minutesSinceLastOpen,
    });
  }

  InterventionEventsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? timestamp,
      Value<String>? packageName,
      Value<String>? appName,
      Value<String>? reason,
      Value<String>? outcome,
      Value<int>? pauseSeconds,
      Value<double?>? riskScore,
      Value<int>? hourOfDay,
      Value<int>? weekday,
      Value<int>? opensBefore,
      Value<int?>? minutesSinceLastOpen}) {
    return InterventionEventsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      reason: reason ?? this.reason,
      outcome: outcome ?? this.outcome,
      pauseSeconds: pauseSeconds ?? this.pauseSeconds,
      riskScore: riskScore ?? this.riskScore,
      hourOfDay: hourOfDay ?? this.hourOfDay,
      weekday: weekday ?? this.weekday,
      opensBefore: opensBefore ?? this.opensBefore,
      minutesSinceLastOpen: minutesSinceLastOpen ?? this.minutesSinceLastOpen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (pauseSeconds.present) {
      map['pause_seconds'] = Variable<int>(pauseSeconds.value);
    }
    if (riskScore.present) {
      map['risk_score'] = Variable<double>(riskScore.value);
    }
    if (hourOfDay.present) {
      map['hour_of_day'] = Variable<int>(hourOfDay.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (opensBefore.present) {
      map['opens_before'] = Variable<int>(opensBefore.value);
    }
    if (minutesSinceLastOpen.present) {
      map['minutes_since_last_open'] =
          Variable<int>(minutesSinceLastOpen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterventionEventsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('reason: $reason, ')
          ..write('outcome: $outcome, ')
          ..write('pauseSeconds: $pauseSeconds, ')
          ..write('riskScore: $riskScore, ')
          ..write('hourOfDay: $hourOfDay, ')
          ..write('weekday: $weekday, ')
          ..write('opensBefore: $opensBefore, ')
          ..write('minutesSinceLastOpen: $minutesSinceLastOpen')
          ..write(')'))
        .toString();
  }
}

class $DailyCheckinsTable extends DailyCheckins
    with TableInfo<$DailyCheckinsTable, DailyCheckin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyCheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
      'day', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _focusScoreMeta =
      const VerificationMeta('focusScore');
  @override
  late final GeneratedColumn<int> focusScore = GeneratedColumn<int>(
      'focus_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [day, focusScore, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_checkins';
  @override
  VerificationContext validateIntegrity(Insertable<DailyCheckin> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('focus_score')) {
      context.handle(
          _focusScoreMeta,
          focusScore.isAcceptableOrUnknown(
              data['focus_score']!, _focusScoreMeta));
    } else if (isInserting) {
      context.missing(_focusScoreMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  DailyCheckin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyCheckin(
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}day'])!,
      focusScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}focus_score'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
    );
  }

  @override
  $DailyCheckinsTable createAlias(String alias) {
    return $DailyCheckinsTable(attachedDatabase, alias);
  }
}

class DailyCheckin extends DataClass implements Insertable<DailyCheckin> {
  final DateTime day;
  final int focusScore;
  final DateTime recordedAt;
  const DailyCheckin(
      {required this.day, required this.focusScore, required this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['focus_score'] = Variable<int>(focusScore);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  DailyCheckinsCompanion toCompanion(bool nullToAbsent) {
    return DailyCheckinsCompanion(
      day: Value(day),
      focusScore: Value(focusScore),
      recordedAt: Value(recordedAt),
    );
  }

  factory DailyCheckin.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyCheckin(
      day: serializer.fromJson<DateTime>(json['day']),
      focusScore: serializer.fromJson<int>(json['focusScore']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'focusScore': serializer.toJson<int>(focusScore),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  DailyCheckin copyWith(
          {DateTime? day, int? focusScore, DateTime? recordedAt}) =>
      DailyCheckin(
        day: day ?? this.day,
        focusScore: focusScore ?? this.focusScore,
        recordedAt: recordedAt ?? this.recordedAt,
      );
  DailyCheckin copyWithCompanion(DailyCheckinsCompanion data) {
    return DailyCheckin(
      day: data.day.present ? data.day.value : this.day,
      focusScore:
          data.focusScore.present ? data.focusScore.value : this.focusScore,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckin(')
          ..write('day: $day, ')
          ..write('focusScore: $focusScore, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, focusScore, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyCheckin &&
          other.day == this.day &&
          other.focusScore == this.focusScore &&
          other.recordedAt == this.recordedAt);
}

class DailyCheckinsCompanion extends UpdateCompanion<DailyCheckin> {
  final Value<DateTime> day;
  final Value<int> focusScore;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const DailyCheckinsCompanion({
    this.day = const Value.absent(),
    this.focusScore = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyCheckinsCompanion.insert({
    required DateTime day,
    required int focusScore,
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  })  : day = Value(day),
        focusScore = Value(focusScore),
        recordedAt = Value(recordedAt);
  static Insertable<DailyCheckin> custom({
    Expression<DateTime>? day,
    Expression<int>? focusScore,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (focusScore != null) 'focus_score': focusScore,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyCheckinsCompanion copyWith(
      {Value<DateTime>? day,
      Value<int>? focusScore,
      Value<DateTime>? recordedAt,
      Value<int>? rowid}) {
    return DailyCheckinsCompanion(
      day: day ?? this.day,
      focusScore: focusScore ?? this.focusScore,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (focusScore.present) {
      map['focus_score'] = Variable<int>(focusScore.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyCheckinsCompanion(')
          ..write('day: $day, ')
          ..write('focusScore: $focusScore, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsageDailyTable extends AppUsageDaily
    with TableInfo<$AppUsageDailyTable, AppUsageDailyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsageDailyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
      'day', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _minutesMeta =
      const VerificationMeta('minutes');
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
      'minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [day, packageName, minutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_usage_daily';
  @override
  VerificationContext validateIntegrity(Insertable<AppUsageDailyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(_minutesMeta,
          minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta));
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day, packageName};
  @override
  AppUsageDailyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUsageDailyData(
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}day'])!,
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
      minutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}minutes'])!,
    );
  }

  @override
  $AppUsageDailyTable createAlias(String alias) {
    return $AppUsageDailyTable(attachedDatabase, alias);
  }
}

class AppUsageDailyData extends DataClass
    implements Insertable<AppUsageDailyData> {
  final DateTime day;
  final String packageName;
  final int minutes;
  const AppUsageDailyData(
      {required this.day, required this.packageName, required this.minutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['package_name'] = Variable<String>(packageName);
    map['minutes'] = Variable<int>(minutes);
    return map;
  }

  AppUsageDailyCompanion toCompanion(bool nullToAbsent) {
    return AppUsageDailyCompanion(
      day: Value(day),
      packageName: Value(packageName),
      minutes: Value(minutes),
    );
  }

  factory AppUsageDailyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUsageDailyData(
      day: serializer.fromJson<DateTime>(json['day']),
      packageName: serializer.fromJson<String>(json['packageName']),
      minutes: serializer.fromJson<int>(json['minutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'packageName': serializer.toJson<String>(packageName),
      'minutes': serializer.toJson<int>(minutes),
    };
  }

  AppUsageDailyData copyWith(
          {DateTime? day, String? packageName, int? minutes}) =>
      AppUsageDailyData(
        day: day ?? this.day,
        packageName: packageName ?? this.packageName,
        minutes: minutes ?? this.minutes,
      );
  AppUsageDailyData copyWithCompanion(AppUsageDailyCompanion data) {
    return AppUsageDailyData(
      day: data.day.present ? data.day.value : this.day,
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageDailyData(')
          ..write('day: $day, ')
          ..write('packageName: $packageName, ')
          ..write('minutes: $minutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, packageName, minutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUsageDailyData &&
          other.day == this.day &&
          other.packageName == this.packageName &&
          other.minutes == this.minutes);
}

class AppUsageDailyCompanion extends UpdateCompanion<AppUsageDailyData> {
  final Value<DateTime> day;
  final Value<String> packageName;
  final Value<int> minutes;
  final Value<int> rowid;
  const AppUsageDailyCompanion({
    this.day = const Value.absent(),
    this.packageName = const Value.absent(),
    this.minutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsageDailyCompanion.insert({
    required DateTime day,
    required String packageName,
    required int minutes,
    this.rowid = const Value.absent(),
  })  : day = Value(day),
        packageName = Value(packageName),
        minutes = Value(minutes);
  static Insertable<AppUsageDailyData> custom({
    Expression<DateTime>? day,
    Expression<String>? packageName,
    Expression<int>? minutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (packageName != null) 'package_name': packageName,
      if (minutes != null) 'minutes': minutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsageDailyCompanion copyWith(
      {Value<DateTime>? day,
      Value<String>? packageName,
      Value<int>? minutes,
      Value<int>? rowid}) {
    return AppUsageDailyCompanion(
      day: day ?? this.day,
      packageName: packageName ?? this.packageName,
      minutes: minutes ?? this.minutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageDailyCompanion(')
          ..write('day: $day, ')
          ..write('packageName: $packageName, ')
          ..write('minutes: $minutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelWeightsTable extends ModelWeights
    with TableInfo<$ModelWeightsTable, ModelWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureMeta =
      const VerificationMeta('feature');
  @override
  late final GeneratedColumn<String> feature = GeneratedColumn<String>(
      'feature', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 60),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _trainedOnMeta =
      const VerificationMeta('trainedOn');
  @override
  late final GeneratedColumn<int> trainedOn = GeneratedColumn<int>(
      'trained_on', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [feature, weight, trainedOn, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_weights';
  @override
  VerificationContext validateIntegrity(Insertable<ModelWeight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature')) {
      context.handle(_featureMeta,
          feature.isAcceptableOrUnknown(data['feature']!, _featureMeta));
    } else if (isInserting) {
      context.missing(_featureMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('trained_on')) {
      context.handle(_trainedOnMeta,
          trainedOn.isAcceptableOrUnknown(data['trained_on']!, _trainedOnMeta));
    } else if (isInserting) {
      context.missing(_trainedOnMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feature};
  @override
  ModelWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelWeight(
      feature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feature'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      trainedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}trained_on'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ModelWeightsTable createAlias(String alias) {
    return $ModelWeightsTable(attachedDatabase, alias);
  }
}

class ModelWeight extends DataClass implements Insertable<ModelWeight> {
  final String feature;
  final double weight;
  final int trainedOn;
  final DateTime updatedAt;
  const ModelWeight(
      {required this.feature,
      required this.weight,
      required this.trainedOn,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature'] = Variable<String>(feature);
    map['weight'] = Variable<double>(weight);
    map['trained_on'] = Variable<int>(trainedOn);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ModelWeightsCompanion toCompanion(bool nullToAbsent) {
    return ModelWeightsCompanion(
      feature: Value(feature),
      weight: Value(weight),
      trainedOn: Value(trainedOn),
      updatedAt: Value(updatedAt),
    );
  }

  factory ModelWeight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelWeight(
      feature: serializer.fromJson<String>(json['feature']),
      weight: serializer.fromJson<double>(json['weight']),
      trainedOn: serializer.fromJson<int>(json['trainedOn']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feature': serializer.toJson<String>(feature),
      'weight': serializer.toJson<double>(weight),
      'trainedOn': serializer.toJson<int>(trainedOn),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ModelWeight copyWith(
          {String? feature,
          double? weight,
          int? trainedOn,
          DateTime? updatedAt}) =>
      ModelWeight(
        feature: feature ?? this.feature,
        weight: weight ?? this.weight,
        trainedOn: trainedOn ?? this.trainedOn,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ModelWeight copyWithCompanion(ModelWeightsCompanion data) {
    return ModelWeight(
      feature: data.feature.present ? data.feature.value : this.feature,
      weight: data.weight.present ? data.weight.value : this.weight,
      trainedOn: data.trainedOn.present ? data.trainedOn.value : this.trainedOn,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelWeight(')
          ..write('feature: $feature, ')
          ..write('weight: $weight, ')
          ..write('trainedOn: $trainedOn, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(feature, weight, trainedOn, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelWeight &&
          other.feature == this.feature &&
          other.weight == this.weight &&
          other.trainedOn == this.trainedOn &&
          other.updatedAt == this.updatedAt);
}

class ModelWeightsCompanion extends UpdateCompanion<ModelWeight> {
  final Value<String> feature;
  final Value<double> weight;
  final Value<int> trainedOn;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ModelWeightsCompanion({
    this.feature = const Value.absent(),
    this.weight = const Value.absent(),
    this.trainedOn = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelWeightsCompanion.insert({
    required String feature,
    required double weight,
    required int trainedOn,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : feature = Value(feature),
        weight = Value(weight),
        trainedOn = Value(trainedOn),
        updatedAt = Value(updatedAt);
  static Insertable<ModelWeight> custom({
    Expression<String>? feature,
    Expression<double>? weight,
    Expression<int>? trainedOn,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feature != null) 'feature': feature,
      if (weight != null) 'weight': weight,
      if (trainedOn != null) 'trained_on': trainedOn,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelWeightsCompanion copyWith(
      {Value<String>? feature,
      Value<double>? weight,
      Value<int>? trainedOn,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ModelWeightsCompanion(
      feature: feature ?? this.feature,
      weight: weight ?? this.weight,
      trainedOn: trainedOn ?? this.trainedOn,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feature.present) {
      map['feature'] = Variable<String>(feature.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (trainedOn.present) {
      map['trained_on'] = Variable<int>(trainedOn.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelWeightsCompanion(')
          ..write('feature: $feature, ')
          ..write('weight: $weight, ')
          ..write('trainedOn: $trainedOn, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InterventionEventsTable interventionEvents =
      $InterventionEventsTable(this);
  late final $DailyCheckinsTable dailyCheckins = $DailyCheckinsTable(this);
  late final $AppUsageDailyTable appUsageDaily = $AppUsageDailyTable(this);
  late final $ModelWeightsTable modelWeights = $ModelWeightsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [interventionEvents, dailyCheckins, appUsageDaily, modelWeights];
}

typedef $$InterventionEventsTableCreateCompanionBuilder
    = InterventionEventsCompanion Function({
  Value<int> id,
  required DateTime timestamp,
  required String packageName,
  required String appName,
  required String reason,
  required String outcome,
  required int pauseSeconds,
  Value<double?> riskScore,
  required int hourOfDay,
  required int weekday,
  required int opensBefore,
  Value<int?> minutesSinceLastOpen,
});
typedef $$InterventionEventsTableUpdateCompanionBuilder
    = InterventionEventsCompanion Function({
  Value<int> id,
  Value<DateTime> timestamp,
  Value<String> packageName,
  Value<String> appName,
  Value<String> reason,
  Value<String> outcome,
  Value<int> pauseSeconds,
  Value<double?> riskScore,
  Value<int> hourOfDay,
  Value<int> weekday,
  Value<int> opensBefore,
  Value<int?> minutesSinceLastOpen,
});

class $$InterventionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $InterventionEventsTable> {
  $$InterventionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pauseSeconds => $composableBuilder(
      column: $table.pauseSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get riskScore => $composableBuilder(
      column: $table.riskScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hourOfDay => $composableBuilder(
      column: $table.hourOfDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get opensBefore => $composableBuilder(
      column: $table.opensBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutesSinceLastOpen => $composableBuilder(
      column: $table.minutesSinceLastOpen,
      builder: (column) => ColumnFilters(column));
}

class $$InterventionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $InterventionEventsTable> {
  $$InterventionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcome => $composableBuilder(
      column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pauseSeconds => $composableBuilder(
      column: $table.pauseSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get riskScore => $composableBuilder(
      column: $table.riskScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hourOfDay => $composableBuilder(
      column: $table.hourOfDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get opensBefore => $composableBuilder(
      column: $table.opensBefore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutesSinceLastOpen => $composableBuilder(
      column: $table.minutesSinceLastOpen,
      builder: (column) => ColumnOrderings(column));
}

class $$InterventionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterventionEventsTable> {
  $$InterventionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get pauseSeconds => $composableBuilder(
      column: $table.pauseSeconds, builder: (column) => column);

  GeneratedColumn<double> get riskScore =>
      $composableBuilder(column: $table.riskScore, builder: (column) => column);

  GeneratedColumn<int> get hourOfDay =>
      $composableBuilder(column: $table.hourOfDay, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get opensBefore => $composableBuilder(
      column: $table.opensBefore, builder: (column) => column);

  GeneratedColumn<int> get minutesSinceLastOpen => $composableBuilder(
      column: $table.minutesSinceLastOpen, builder: (column) => column);
}

class $$InterventionEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InterventionEventsTable,
    InterventionEvent,
    $$InterventionEventsTableFilterComposer,
    $$InterventionEventsTableOrderingComposer,
    $$InterventionEventsTableAnnotationComposer,
    $$InterventionEventsTableCreateCompanionBuilder,
    $$InterventionEventsTableUpdateCompanionBuilder,
    (
      InterventionEvent,
      BaseReferences<_$AppDatabase, $InterventionEventsTable, InterventionEvent>
    ),
    InterventionEvent,
    PrefetchHooks Function()> {
  $$InterventionEventsTableTableManager(
      _$AppDatabase db, $InterventionEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterventionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterventionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterventionEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> packageName = const Value.absent(),
            Value<String> appName = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<String> outcome = const Value.absent(),
            Value<int> pauseSeconds = const Value.absent(),
            Value<double?> riskScore = const Value.absent(),
            Value<int> hourOfDay = const Value.absent(),
            Value<int> weekday = const Value.absent(),
            Value<int> opensBefore = const Value.absent(),
            Value<int?> minutesSinceLastOpen = const Value.absent(),
          }) =>
              InterventionEventsCompanion(
            id: id,
            timestamp: timestamp,
            packageName: packageName,
            appName: appName,
            reason: reason,
            outcome: outcome,
            pauseSeconds: pauseSeconds,
            riskScore: riskScore,
            hourOfDay: hourOfDay,
            weekday: weekday,
            opensBefore: opensBefore,
            minutesSinceLastOpen: minutesSinceLastOpen,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime timestamp,
            required String packageName,
            required String appName,
            required String reason,
            required String outcome,
            required int pauseSeconds,
            Value<double?> riskScore = const Value.absent(),
            required int hourOfDay,
            required int weekday,
            required int opensBefore,
            Value<int?> minutesSinceLastOpen = const Value.absent(),
          }) =>
              InterventionEventsCompanion.insert(
            id: id,
            timestamp: timestamp,
            packageName: packageName,
            appName: appName,
            reason: reason,
            outcome: outcome,
            pauseSeconds: pauseSeconds,
            riskScore: riskScore,
            hourOfDay: hourOfDay,
            weekday: weekday,
            opensBefore: opensBefore,
            minutesSinceLastOpen: minutesSinceLastOpen,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$InterventionEventsTable, InterventionEvent>(
                        table),
                    BaseReferences<_$AppDatabase, $InterventionEventsTable,
                        InterventionEvent>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InterventionEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InterventionEventsTable,
    InterventionEvent,
    $$InterventionEventsTableFilterComposer,
    $$InterventionEventsTableOrderingComposer,
    $$InterventionEventsTableAnnotationComposer,
    $$InterventionEventsTableCreateCompanionBuilder,
    $$InterventionEventsTableUpdateCompanionBuilder,
    (
      InterventionEvent,
      BaseReferences<_$AppDatabase, $InterventionEventsTable, InterventionEvent>
    ),
    InterventionEvent,
    PrefetchHooks Function()>;
typedef $$DailyCheckinsTableCreateCompanionBuilder = DailyCheckinsCompanion
    Function({
  required DateTime day,
  required int focusScore,
  required DateTime recordedAt,
  Value<int> rowid,
});
typedef $$DailyCheckinsTableUpdateCompanionBuilder = DailyCheckinsCompanion
    Function({
  Value<DateTime> day,
  Value<int> focusScore,
  Value<DateTime> recordedAt,
  Value<int> rowid,
});

class $$DailyCheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyCheckinsTable> {
  $$DailyCheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusScore => $composableBuilder(
      column: $table.focusScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));
}

class $$DailyCheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyCheckinsTable> {
  $$DailyCheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusScore => $composableBuilder(
      column: $table.focusScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));
}

class $$DailyCheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyCheckinsTable> {
  $$DailyCheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get focusScore => $composableBuilder(
      column: $table.focusScore, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);
}

class $$DailyCheckinsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyCheckinsTable,
    DailyCheckin,
    $$DailyCheckinsTableFilterComposer,
    $$DailyCheckinsTableOrderingComposer,
    $$DailyCheckinsTableAnnotationComposer,
    $$DailyCheckinsTableCreateCompanionBuilder,
    $$DailyCheckinsTableUpdateCompanionBuilder,
    (
      DailyCheckin,
      BaseReferences<_$AppDatabase, $DailyCheckinsTable, DailyCheckin>
    ),
    DailyCheckin,
    PrefetchHooks Function()> {
  $$DailyCheckinsTableTableManager(_$AppDatabase db, $DailyCheckinsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyCheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyCheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyCheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> day = const Value.absent(),
            Value<int> focusScore = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyCheckinsCompanion(
            day: day,
            focusScore: focusScore,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime day,
            required int focusScore,
            required DateTime recordedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyCheckinsCompanion.insert(
            day: day,
            focusScore: focusScore,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DailyCheckinsTable, DailyCheckin>(table),
                    BaseReferences<_$AppDatabase, $DailyCheckinsTable,
                        DailyCheckin>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyCheckinsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyCheckinsTable,
    DailyCheckin,
    $$DailyCheckinsTableFilterComposer,
    $$DailyCheckinsTableOrderingComposer,
    $$DailyCheckinsTableAnnotationComposer,
    $$DailyCheckinsTableCreateCompanionBuilder,
    $$DailyCheckinsTableUpdateCompanionBuilder,
    (
      DailyCheckin,
      BaseReferences<_$AppDatabase, $DailyCheckinsTable, DailyCheckin>
    ),
    DailyCheckin,
    PrefetchHooks Function()>;
typedef $$AppUsageDailyTableCreateCompanionBuilder = AppUsageDailyCompanion
    Function({
  required DateTime day,
  required String packageName,
  required int minutes,
  Value<int> rowid,
});
typedef $$AppUsageDailyTableUpdateCompanionBuilder = AppUsageDailyCompanion
    Function({
  Value<DateTime> day,
  Value<String> packageName,
  Value<int> minutes,
  Value<int> rowid,
});

class $$AppUsageDailyTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsageDailyTable> {
  $$AppUsageDailyTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutes => $composableBuilder(
      column: $table.minutes, builder: (column) => ColumnFilters(column));
}

class $$AppUsageDailyTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsageDailyTable> {
  $$AppUsageDailyTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutes => $composableBuilder(
      column: $table.minutes, builder: (column) => ColumnOrderings(column));
}

class $$AppUsageDailyTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsageDailyTable> {
  $$AppUsageDailyTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);
}

class $$AppUsageDailyTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppUsageDailyTable,
    AppUsageDailyData,
    $$AppUsageDailyTableFilterComposer,
    $$AppUsageDailyTableOrderingComposer,
    $$AppUsageDailyTableAnnotationComposer,
    $$AppUsageDailyTableCreateCompanionBuilder,
    $$AppUsageDailyTableUpdateCompanionBuilder,
    (
      AppUsageDailyData,
      BaseReferences<_$AppDatabase, $AppUsageDailyTable, AppUsageDailyData>
    ),
    AppUsageDailyData,
    PrefetchHooks Function()> {
  $$AppUsageDailyTableTableManager(_$AppDatabase db, $AppUsageDailyTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsageDailyTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsageDailyTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsageDailyTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> day = const Value.absent(),
            Value<String> packageName = const Value.absent(),
            Value<int> minutes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppUsageDailyCompanion(
            day: day,
            packageName: packageName,
            minutes: minutes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime day,
            required String packageName,
            required int minutes,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppUsageDailyCompanion.insert(
            day: day,
            packageName: packageName,
            minutes: minutes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppUsageDailyTable, AppUsageDailyData>(table),
                    BaseReferences<_$AppDatabase, $AppUsageDailyTable,
                        AppUsageDailyData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppUsageDailyTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppUsageDailyTable,
    AppUsageDailyData,
    $$AppUsageDailyTableFilterComposer,
    $$AppUsageDailyTableOrderingComposer,
    $$AppUsageDailyTableAnnotationComposer,
    $$AppUsageDailyTableCreateCompanionBuilder,
    $$AppUsageDailyTableUpdateCompanionBuilder,
    (
      AppUsageDailyData,
      BaseReferences<_$AppDatabase, $AppUsageDailyTable, AppUsageDailyData>
    ),
    AppUsageDailyData,
    PrefetchHooks Function()>;
typedef $$ModelWeightsTableCreateCompanionBuilder = ModelWeightsCompanion
    Function({
  required String feature,
  required double weight,
  required int trainedOn,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ModelWeightsTableUpdateCompanionBuilder = ModelWeightsCompanion
    Function({
  Value<String> feature,
  Value<double> weight,
  Value<int> trainedOn,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ModelWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $ModelWeightsTable> {
  $$ModelWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get trainedOn => $composableBuilder(
      column: $table.trainedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ModelWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $ModelWeightsTable> {
  $$ModelWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feature => $composableBuilder(
      column: $table.feature, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get trainedOn => $composableBuilder(
      column: $table.trainedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ModelWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModelWeightsTable> {
  $$ModelWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feature =>
      $composableBuilder(column: $table.feature, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get trainedOn =>
      $composableBuilder(column: $table.trainedOn, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ModelWeightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModelWeightsTable,
    ModelWeight,
    $$ModelWeightsTableFilterComposer,
    $$ModelWeightsTableOrderingComposer,
    $$ModelWeightsTableAnnotationComposer,
    $$ModelWeightsTableCreateCompanionBuilder,
    $$ModelWeightsTableUpdateCompanionBuilder,
    (
      ModelWeight,
      BaseReferences<_$AppDatabase, $ModelWeightsTable, ModelWeight>
    ),
    ModelWeight,
    PrefetchHooks Function()> {
  $$ModelWeightsTableTableManager(_$AppDatabase db, $ModelWeightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> feature = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<int> trainedOn = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelWeightsCompanion(
            feature: feature,
            weight: weight,
            trainedOn: trainedOn,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String feature,
            required double weight,
            required int trainedOn,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ModelWeightsCompanion.insert(
            feature: feature,
            weight: weight,
            trainedOn: trainedOn,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ModelWeightsTable, ModelWeight>(table),
                    BaseReferences<_$AppDatabase, $ModelWeightsTable,
                        ModelWeight>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModelWeightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ModelWeightsTable,
    ModelWeight,
    $$ModelWeightsTableFilterComposer,
    $$ModelWeightsTableOrderingComposer,
    $$ModelWeightsTableAnnotationComposer,
    $$ModelWeightsTableCreateCompanionBuilder,
    $$ModelWeightsTableUpdateCompanionBuilder,
    (
      ModelWeight,
      BaseReferences<_$AppDatabase, $ModelWeightsTable, ModelWeight>
    ),
    ModelWeight,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InterventionEventsTableTableManager get interventionEvents =>
      $$InterventionEventsTableTableManager(_db, _db.interventionEvents);
  $$DailyCheckinsTableTableManager get dailyCheckins =>
      $$DailyCheckinsTableTableManager(_db, _db.dailyCheckins);
  $$AppUsageDailyTableTableManager get appUsageDaily =>
      $$AppUsageDailyTableTableManager(_db, _db.appUsageDaily);
  $$ModelWeightsTableTableManager get modelWeights =>
      $$ModelWeightsTableTableManager(_db, _db.modelWeights);
}

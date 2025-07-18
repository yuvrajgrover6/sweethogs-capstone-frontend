import 'package:flutter/material.dart';

class PatientModel {
  final String? id; // MongoDB _id
  final int encounterId;
  final int patientNumber;
  final String? race;
  final String gender;
  final String age;
  final String? weight;
  final int admissionTypeId;
  final int dischargeDispositionId;
  final int admissionSourceId;
  final int timeInHospital;
  final String? payerCode;
  final String? medicalSpecialty;
  final int numLabProcedures;
  final int numProcedures;
  final int numMedications;
  final int numberOutpatient;
  final int numberEmergency;
  final int numberInpatient;
  final String diagnosis1;
  final String? diagnosis2;
  final String? diagnosis3;
  final int numberDiagnoses;
  final String maxGluSerum;
  final String a1cResult;
  final String metformin;
  final String? repaglinide;
  final String? nateglinide;
  final String? chlorpropamide;
  final String? glimepiride;
  final String? acetohexamide;
  final String? glipizide;
  final String? glyburide;
  final String? tolbutamide;
  final String? pioglitazone;
  final String? rosiglitazone;
  final String? acarbose;
  final String? miglitol;
  final String? troglitazone;
  final String? tolazamide;
  final String? examide;
  final String? citoglipton;
  final String insulin;
  final String? glyburideMetformin;
  final String? glipizideMetformin;
  final String? glimepiridePioglitazone;
  final String? metforminRosiglitazone;
  final String? metforminPioglitazone;
  final String change;
  final String diabetesMed;
  final String? readmitted;
  final String createdBy;
  final String updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PatientModel({
    this.id,
    required this.encounterId,
    required this.patientNumber,
    this.race,
    required this.gender,
    required this.age,
    this.weight,
    required this.admissionTypeId,
    required this.dischargeDispositionId,
    required this.admissionSourceId,
    required this.timeInHospital,
    this.payerCode,
    this.medicalSpecialty,
    required this.numLabProcedures,
    required this.numProcedures,
    required this.numMedications,
    required this.numberOutpatient,
    required this.numberEmergency,
    required this.numberInpatient,
    required this.diagnosis1,
    this.diagnosis2,
    this.diagnosis3,
    required this.numberDiagnoses,
    required this.maxGluSerum,
    required this.a1cResult,
    required this.metformin,
    this.repaglinide,
    this.nateglinide,
    this.chlorpropamide,
    this.glimepiride,
    this.acetohexamide,
    this.glipizide,
    this.glyburide,
    this.tolbutamide,
    this.pioglitazone,
    this.rosiglitazone,
    this.acarbose,
    this.miglitol,
    this.troglitazone,
    this.tolazamide,
    this.examide,
    this.citoglipton,
    required this.insulin,
    this.glyburideMetformin,
    this.glipizideMetformin,
    this.glimepiridePioglitazone,
    this.metforminRosiglitazone,
    this.metforminPioglitazone,
    required this.change,
    required this.diabetesMed,
    this.readmitted,
    required this.createdBy,
    required this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  // Computed properties for better display
  String get displayAge =>
      age.replaceAll('[', '').replaceAll(')', '').replaceAll(',', '-');

  String get patientId => 'P${patientNumber.toString().padLeft(8, '0')}';

  String get encounterIdDisplay => 'E${encounterId.toString().padLeft(7, '0')}';

  String get riskLevel {
    // Simple risk calculation based on multiple factors
    int risk = 0;

    // Age factor
    if (age.contains('70-80') ||
        age.contains('80-90') ||
        age.contains('90-100'))
      risk += 3;
    else if (age.contains('60-70') || age.contains('50-60'))
      risk += 2;
    else if (age.contains('40-50') || age.contains('30-40'))
      risk += 1;

    // Hospital stay factor
    if (timeInHospital > 10)
      risk += 3;
    else if (timeInHospital > 5)
      risk += 2;
    else if (timeInHospital > 2)
      risk += 1;

    // Medication changes
    if (change == 'Ch') risk += 2;

    // Previous admissions
    if (numberInpatient > 0) risk += 1;
    if (numberEmergency > 0) risk += 1;

    // Diabetes medication
    if (diabetesMed == 'Yes') risk += 1;

    // Lab procedures (complexity indicator)
    if (numLabProcedures > 50)
      risk += 2;
    else if (numLabProcedures > 25)
      risk += 1;

    if (risk >= 8) return 'High';
    if (risk >= 5) return 'Medium';
    if (risk >= 2) return 'Low';
    return 'Very Low';
  }

  Color get riskColor {
    switch (riskLevel) {
      case 'High':
        return const Color(0xFFDC2626); // Red
      case 'Medium':
        return const Color(0xFFF59E0B); // Orange
      case 'Low':
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  bool get isHighRisk => riskLevel == 'High' || riskLevel == 'Medium';

  String get primaryDiagnosis {
    if (diagnosis1 != '?') return diagnosis1;
    if (diagnosis2 != null && diagnosis2! != '?') return diagnosis2!;
    if (diagnosis3 != null && diagnosis3! != '?') return diagnosis3!;
    return 'Unknown';
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['_id'] ?? json['id'],
      encounterId: json['encounter_id'] ?? 0,
      patientNumber: json['patient_nbr'] ?? 0,
      race: json['race'],
      gender: json['gender'] ?? '',
      age: json['age'] ?? '',
      weight: json['weight'],
      admissionTypeId: json['admission_type_id'] ?? 0,
      dischargeDispositionId: json['discharge_disposition_id'] ?? 0,
      admissionSourceId: json['admission_source_id'] ?? 0,
      timeInHospital: json['time_in_hospital'] ?? 0,
      payerCode: json['payer_code'],
      medicalSpecialty: json['medical_specialty'],
      numLabProcedures: json['num_lab_procedures'] ?? 0,
      numProcedures: json['num_procedures'] ?? 0,
      numMedications: json['num_medications'] ?? 0,
      numberOutpatient: json['number_outpatient'] ?? 0,
      numberEmergency: json['number_emergency'] ?? 0,
      numberInpatient: json['number_inpatient'] ?? 0,
      diagnosis1: json['diag_1'] ?? '',
      diagnosis2: json['diag_2'],
      diagnosis3: json['diag_3'],
      numberDiagnoses: json['number_diagnoses'] ?? 0,
      maxGluSerum: json['max_glu_serum'] ?? '',
      a1cResult: json['A1Cresult'] ?? '',
      metformin: json['metformin'] ?? '',
      repaglinide: json['repaglinide'],
      nateglinide: json['nateglinide'],
      chlorpropamide: json['chlorpropamide'],
      glimepiride: json['glimepiride'],
      acetohexamide: json['acetohexamide'],
      glipizide: json['glipizide'],
      glyburide: json['glyburide'],
      tolbutamide: json['tolbutamide'],
      pioglitazone: json['pioglitazone'],
      rosiglitazone: json['rosiglitazone'],
      acarbose: json['acarbose'],
      miglitol: json['miglitol'],
      troglitazone: json['troglitazone'],
      tolazamide: json['tolazamide'],
      examide: json['examide'],
      citoglipton: json['citoglipton'],
      insulin: json['insulin'] ?? '',
      glyburideMetformin: json['glyburide_metformin'],
      glipizideMetformin: json['glipizide_metformin'],
      glimepiridePioglitazone: json['glimepiride_pioglitazone'],
      metforminRosiglitazone: json['metformin_rosiglitazone'],
      metforminPioglitazone: json['metformin_pioglitazone'],
      change: json['change'] ?? '',
      diabetesMed: json['diabetesMed'] ?? '',
      readmitted: json['readmitted'],
      createdBy: json['created_by'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  /// Factory constructor for API response format
  /// This handles the API format from the Patient Management API
  factory PatientModel.fromApiJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int _safeInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    // Helper function to safely convert to string
    String _safeString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    return PatientModel(
      id: json['_id'] ?? json['id'],
      encounterId: _safeInt(json['encounter_id'] ?? json['id'], 0),
      patientNumber: _safeInt(json['patient_nbr'] ?? json['patientNumber'], 0),
      race: json['race'],
      gender: _safeString(json['gender'], 'Unknown'),
      age: _safeString(json['age'], '[0-10)'),
      weight: json['weight'],
      admissionTypeId: _safeInt(json['admission_type_id'] ?? json['admissionTypeId'], 1),
      dischargeDispositionId: _safeInt(json['discharge_disposition_id'] ?? json['dischargeDispositionId'], 1),
      admissionSourceId: _safeInt(json['admission_source_id'] ?? json['admissionSourceId'], 7),
      timeInHospital: _safeInt(json['time_in_hospital'] ?? json['timeInHospital'], 1),
      payerCode: json['payer_code'] ?? json['payerCode'],
      medicalSpecialty: json['medical_specialty'] ?? json['medicalSpecialty'],
      numLabProcedures: _safeInt(json['num_lab_procedures'] ?? json['numLabProcedures'], 0),
      numProcedures: _safeInt(json['num_procedures'] ?? json['numProcedures'], 0),
      numMedications: _safeInt(json['num_medications'] ?? json['numMedications'], 0),
      numberOutpatient: _safeInt(json['number_outpatient'] ?? json['numberOutpatient'], 0),
      numberEmergency: _safeInt(json['number_emergency'] ?? json['numberEmergency'], 0),
      numberInpatient: _safeInt(json['number_inpatient'] ?? json['numberInpatient'], 0),
      diagnosis1: _safeString(json['diag_1'] ?? json['diagnosis1'], '?'),
      diagnosis2: json['diag_2'] ?? json['diagnosis2'],
      diagnosis3: json['diag_3'] ?? json['diagnosis3'],
      numberDiagnoses: _safeInt(json['number_diagnoses'] ?? json['numberDiagnoses'], 0),
      maxGluSerum: _safeString(json['max_glu_serum'] ?? json['maxGluSerum'], 'None'),
      a1cResult: _safeString(json['A1Cresult'] ?? json['a1cResult'], 'None'),
      metformin: _safeString(json['metformin'], 'No'),
      repaglinide: json['repaglinide'],
      nateglinide: json['nateglinide'],
      chlorpropamide: json['chlorpropamide'],
      glimepiride: json['glimepiride'],
      acetohexamide: json['acetohexamide'],
      glipizide: json['glipizide'],
      glyburide: json['glyburide'],
      tolbutamide: json['tolbutamide'],
      pioglitazone: json['pioglitazone'],
      rosiglitazone: json['rosiglitazone'],
      acarbose: json['acarbose'],
      miglitol: json['miglitol'],
      troglitazone: json['troglitazone'],
      tolazamide: json['tolazamide'],
      examide: json['examide'],
      citoglipton: json['citoglipton'],
      insulin: _safeString(json['insulin'], 'No'),
      glyburideMetformin: json['glyburide_metformin'] ?? json['glyburide-metformin'] ?? json['glyburideMetformin'],
      glipizideMetformin: json['glipizide_metformin'] ?? json['glipizide-metformin'] ?? json['glipizideMetformin'],
      glimepiridePioglitazone: json['glimepiride_pioglitazone'] ?? json['glimepiride-pioglitazone'] ?? json['glimepiridePioglitazone'],
      metforminRosiglitazone: json['metformin_rosiglitazone'] ?? json['metformin-rosiglitazone'] ?? json['metforminRosiglitazone'],
      metforminPioglitazone: json['metformin_pioglitazone'] ?? json['metformin-pioglitazone'] ?? json['metforminPioglitazone'],
      change: _safeString(json['change'], 'No'),
      diabetesMed: _safeString(json['diabetesMed'], 'No'),
      readmitted: json['readmitted'],
      createdBy: _safeString(json['created_by'] ?? json['createdBy'], ''),
      updatedBy: _safeString(json['updated_by'] ?? json['updatedBy'], ''),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'encounter_id': encounterId,
      'patient_nbr': patientNumber,
      'race': race,
      'gender': gender,
      'age': age,
      'weight': weight,
      'admission_type_id': admissionTypeId,
      'discharge_disposition_id': dischargeDispositionId,
      'admission_source_id': admissionSourceId,
      'time_in_hospital': timeInHospital,
      'payer_code': payerCode,
      'medical_specialty': medicalSpecialty,
      'num_lab_procedures': numLabProcedures,
      'num_procedures': numProcedures,
      'num_medications': numMedications,
      'number_outpatient': numberOutpatient,
      'number_emergency': numberEmergency,
      'number_inpatient': numberInpatient,
      'diag_1': diagnosis1,
      'diag_2': diagnosis2,
      'diag_3': diagnosis3,
      'number_diagnoses': numberDiagnoses,
      'max_glu_serum': maxGluSerum,
      'A1Cresult': a1cResult,
      'metformin': metformin,
      'repaglinide': repaglinide,
      'nateglinide': nateglinide,
      'chlorpropamide': chlorpropamide,
      'glimepiride': glimepiride,
      'acetohexamide': acetohexamide,
      'glipizide': glipizide,
      'glyburide': glyburide,
      'tolbutamide': tolbutamide,
      'pioglitazone': pioglitazone,
      'rosiglitazone': rosiglitazone,
      'acarbose': acarbose,
      'miglitol': miglitol,
      'troglitazone': troglitazone,
      'tolazamide': tolazamide,
      'examide': examide,
      'citoglipton': citoglipton,
      'insulin': insulin,
      'glyburide_metformin': glyburideMetformin,
      'glipizide_metformin': glipizideMetformin,
      'glimepiride_pioglitazone': glimepiridePioglitazone,
      'metformin_rosiglitazone': metforminRosiglitazone,
      'metformin_pioglitazone': metforminPioglitazone,
      'change': change,
      'diabetesMed': diabetesMed,
      'readmitted': readmitted,
      'created_by': createdBy,
      'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Convert to API format for readmission prediction
  /// This format matches the new API specification exactly
  Map<String, dynamic> toApiJson() {
    return {
      'age': age,
      'gender': gender,
      'time_in_hospital': timeInHospital,
      'admission_type': admissionTypeId,
      'discharge_disposition': dischargeDispositionId,
      'admission_source': admissionSourceId,
      'num_medications': numMedications,
      'num_lab_procedures': numLabProcedures,
      'num_procedures': numProcedures,
      'number_diagnoses': numberDiagnoses,
      'number_inpatient': numberInpatient,
      'number_outpatient': numberOutpatient,
      'number_emergency': numberEmergency,
      'diabetesMed': diabetesMed.isEmpty ? 'No' : diabetesMed,
      'change': change.isEmpty ? 'No' : change,
      'A1Cresult': a1cResult.isEmpty ? 'None' : a1cResult,
      'max_glu_serum': maxGluSerum.isEmpty ? 'None' : maxGluSerum,
      'insulin': insulin.isEmpty ? 'No' : insulin,
      'metformin': metformin.isEmpty ? 'No' : metformin,
      'diagnosis_1': diagnosis1.isEmpty ? '250' : diagnosis1,
    };
  }

  /// Validate required fields for the new API
  List<String> validateApiFields() {
    List<String> errors = [];

    if (age.isEmpty) {
      errors.add('Age is required');
    }
    if (gender.isEmpty) {
      errors.add('Gender is required');
    }
    if (timeInHospital <= 0) {
      errors.add('Time in hospital must be greater than 0 (current: $timeInHospital)');
    }
    if (admissionTypeId <= 0) {
      errors.add('Admission type is required (current: $admissionTypeId)');
    }
    if (dischargeDispositionId <= 0) {
      errors.add('Discharge disposition is required (current: $dischargeDispositionId)');
    }
    if (admissionSourceId <= 0) {
      errors.add('Admission source is required (current: $admissionSourceId)');
    }
    if (numMedications < 0) {
      errors.add('Number of medications cannot be negative (current: $numMedications)');
    }
    if (numLabProcedures < 0) {
      errors.add('Number of lab procedures cannot be negative (current: $numLabProcedures)');
    }
    if (numProcedures < 0) {
      errors.add('Number of procedures cannot be negative (current: $numProcedures)');
    }
    if (numberDiagnoses <= 0) {
      errors.add('Number of diagnoses must be greater than 0 (current: $numberDiagnoses)');
    }
    if (numberInpatient < 0) {
      errors.add('Number of inpatient visits cannot be negative (current: $numberInpatient)');
    }
    if (numberOutpatient < 0) {
      errors.add('Number of outpatient visits cannot be negative (current: $numberOutpatient)');
    }
    if (numberEmergency < 0) {
      errors.add('Number of emergency visits cannot be negative (current: $numberEmergency)');
    }

    return errors;
  }
}

// Pagination model for patients
class PatientPagination {
  final List<PatientModel> patients;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  const PatientPagination({
    required this.patients,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  int get startIndex => (currentPage - 1) * itemsPerPage + 1;
  int get endIndex => (currentPage * itemsPerPage).clamp(0, totalItems);
}

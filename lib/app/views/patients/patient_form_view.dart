import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/patients_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/patient_model.dart';
import '../../utils/custom_snackbar.dart';

class PatientFormView extends StatefulWidget {
  const PatientFormView({super.key});

  @override
  State<PatientFormView> createState() => _PatientFormViewState();
}

class _PatientFormViewState extends State<PatientFormView> {
  final _formKey = GlobalKey<FormState>();
  final PatientsController _patientsController = Get.find<PatientsController>();
  
  // Form data
  final _patientNumberController = TextEditingController();
  final _encounterIdController = TextEditingController();
  final _timeInHospitalController = TextEditingController();
  final _admissionTypeIdController = TextEditingController();
  final _dischargeDispositionIdController = TextEditingController();
  final _admissionSourceIdController = TextEditingController();
  final _payerCodeController = TextEditingController();
  final _medicalSpecialtyController = TextEditingController();
  final _numLabProceduresController = TextEditingController();
  final _numProceduresController = TextEditingController();
  final _numMedicationsController = TextEditingController();
  final _numberOutpatientController = TextEditingController();
  final _numberEmergencyController = TextEditingController();
  final _numberInpatientController = TextEditingController();
  final _diagnosis1Controller = TextEditingController();
  final _diagnosis2Controller = TextEditingController();
  final _diagnosis3Controller = TextEditingController();
  final _numberDiagnosesController = TextEditingController();

  // Dropdown selections
  String _selectedRace = 'Caucasian';
  String _selectedGender = 'Male';
  String _selectedAge = '[0-10)';
  String _selectedWeight = '?';
  String _selectedMaxGluSerum = 'None';
  String _selectedA1cResult = 'None';
  String _selectedMetformin = 'No';
  String _selectedRepaglinide = 'No';
  String _selectedNateglinide = 'No';
  String _selectedChlorpropamide = 'No';
  String _selectedGlimepiride = 'No';
  String _selectedAcetohexamide = 'No';
  String _selectedGlipizide = 'No';
  String _selectedGlyburide = 'No';
  String _selectedTolbutamide = 'No';
  String _selectedPioglitazone = 'No';
  String _selectedRosiglitazone = 'No';
  String _selectedAcarbose = 'No';
  String _selectedMiglitol = 'No';
  String _selectedTroglitazone = 'No';
  String _selectedTolazamide = 'No';
  String _selectedExamide = 'No';
  String _selectedCitoglipton = 'No';
  String _selectedInsulin = 'No';
  String _selectedGlyburideMetformin = 'No';
  String _selectedGlipizideMetformin = 'No';
  String _selectedGlimepiridePioglitazone = 'No';
  String _selectedMetforminRosiglitazone = 'No';
  String _selectedMetforminPioglitazone = 'No';
  String _selectedChange = 'No';
  String _selectedDiabetesMed = 'No';
  String _selectedReadmitted = 'NO';

  // Get data from arguments
  PatientModel? _existingPatient;
  bool _isEditMode = false;

  // Dropdown options
  final List<String> _raceOptions = ['Caucasian', 'AfricanAmerican', 'Asian', 'Hispanic', 'Other', '?'];
  final List<String> _genderOptions = ['Male', 'Female'];
  final List<String> _ageOptions = [
    '[0-10)', '[10-20)', '[20-30)', '[30-40)', '[40-50)', 
    '[50-60)', '[60-70)', '[70-80)', '[80-90)', '[90-100)'
  ];
  final List<String> _weightOptions = ['?', '[0-25)', '[25-50)', '[50-75)', '[75-100)', '[100-125)', '[125-150)', '[150-175)', '[175-200)', '>200'];
  final List<String> _labResultOptions = ['None', 'Normal', '>200', '>300', 'Norm'];
  final List<String> _medicationOptions = ['No', 'Up', 'Down', 'Steady'];
  final List<String> _changeOptions = ['No', 'Ch'];
  final List<String> _yesNoOptions = ['No', 'Yes'];
  final List<String> _readmittedOptions = ['NO', '<30', '>30'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Check if we're editing an existing patient
    final arguments = Get.arguments;
    if (arguments != null && arguments is PatientModel) {
      _existingPatient = arguments;
      _isEditMode = true;
      _populateFormWithExistingData();
    }
  }

  void _populateFormWithExistingData() {
    if (_existingPatient == null) return;

    final patient = _existingPatient!;
    
    _patientNumberController.text = patient.patientNumber.toString();
    _encounterIdController.text = patient.encounterId.toString();
    _selectedAge = patient.age;
    _selectedWeight = patient.weight ?? '?';
    _timeInHospitalController.text = patient.timeInHospital.toString();
    _admissionTypeIdController.text = patient.admissionTypeId.toString();
    _dischargeDispositionIdController.text = patient.dischargeDispositionId.toString();
    _admissionSourceIdController.text = patient.admissionSourceId.toString();
    _payerCodeController.text = patient.payerCode ?? '';
    _medicalSpecialtyController.text = patient.medicalSpecialty ?? '';
    _numLabProceduresController.text = patient.numLabProcedures.toString();
    _numProceduresController.text = patient.numProcedures.toString();
    _numMedicationsController.text = patient.numMedications.toString();
    _numberOutpatientController.text = patient.numberOutpatient.toString();
    _numberEmergencyController.text = patient.numberEmergency.toString();
    _numberInpatientController.text = patient.numberInpatient.toString();
    _diagnosis1Controller.text = patient.diagnosis1;
    _diagnosis2Controller.text = patient.diagnosis2 ?? '';
    _diagnosis3Controller.text = patient.diagnosis3 ?? '';
    _numberDiagnosesController.text = patient.numberDiagnoses.toString();

    _selectedRace = patient.race != null && patient.race!.isNotEmpty ? patient.race! : 'Caucasian';
    _selectedGender = patient.gender.isNotEmpty ? patient.gender : 'Male';
    _selectedMaxGluSerum = patient.maxGluSerum.isNotEmpty ? patient.maxGluSerum : 'None';
    _selectedA1cResult = patient.a1cResult.isNotEmpty ? patient.a1cResult : 'None';
    _selectedMetformin = patient.metformin.isNotEmpty ? patient.metformin : 'No';
    _selectedRepaglinide = patient.repaglinide != null && patient.repaglinide!.isNotEmpty ? patient.repaglinide! : 'No';
    _selectedNateglinide = patient.nateglinide != null && patient.nateglinide!.isNotEmpty ? patient.nateglinide! : 'No';
    _selectedChlorpropamide = patient.chlorpropamide != null && patient.chlorpropamide!.isNotEmpty ? patient.chlorpropamide! : 'No';
    _selectedGlimepiride = patient.glimepiride != null && patient.glimepiride!.isNotEmpty ? patient.glimepiride! : 'No';
    _selectedAcetohexamide = patient.acetohexamide != null && patient.acetohexamide!.isNotEmpty ? patient.acetohexamide! : 'No';
    _selectedGlipizide = patient.glipizide != null && patient.glipizide!.isNotEmpty ? patient.glipizide! : 'No';
    _selectedGlyburide = patient.glyburide != null && patient.glyburide!.isNotEmpty ? patient.glyburide! : 'No';
    _selectedTolbutamide = patient.tolbutamide != null && patient.tolbutamide!.isNotEmpty ? patient.tolbutamide! : 'No';
    _selectedPioglitazone = patient.pioglitazone != null && patient.pioglitazone!.isNotEmpty ? patient.pioglitazone! : 'No';
    _selectedRosiglitazone = patient.rosiglitazone != null && patient.rosiglitazone!.isNotEmpty ? patient.rosiglitazone! : 'No';
    _selectedAcarbose = patient.acarbose != null && patient.acarbose!.isNotEmpty ? patient.acarbose! : 'No';
    _selectedMiglitol = patient.miglitol != null && patient.miglitol!.isNotEmpty ? patient.miglitol! : 'No';
    _selectedTroglitazone = patient.troglitazone != null && patient.troglitazone!.isNotEmpty ? patient.troglitazone! : 'No';
    _selectedTolazamide = patient.tolazamide != null && patient.tolazamide!.isNotEmpty ? patient.tolazamide! : 'No';
    _selectedExamide = patient.examide != null && patient.examide!.isNotEmpty ? patient.examide! : 'No';
    _selectedCitoglipton = patient.citoglipton != null && patient.citoglipton!.isNotEmpty ? patient.citoglipton! : 'No';
    _selectedInsulin = patient.insulin.isNotEmpty ? patient.insulin : 'No';
    _selectedGlyburideMetformin = patient.glyburideMetformin != null && patient.glyburideMetformin!.isNotEmpty ? patient.glyburideMetformin! : 'No';
    _selectedGlipizideMetformin = patient.glipizideMetformin != null && patient.glipizideMetformin!.isNotEmpty ? patient.glipizideMetformin! : 'No';
    _selectedGlimepiridePioglitazone = patient.glimepiridePioglitazone != null && patient.glimepiridePioglitazone!.isNotEmpty ? patient.glimepiridePioglitazone! : 'No';
    _selectedMetforminRosiglitazone = patient.metforminRosiglitazone != null && patient.metforminRosiglitazone!.isNotEmpty ? patient.metforminRosiglitazone! : 'No';
    _selectedMetforminPioglitazone = patient.metforminPioglitazone != null && patient.metforminPioglitazone!.isNotEmpty ? patient.metforminPioglitazone! : 'No';
    _selectedChange = patient.change.isNotEmpty ? patient.change : 'No';
    _selectedDiabetesMed = patient.diabetesMed.isNotEmpty ? patient.diabetesMed : 'No';
    _selectedReadmitted = patient.readmitted != null && patient.readmitted!.isNotEmpty ? patient.readmitted! : 'NO';
  }

  @override
  void dispose() {
    _patientNumberController.dispose();
    _encounterIdController.dispose();
    _timeInHospitalController.dispose();
    _admissionTypeIdController.dispose();
    _dischargeDispositionIdController.dispose();
    _admissionSourceIdController.dispose();
    _payerCodeController.dispose();
    _medicalSpecialtyController.dispose();
    _numLabProceduresController.dispose();
    _numProceduresController.dispose();
    _numMedicationsController.dispose();
    _numberOutpatientController.dispose();
    _numberEmergencyController.dispose();
    _numberInpatientController.dispose();
    _diagnosis1Controller.dispose();
    _diagnosis2Controller.dispose();
    _diagnosis3Controller.dispose();
    _numberDiagnosesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Modern App Bar
            _buildModernAppBar(context),
            
            // Form Content
            Expanded(
              child: _buildResponsiveForm(context, isDesktop, isTablet, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Back Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0098B9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0098B9)),
                onPressed: () => Get.back(),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title and Breadcrumb
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Patient' : 'Create New Patient',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.home, size: 16, color: Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      const Text(
                        'Home',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF6B7280)),
                      const Text(
                        'Patients',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                      ),
                      const Icon(Icons.chevron_right, size: 16, color: Color(0xFF6B7280)),
                      Text(
                        _isEditMode ? 'Edit' : 'Create',
                        style: const TextStyle(color: Color(0xFF0098B9), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            if (_isEditMode) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _showDeleteDialog,
                  tooltip: 'Delete Patient',
                ),
              ),
              const SizedBox(width: 12),
            ],
            
            // Save Button
            Obx(() => Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0098B9), Color(0xFF00ACC1)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0098B9).withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _patientsController.isLoading ? null : _savePatient,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_patientsController.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(Icons.save, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isEditMode ? 'Update Patient' : 'Create Patient',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveForm(BuildContext context, bool isDesktop, bool isTablet, bool isMobile) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : double.infinity,
            ),
            child: Column(
              children: [
                if (isDesktop)
                  _buildDesktopLayout()
                else if (isTablet)
                  _buildTabletLayout()
                else
                  _buildMobileLayout(),
                
                const SizedBox(height: 32),
                
                // Action Buttons (Mobile Only - Desktop has them in app bar)
                if (isMobile) _buildMobileActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildModernSectionCard(
                    'Basic Information',
                    Icons.person,
                    [
                      Row(
                        children: [
                          Expanded(child: _buildModernNumberField('Patient Number', _patientNumberController, required: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernNumberField('Encounter ID', _encounterIdController, required: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernDropdownField('Race', _selectedRace, _raceOptions, (value) => setState(() => _selectedRace = value!))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernDropdownField('Gender', _selectedGender, _genderOptions, (value) => setState(() => _selectedGender = value!))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernDropdownField('Age', _selectedAge, _ageOptions, (value) { setState(() { _selectedAge = value!; }); })),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernDropdownField('Weight', _selectedWeight, _weightOptions, (value) { setState(() { _selectedWeight = value!; }); })),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildModernSectionCard(
                    'Admission Information',
                    Icons.local_hospital,
                    [
                      Row(
                        children: [
                          Expanded(child: _buildModernNumberField('Time in Hospital', _timeInHospitalController, required: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernNumberField('Admission Type ID', _admissionTypeIdController, required: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernNumberField('Discharge Disposition ID', _dischargeDispositionIdController, required: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernNumberField('Admission Source ID', _admissionSourceIdController, required: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernTextField('Payer Code', _payerCodeController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernTextField('Medical Specialty', _medicalSpecialtyController)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Right Column
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildModernSectionCard(
                    'Medical Procedures & Visits',
                    Icons.medical_services,
                    [
                      Row(
                        children: [
                          Expanded(child: _buildModernNumberField('Lab Procedures', _numLabProceduresController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernNumberField('Procedures', _numProceduresController)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernNumberField('Medications', _numMedicationsController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernNumberField('Outpatient Visits', _numberOutpatientController)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildModernNumberField('Emergency Visits', _numberEmergencyController)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildModernNumberField('Inpatient Visits', _numberInpatientController)),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildModernSectionCard(
                    'Diagnoses',
                    Icons.assignment,
                    [
                      _buildModernTextField('Primary Diagnosis', _diagnosis1Controller),
                      _buildModernTextField('Secondary Diagnosis', _diagnosis2Controller),
                      _buildModernTextField('Tertiary Diagnosis', _diagnosis3Controller),
                      _buildModernNumberField('Number of Diagnoses', _numberDiagnosesController),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Lab Results and Treatment Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernSectionCard(
                'Lab Results',
                Icons.science,
                [
                  _buildModernDropdownField('Max Glucose Serum', _selectedMaxGluSerum, _labResultOptions, (value) => setState(() => _selectedMaxGluSerum = value!)),
                  _buildModernDropdownField('A1C Result', _selectedA1cResult, _labResultOptions, (value) => setState(() => _selectedA1cResult = value!)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildModernSectionCard(
                'Treatment & Outcome',
                Icons.local_pharmacy,
                [
                  _buildModernDropdownField('Medication Change', _selectedChange, _changeOptions, (value) => setState(() => _selectedChange = value!)),
                  _buildModernDropdownField('Diabetes Medication', _selectedDiabetesMed, _yesNoOptions, (value) => setState(() => _selectedDiabetesMed = value!)),
                  _buildModernDropdownField('Readmitted', _selectedReadmitted, _readmittedOptions, (value) => setState(() => _selectedReadmitted = value!)),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Primary and Secondary Medications Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernSectionCard(
                'Primary Medications',
                Icons.medication,
                [
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Metformin', _selectedMetformin, _medicationOptions, (value) => setState(() => _selectedMetformin = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Insulin', _selectedInsulin, _medicationOptions, (value) => setState(() => _selectedInsulin = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Repaglinide', _selectedRepaglinide, _medicationOptions, (value) => setState(() => _selectedRepaglinide = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Nateglinide', _selectedNateglinide, _medicationOptions, (value) => setState(() => _selectedNateglinide = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Glimepiride', _selectedGlimepiride, _medicationOptions, (value) => setState(() => _selectedGlimepiride = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Glipizide', _selectedGlipizide, _medicationOptions, (value) => setState(() => _selectedGlipizide = value!))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildModernSectionCard(
                'Secondary Medications',
                Icons.medication_liquid,
                [
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Chlorpropamide', _selectedChlorpropamide, _medicationOptions, (value) => setState(() => _selectedChlorpropamide = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Acetohexamide', _selectedAcetohexamide, _medicationOptions, (value) => setState(() => _selectedAcetohexamide = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Glyburide', _selectedGlyburide, _medicationOptions, (value) => setState(() => _selectedGlyburide = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Tolbutamide', _selectedTolbutamide, _medicationOptions, (value) => setState(() => _selectedTolbutamide = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Pioglitazone', _selectedPioglitazone, _medicationOptions, (value) => setState(() => _selectedPioglitazone = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Rosiglitazone', _selectedRosiglitazone, _medicationOptions, (value) => setState(() => _selectedRosiglitazone = value!))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Additional and Combination Medications Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernSectionCard(
                'Additional Medications',
                Icons.vaccines,
                [
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Acarbose', _selectedAcarbose, _medicationOptions, (value) => setState(() => _selectedAcarbose = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Miglitol', _selectedMiglitol, _medicationOptions, (value) => setState(() => _selectedMiglitol = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Troglitazone', _selectedTroglitazone, _medicationOptions, (value) => setState(() => _selectedTroglitazone = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Tolazamide', _selectedTolazamide, _medicationOptions, (value) => setState(() => _selectedTolazamide = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Examide', _selectedExamide, _medicationOptions, (value) => setState(() => _selectedExamide = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Citoglipton', _selectedCitoglipton, _medicationOptions, (value) => setState(() => _selectedCitoglipton = value!))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildModernSectionCard(
                'Combination Medications',
                Icons.api,
                [
                  _buildModernDropdownField('Glyburide-Metformin', _selectedGlyburideMetformin, _medicationOptions, (value) => setState(() => _selectedGlyburideMetformin = value!)),
                  _buildModernDropdownField('Glipizide-Metformin', _selectedGlipizideMetformin, _medicationOptions, (value) => setState(() => _selectedGlipizideMetformin = value!)),
                  _buildModernDropdownField('Glimepiride-Pioglitazone', _selectedGlimepiridePioglitazone, _medicationOptions, (value) => setState(() => _selectedGlimepiridePioglitazone = value!)),
                  _buildModernDropdownField('Metformin-Rosiglitazone', _selectedMetforminRosiglitazone, _medicationOptions, (value) => setState(() => _selectedMetforminRosiglitazone = value!)),
                  _buildModernDropdownField('Metformin-Pioglitazone', _selectedMetforminPioglitazone, _medicationOptions, (value) => setState(() => _selectedMetforminPioglitazone = value!)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildModernSectionCard(
                'Basic Information',
                Icons.person,
                [
                  Row(
                    children: [
                      Expanded(child: _buildModernNumberField('Patient Number', _patientNumberController, required: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernNumberField('Encounter ID', _encounterIdController, required: true)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Race', _selectedRace, _raceOptions, (value) => setState(() => _selectedRace = value!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Gender', _selectedGender, _genderOptions, (value) => setState(() => _selectedGender = value!))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _buildModernDropdownField('Age', _selectedAge, _ageOptions, (value) { setState(() { _selectedAge = value!; }); })),
                      const SizedBox(width: 16),
                      Expanded(child: _buildModernDropdownField('Weight', _selectedWeight, _weightOptions, (value) { setState(() { _selectedWeight = value!; }); })),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildModernSectionCard(
                'Admission Information',
                Icons.local_hospital,
                [
                  _buildModernNumberField('Time in Hospital', _timeInHospitalController, required: true),
                  _buildModernNumberField('Admission Type ID', _admissionTypeIdController, required: true),
                  _buildModernNumberField('Discharge Disposition ID', _dischargeDispositionIdController, required: true),
                  _buildModernNumberField('Admission Source ID', _admissionSourceIdController, required: true),
                  _buildModernTextField('Payer Code', _payerCodeController),
                  _buildModernTextField('Medical Specialty', _medicalSpecialtyController),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Medical Procedures & Visits',
          Icons.medical_services,
          [
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 32) / 3;
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernNumberField('Lab Procedures', _numLabProceduresController),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernNumberField('Procedures', _numProceduresController),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernNumberField('Medications', _numMedicationsController),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernNumberField('Outpatient Visits', _numberOutpatientController),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernNumberField('Emergency Visits', _numberEmergencyController),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernNumberField('Inpatient Visits', _numberInpatientController),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Diagnoses',
          Icons.assignment,
          [
            Row(
              children: [
                Expanded(child: _buildModernTextField('Primary Diagnosis', _diagnosis1Controller)),
                const SizedBox(width: 16),
                Expanded(child: _buildModernTextField('Secondary Diagnosis', _diagnosis2Controller)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildModernTextField('Tertiary Diagnosis', _diagnosis3Controller)),
                const SizedBox(width: 16),
                Expanded(child: _buildModernNumberField('Number of Diagnoses', _numberDiagnosesController)),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Lab Results',
          Icons.science,
          [
            Row(
              children: [
                Expanded(child: _buildModernDropdownField('Max Glucose Serum', _selectedMaxGluSerum, _labResultOptions, (value) => setState(() => _selectedMaxGluSerum = value!))),
                const SizedBox(width: 16),
                Expanded(child: _buildModernDropdownField('A1C Result', _selectedA1cResult, _labResultOptions, (value) => setState(() => _selectedA1cResult = value!))),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Primary Medications',
          Icons.medication,
          [
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 32) / 3; // 32 = 2 * 16px spacing
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Metformin', _selectedMetformin, _medicationOptions, (value) => setState(() => _selectedMetformin = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Repaglinide', _selectedRepaglinide, _medicationOptions, (value) => setState(() => _selectedRepaglinide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Nateglinide', _selectedNateglinide, _medicationOptions, (value) => setState(() => _selectedNateglinide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Chlorpropamide', _selectedChlorpropamide, _medicationOptions, (value) => setState(() => _selectedChlorpropamide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Glimepiride', _selectedGlimepiride, _medicationOptions, (value) => setState(() => _selectedGlimepiride = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Acetohexamide', _selectedAcetohexamide, _medicationOptions, (value) => setState(() => _selectedAcetohexamide = value!)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Secondary Medications',
          Icons.medical_services,
          [
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 32) / 3;
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Glipizide', _selectedGlipizide, _medicationOptions, (value) => setState(() => _selectedGlipizide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Glyburide', _selectedGlyburide, _medicationOptions, (value) => setState(() => _selectedGlyburide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Tolbutamide', _selectedTolbutamide, _medicationOptions, (value) => setState(() => _selectedTolbutamide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Pioglitazone', _selectedPioglitazone, _medicationOptions, (value) => setState(() => _selectedPioglitazone = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Rosiglitazone', _selectedRosiglitazone, _medicationOptions, (value) => setState(() => _selectedRosiglitazone = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Acarbose', _selectedAcarbose, _medicationOptions, (value) => setState(() => _selectedAcarbose = value!)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Additional Medications',
          Icons.local_pharmacy,
          [
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 32) / 3;
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Miglitol', _selectedMiglitol, _medicationOptions, (value) => setState(() => _selectedMiglitol = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Troglitazone', _selectedTroglitazone, _medicationOptions, (value) => setState(() => _selectedTroglitazone = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Tolazamide', _selectedTolazamide, _medicationOptions, (value) => setState(() => _selectedTolazamide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Examide', _selectedExamide, _medicationOptions, (value) => setState(() => _selectedExamide = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Citoglipton', _selectedCitoglipton, _medicationOptions, (value) => setState(() => _selectedCitoglipton = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Insulin', _selectedInsulin, _medicationOptions, (value) => setState(() => _selectedInsulin = value!)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Combination Medications',
          Icons.medication_liquid,
          [
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 16) / 2; // 2 columns for combination meds
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Glyburide-Metformin', _selectedGlyburideMetformin, _medicationOptions, (value) => setState(() => _selectedGlyburideMetformin = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Glipizide-Metformin', _selectedGlipizideMetformin, _medicationOptions, (value) => setState(() => _selectedGlipizideMetformin = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Glimepiride-Pioglitazone', _selectedGlimepiridePioglitazone, _medicationOptions, (value) => setState(() => _selectedGlimepiridePioglitazone = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Metformin-Rosiglitazone', _selectedMetforminRosiglitazone, _medicationOptions, (value) => setState(() => _selectedMetforminRosiglitazone = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Metformin-Pioglitazone', _selectedMetforminPioglitazone, _medicationOptions, (value) => setState(() => _selectedMetforminPioglitazone = value!)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Treatment & Outcome',
          Icons.assignment_turned_in,
          [
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final itemWidth = (availableWidth - 32) / 3;
                
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Medication Change', _selectedChange, _changeOptions, (value) => setState(() => _selectedChange = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Diabetes Medication', _selectedDiabetesMed, _yesNoOptions, (value) => setState(() => _selectedDiabetesMed = value!)),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildModernDropdownField('Readmitted', _selectedReadmitted, _readmittedOptions, (value) => setState(() => _selectedReadmitted = value!)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildModernSectionCard(
          'Basic Information',
          Icons.person,
          [
            _buildModernNumberField('Patient Number', _patientNumberController, required: true),
            _buildModernNumberField('Encounter ID', _encounterIdController, required: true),
            _buildModernDropdownField('Race', _selectedRace, _raceOptions, (value) => setState(() => _selectedRace = value!)),
            _buildModernDropdownField('Gender', _selectedGender, _genderOptions, (value) => setState(() => _selectedGender = value!)),
            _buildModernDropdownField('Age', _selectedAge, _ageOptions, (value) { setState(() { _selectedAge = value!; }); }),
            _buildModernDropdownField('Weight', _selectedWeight, _weightOptions, (value) { setState(() { _selectedWeight = value!; }); }),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Admission Information',
          Icons.local_hospital,
          [
            _buildModernNumberField('Time in Hospital', _timeInHospitalController, required: true),
            _buildModernNumberField('Admission Type ID', _admissionTypeIdController, required: true),
            _buildModernNumberField('Discharge Disposition ID', _dischargeDispositionIdController, required: true),
            _buildModernNumberField('Admission Source ID', _admissionSourceIdController, required: true),
            _buildModernTextField('Payer Code', _payerCodeController),
            _buildModernTextField('Medical Specialty', _medicalSpecialtyController),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Medical Procedures & Visits',
          Icons.medical_services,
          [
            _buildModernNumberField('Lab Procedures', _numLabProceduresController),
            _buildModernNumberField('Procedures', _numProceduresController),
            _buildModernNumberField('Medications', _numMedicationsController),
            _buildModernNumberField('Outpatient Visits', _numberOutpatientController),
            _buildModernNumberField('Emergency Visits', _numberEmergencyController),
            _buildModernNumberField('Inpatient Visits', _numberInpatientController),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Diagnoses',
          Icons.assignment,
          [
            _buildModernTextField('Primary Diagnosis', _diagnosis1Controller),
            _buildModernTextField('Secondary Diagnosis', _diagnosis2Controller),
            _buildModernTextField('Tertiary Diagnosis', _diagnosis3Controller),
            _buildModernNumberField('Number of Diagnoses', _numberDiagnosesController),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Lab Results',
          Icons.science,
          [
            _buildModernDropdownField('Max Glucose Serum', _selectedMaxGluSerum, _labResultOptions, (value) => setState(() => _selectedMaxGluSerum = value!)),
            _buildModernDropdownField('A1C Result', _selectedA1cResult, _labResultOptions, (value) => setState(() => _selectedA1cResult = value!)),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Medications',
          Icons.medication,
          [
            _buildModernDropdownField('Metformin', _selectedMetformin, _medicationOptions, (value) => setState(() => _selectedMetformin = value!)),
            _buildModernDropdownField('Repaglinide', _selectedRepaglinide, _medicationOptions, (value) => setState(() => _selectedRepaglinide = value!)),
            _buildModernDropdownField('Nateglinide', _selectedNateglinide, _medicationOptions, (value) => setState(() => _selectedNateglinide = value!)),
            _buildModernDropdownField('Chlorpropamide', _selectedChlorpropamide, _medicationOptions, (value) => setState(() => _selectedChlorpropamide = value!)),
            _buildModernDropdownField('Glimepiride', _selectedGlimepiride, _medicationOptions, (value) => setState(() => _selectedGlimepiride = value!)),
            _buildModernDropdownField('Acetohexamide', _selectedAcetohexamide, _medicationOptions, (value) => setState(() => _selectedAcetohexamide = value!)),
            _buildModernDropdownField('Glipizide', _selectedGlipizide, _medicationOptions, (value) => setState(() => _selectedGlipizide = value!)),
            _buildModernDropdownField('Glyburide', _selectedGlyburide, _medicationOptions, (value) => setState(() => _selectedGlyburide = value!)),
            _buildModernDropdownField('Tolbutamide', _selectedTolbutamide, _medicationOptions, (value) => setState(() => _selectedTolbutamide = value!)),
            _buildModernDropdownField('Pioglitazone', _selectedPioglitazone, _medicationOptions, (value) => setState(() => _selectedPioglitazone = value!)),
            _buildModernDropdownField('Rosiglitazone', _selectedRosiglitazone, _medicationOptions, (value) => setState(() => _selectedRosiglitazone = value!)),
            _buildModernDropdownField('Acarbose', _selectedAcarbose, _medicationOptions, (value) => setState(() => _selectedAcarbose = value!)),
            _buildModernDropdownField('Miglitol', _selectedMiglitol, _medicationOptions, (value) => setState(() => _selectedMiglitol = value!)),
            _buildModernDropdownField('Troglitazone', _selectedTroglitazone, _medicationOptions, (value) => setState(() => _selectedTroglitazone = value!)),
            _buildModernDropdownField('Tolazamide', _selectedTolazamide, _medicationOptions, (value) => setState(() => _selectedTolazamide = value!)),
            _buildModernDropdownField('Examide', _selectedExamide, _medicationOptions, (value) => setState(() => _selectedExamide = value!)),
            _buildModernDropdownField('Citoglipton', _selectedCitoglipton, _medicationOptions, (value) => setState(() => _selectedCitoglipton = value!)),
            _buildModernDropdownField('Insulin', _selectedInsulin, _medicationOptions, (value) => setState(() => _selectedInsulin = value!)),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Combination Medications',
          Icons.medication_liquid,
          [
            _buildModernDropdownField('Glyburide-Metformin', _selectedGlyburideMetformin, _medicationOptions, (value) => setState(() => _selectedGlyburideMetformin = value!)),
            _buildModernDropdownField('Glipizide-Metformin', _selectedGlipizideMetformin, _medicationOptions, (value) => setState(() => _selectedGlipizideMetformin = value!)),
            _buildModernDropdownField('Glimepiride-Pioglitazone', _selectedGlimepiridePioglitazone, _medicationOptions, (value) => setState(() => _selectedGlimepiridePioglitazone = value!)),
            _buildModernDropdownField('Metformin-Rosiglitazone', _selectedMetforminRosiglitazone, _medicationOptions, (value) => setState(() => _selectedMetforminRosiglitazone = value!)),
            _buildModernDropdownField('Metformin-Pioglitazone', _selectedMetforminPioglitazone, _medicationOptions, (value) => setState(() => _selectedMetforminPioglitazone = value!)),
          ],
        ),
        
        const SizedBox(height: 24),
        
        _buildModernSectionCard(
          'Treatment & Outcome',
          Icons.local_pharmacy,
          [
            _buildModernDropdownField('Medication Change', _selectedChange, _changeOptions, (value) => setState(() => _selectedChange = value!)),
            _buildModernDropdownField('Diabetes Medication', _selectedDiabetesMed, _yesNoOptions, (value) => setState(() => _selectedDiabetesMed = value!)),
            _buildModernDropdownField('Readmitted', _selectedReadmitted, _readmittedOptions, (value) => setState(() => _selectedReadmitted = value!)),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileActionButtons() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.back(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0098B9), Color(0xFF00ACC1)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0098B9).withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _patientsController.isLoading ? null : _savePatient,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _patientsController.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isEditMode ? 'Update Patient' : 'Create Patient',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildModernSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0098B9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF0098B9),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children.map((child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0098B9), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: required ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildModernNumberField(String label, TextEditingController controller, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0098B9), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: required ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildModernDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            color: const Color(0xFFF9FAFB),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: Colors.white,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
            ),
            isExpanded: true, // This ensures the dropdown takes full width
          ),
        ),
      ],
    );
  }

  void _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.warning('Please fill in all required fields correctly');
      return;
    }

    // Get current user for createdBy/updatedBy fields
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser?.id.toString() ?? 'unknown';

    final patient = PatientModel(
      encounterId: int.tryParse(_encounterIdController.text) ?? 0,
      patientNumber: int.tryParse(_patientNumberController.text) ?? 0,
      race: _selectedRace.isEmpty ? null : _selectedRace,
      gender: _selectedGender,
      age: _selectedAge,
      weight: _selectedWeight == '?' ? null : _selectedWeight,
      admissionTypeId: int.tryParse(_admissionTypeIdController.text) ?? 1,
      dischargeDispositionId: int.tryParse(_dischargeDispositionIdController.text) ?? 1,
      admissionSourceId: int.tryParse(_admissionSourceIdController.text) ?? 7,
      timeInHospital: int.tryParse(_timeInHospitalController.text) ?? 1,
      payerCode: _payerCodeController.text.isEmpty ? null : _payerCodeController.text,
      medicalSpecialty: _medicalSpecialtyController.text.isEmpty ? null : _medicalSpecialtyController.text,
      numLabProcedures: int.tryParse(_numLabProceduresController.text) ?? 0,
      numProcedures: int.tryParse(_numProceduresController.text) ?? 0,
      numMedications: int.tryParse(_numMedicationsController.text) ?? 0,
      numberOutpatient: int.tryParse(_numberOutpatientController.text) ?? 0,
      numberEmergency: int.tryParse(_numberEmergencyController.text) ?? 0,
      numberInpatient: int.tryParse(_numberInpatientController.text) ?? 0,
      diagnosis1: _diagnosis1Controller.text,
      diagnosis2: _diagnosis2Controller.text.isEmpty ? null : _diagnosis2Controller.text,
      diagnosis3: _diagnosis3Controller.text.isEmpty ? null : _diagnosis3Controller.text,
      numberDiagnoses: int.tryParse(_numberDiagnosesController.text) ?? 1,
      maxGluSerum: _selectedMaxGluSerum,
      a1cResult: _selectedA1cResult,
      metformin: _selectedMetformin,
      repaglinide: _selectedRepaglinide.isEmpty ? null : _selectedRepaglinide,
      nateglinide: _selectedNateglinide.isEmpty ? null : _selectedNateglinide,
      chlorpropamide: _selectedChlorpropamide.isEmpty ? null : _selectedChlorpropamide,
      glimepiride: _selectedGlimepiride.isEmpty ? null : _selectedGlimepiride,
      acetohexamide: _selectedAcetohexamide.isEmpty ? null : _selectedAcetohexamide,
      glipizide: _selectedGlipizide.isEmpty ? null : _selectedGlipizide,
      glyburide: _selectedGlyburide.isEmpty ? null : _selectedGlyburide,
      tolbutamide: _selectedTolbutamide.isEmpty ? null : _selectedTolbutamide,
      pioglitazone: _selectedPioglitazone.isEmpty ? null : _selectedPioglitazone,
      rosiglitazone: _selectedRosiglitazone.isEmpty ? null : _selectedRosiglitazone,
      acarbose: _selectedAcarbose.isEmpty ? null : _selectedAcarbose,
      miglitol: _selectedMiglitol.isEmpty ? null : _selectedMiglitol,
      troglitazone: _selectedTroglitazone.isEmpty ? null : _selectedTroglitazone,
      tolazamide: _selectedTolazamide.isEmpty ? null : _selectedTolazamide,
      examide: _selectedExamide.isEmpty ? null : _selectedExamide,
      citoglipton: _selectedCitoglipton.isEmpty ? null : _selectedCitoglipton,
      insulin: _selectedInsulin,
      glyburideMetformin: _selectedGlyburideMetformin.isEmpty ? null : _selectedGlyburideMetformin,
      glipizideMetformin: _selectedGlipizideMetformin.isEmpty ? null : _selectedGlipizideMetformin,
      glimepiridePioglitazone: _selectedGlimepiridePioglitazone.isEmpty ? null : _selectedGlimepiridePioglitazone,
      metforminRosiglitazone: _selectedMetforminRosiglitazone.isEmpty ? null : _selectedMetforminRosiglitazone,
      metforminPioglitazone: _selectedMetforminPioglitazone.isEmpty ? null : _selectedMetforminPioglitazone,
      change: _selectedChange,
      diabetesMed: _selectedDiabetesMed,
      readmitted: _selectedReadmitted.isEmpty ? null : _selectedReadmitted,
      createdBy: _isEditMode ? (_existingPatient?.createdBy ?? currentUserId) : currentUserId,
      updatedBy: currentUserId,
    );

    bool success;
    if (_isEditMode && _existingPatient != null) {
      // Use the MongoDB _id for updates, not encounterId
      if (_existingPatient!.id == null) {
        CustomSnackbar.error('Patient ID is missing. Cannot update patient.');
        return;
      }
      success = await _patientsController.updatePatient(_existingPatient!.id!, patient);
    } else {
      success = await _patientsController.createPatient(patient);
    }

    if (success) {
      Get.back(result: true);
    }
  }

  void _showDeleteDialog() {
    if (!_isEditMode || _existingPatient == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete patient ${_existingPatient!.patientId}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _deletePatient,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deletePatient() async {
    Get.back(); // Close dialog
    
    if (_existingPatient == null) return;

    // Use the MongoDB _id for deletion, not encounterId
    if (_existingPatient!.id == null) {
      CustomSnackbar.error('Patient ID is missing. Cannot delete patient.');
      return;
    }

    final success = await _patientsController.deletePatient(_existingPatient!.id!);
    
    if (success) {
      Get.back(result: true);
    }
  }
}

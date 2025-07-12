# Readmission Prediction API Integration

## Overview

This document describes the implementation of the Diabetic Patient Readmission Prediction API integration in the Flutter application.

## Features Implemented

### 1. Real API Integration

- **Single Patient Prediction**: Predicts readmission risk for individual patients
- **Batch Prediction**: Supports batch processing up to 100 patients
- **Model Information**: Retrieves ML model details and performance metrics
- **Test Endpoint**: Tests API connectivity with sample data

### 2. User Interface Enhancements

#### API Testing Buttons

- **Test API**: Tests the connection to localhost:3000
- **Model Info**: Shows detailed model information dialog
- **Batch Predict**: Batch prediction with multiple options

#### Prediction Options

- **High Risk Patients**: Batch predict for patients with high risk indicators
- **Current Page**: Predict for all patients on current page view
- **Random Sample**: Predict for 10 randomly selected patients

### 3. Error Handling & Fallback

- **Graceful Degradation**: Falls back to mock predictions if API is unavailable
- **Connection Status**: Clear indicators when API is offline/online
- **User Feedback**: Informative messages about API status

## API Endpoints Used

### Base URL

```
http://localhost:3000
```

### Endpoints

1. **GET /readmission/test** - Test prediction (public)
2. **POST /readmission/predict** - Single patient prediction (protected)
3. **POST /readmission/predict/batch** - Batch prediction (protected)
4. **GET /readmission/model-info** - Model information (protected)

## Implementation Details

### File Structure

```
lib/app/
├── constants/
│   └── api_constants.dart          # API endpoints configuration
├── services/
│   ├── api_service.dart           # Base HTTP service with auth
│   └── readmission_service.dart   # Readmission-specific API calls
├── models/
│   ├── patient_model.dart         # Patient data model with API conversion
│   └── readmission_prediction_model.dart # API response models
├── controllers/
│   └── patients_controller.dart   # Updated with API integration
└── views/
    └── patients/
        └── patients_view.dart     # Enhanced UI with API features
```

### Key Classes

#### ReadmissionService

- Handles all API communication
- Manages authentication automatically
- Provides comprehensive error handling
- Supports both single and batch predictions

#### API Response Models

- `ReadmissionApiResponse`: Single prediction response
- `ReadmissionBatchApiResponse`: Batch prediction response
- `ModelInfoResponse`: Model information response
- Automatic conversion to UI-compatible prediction objects

#### Enhanced Patient Model

- `toApiJson()`: Converts patient data to API-required format
- Handles empty/null field conversion to API expectations
- Maintains backward compatibility with existing UI code

## Usage Guide

### For Users

1. **Testing API Connection**

   - Click "Test API" button in the patients page header
   - Green success message indicates API is available
   - Red error message indicates API is offline (falls back to mock data)

2. **Single Patient Prediction**

   - Click "Predict" button next to any patient
   - System automatically tries real API first
   - Falls back to mock prediction if API unavailable

3. **Batch Prediction**

   - Click "Batch Predict" button in page header
   - Choose from three options:
     - High Risk Patients (up to 20)
     - Current Page (all visible patients)
     - Random Sample (10 patients)
   - Results are stored and can be viewed per patient

4. **Model Information**
   - Click "Model Info" button to view:
     - Model version and type
     - Risk thresholds (Low/Medium/High)
     - Accuracy metrics (Sensitivity, Specificity, etc.)
     - Feature categories used in predictions

### For Developers

#### Running with Real API

1. Start the backend server on `localhost:3000`
2. Ensure authentication is working
3. The app will automatically use real API endpoints

#### Testing Offline Mode

1. Stop the backend server
2. App will show connection errors and fall back to mock predictions
3. Users can still interact with all features

#### Adding New Endpoints

1. Add endpoint constants to `api_constants.dart`
2. Add service methods to `readmission_service.dart`
3. Create response models in `readmission_prediction_model.dart`
4. Update controller with new functionality

## API Request/Response Examples

### Single Patient Prediction Request

```json
{
  "patientData": {
    "encounter_id": 123456,
    "patient_nbr": 789012,
    "race": "Caucasian",
    "gender": "Male",
    "age": "[60-70)",
    "weight": "?",
    "admission_type_id": 1,
    "discharge_disposition_id": 1,
    "admission_source_id": 7,
    "time_in_hospital": 5,
    "payer_code": "MC",
    "medical_specialty": "InternalMedicine",
    "num_lab_procedures": 35,
    "num_procedures": 2,
    "num_medications": 12,
    "number_outpatient": 3,
    "number_emergency": 1,
    "number_inpatient": 1,
    "diag_1": "250.01",
    "diag_2": "401.9",
    "diag_3": "?",
    "number_diagnoses": 5,
    "max_glu_serum": ">200",
    "A1Cresult": ">8",
    "metformin": "Steady",
    "insulin": "Up",
    "change": "Ch",
    "diabetesMed": "Yes"
  }
}
```

### API Response

```json
{
  "code": 200,
  "message": "Readmission prediction completed successfully",
  "body": {
    "confidence_score": 48
  }
}
```

## Error Handling

### Connection Errors

- **Message**: "Unable to connect to server. Please check if the backend is running on localhost:3000"
- **Action**: Automatic fallback to mock predictions

### Authentication Errors

- **Message**: "Authentication required. Please login again."
- **Action**: Automatic token refresh attempt

### Validation Errors

- **Message**: Specific field validation errors from API
- **Action**: Display detailed error information to user

### Server Errors

- **Message**: "Server error. Please try again later."
- **Action**: Show error with option to retry

## Configuration

### Development Environment

- API Base URL: `http://localhost:3000` (web)
- API Base URL: `http://10.0.2.2:3000` (Android emulator)
- Authentication: JWT tokens automatically managed

### Production Considerations

- Update base URL in `api_constants.dart`
- Configure proper SSL certificates
- Set up proper error monitoring
- Implement rate limiting awareness

## Performance Optimizations

1. **Caching**: API responses are cached per patient
2. **Batch Processing**: Efficient batch requests (max 100 patients)
3. **Error Recovery**: Graceful fallback prevents UI blocking
4. **Loading States**: Clear loading indicators during API calls

## Security Features

1. **Automatic Authentication**: JWT tokens handled automatically
2. **Token Refresh**: Automatic token refresh on expiry
3. **Secure Storage**: Tokens stored securely in device storage
4. **Input Validation**: Patient data validated before API calls

## Testing

### Manual Testing Checklist

- [ ] Test API connection with backend running
- [ ] Test API connection with backend stopped
- [ ] Test single patient prediction
- [ ] Test batch prediction (all three modes)
- [ ] Test model information display
- [ ] Test authentication token handling
- [ ] Test error message display
- [ ] Test fallback to mock predictions

### API Response Testing

- [ ] Valid prediction response (200)
- [ ] Invalid patient data (400)
- [ ] Authentication failure (401)
- [ ] Server error (500)
- [ ] Network timeout
- [ ] Connection refused

## Future Enhancements

1. **Real-time Updates**: WebSocket integration for live predictions
2. **Prediction History**: Store and track prediction history
3. **Export Features**: Export batch predictions to CSV/PDF
4. **Advanced Analytics**: Trend analysis and population health metrics
5. **Notification System**: Alerts for high-risk patients
6. **Integration APIs**: Connect with hospital information systems

## Troubleshooting

### Common Issues

1. **API Not Connecting**

   - Check if backend server is running on port 3000
   - Verify network connectivity
   - Check console logs for detailed error messages

2. **Authentication Failures**

   - Ensure user is logged in
   - Check token expiry
   - Try logging out and back in

3. **Prediction Errors**

   - Verify patient data completeness
   - Check API payload format
   - Review server logs for validation errors

4. **Performance Issues**
   - Limit batch prediction size
   - Check network speed
   - Monitor memory usage during large batches

### Debug Mode

Enable debug logging in `readmission_service.dart` to see detailed API communication logs.

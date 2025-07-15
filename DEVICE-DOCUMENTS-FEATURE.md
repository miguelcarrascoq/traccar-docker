# Device Document Management Feature

## Overview
This feature allows users to upload multiple documents (PDF, DOC, TXT, Images) to devices with descriptive names and store their metadata in the device attributes as JSON data in the `tc_devices` table. Each document requires both a user-provided name and a file, providing better organization and identification.

## Backend Changes

### 1. DeviceResource.java
- Added `uploadDocuments` endpoint (`POST /api/devices/{id}/documents`) with document name support
- Added `getDocuments` endpoint (`GET /api/devices/{id}/documents`) returning full document metadata
- Added `deleteDocument` endpoint (`DELETE /api/devices/{id}/documents/{filename}`)
- Added `downloadDocument` endpoint (`GET /api/devices/{id}/documents/{filename}`)
- Extended supported file types to include PDF, DOC, DOCX, TXT, and images
- Added multipart form handling with indexed parameters for names and files
- Enhanced document metadata tracking (name, filename, upload date, content type)

### 2. WebServer.java
- Added multipart configuration to enable file upload support
- Configured file size limits (10MB per file, 50MB per request)
- Set temporary file storage location

### 3. MediaManager.java
- Enhanced file storage using `createFileStream` method
- Supports multiple file types with proper validation

## Frontend Changes

### 1. DevicePage.jsx
- Added document upload UI with individual name input fields for each document
- Added dynamic document entry management (add/remove multiple documents)
- Added mandatory document name validation
- Added document list display with enhanced cards showing names and metadata
- Added document deletion functionality
- Added upload progress indication
- Enhanced form validation requiring both name and file for each document

### 2. DocumentCard.jsx (Enhanced Component)
- Card-based display for each document with name prominence
- Shows document name, original filename, and upload date
- File type icons with color coding by extension
- Download and delete actions
- Responsive design with improved metadata display
- Backward compatibility with old document format

## Database Schema
Documents are stored in the `tc_devices.attributes` JSON field as structured objects with metadata:
```json
{
  "documents": [
    {
      "name": "Vehicle Registration",
      "filename": "1641234567890_registration.pdf",
      "originalFilename": "registration.pdf",
      "uploadDate": 1641234567890,
      "contentType": "application/pdf"
    },
    {
      "name": "Insurance Policy",
      "filename": "1641234567891_insurance.docx",
      "originalFilename": "insurance.docx", 
      "uploadDate": 1641234567891,
      "contentType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    },
    {
      "name": "Vehicle Photo",
      "filename": "1641234567892_photo.jpg",
      "originalFilename": "car_photo.jpg",
      "uploadDate": 1641234567892,
      "contentType": "image/jpeg"
    }
  ]
}
```

### Document Object Structure
- **name**: User-provided descriptive name (mandatory)
- **filename**: System-generated unique filename with timestamp
- **originalFilename**: Original uploaded filename
- **uploadDate**: Upload timestamp in milliseconds
- **contentType**: MIME type of the uploaded file

## File Storage
- Files are stored in the media directory: `{media_path}/{device_unique_id}/`
- Each file has a unique timestamp-based filename
- Supports multiple file types with proper extensions

## API Endpoints

### Upload Documents
```
POST /api/devices/{deviceId}/documents
Content-Type: multipart/form-data

Form data structure:
- documentName_0: "Vehicle Registration"
- file_0: [PDF file]
- documentName_1: "Insurance Policy" 
- file_1: [DOCX file]
- documentName_N: "Document Name"
- file_N: [File]
```

### Get Documents
```
GET /api/devices/{deviceId}/documents
Response: Array of document objects with metadata
```

### Download Document
```
GET /api/devices/{deviceId}/documents/{filename}
```

### Delete Document
```
DELETE /api/devices/{deviceId}/documents/{filename}
```

## File Type Support
- **Images**: JPG, PNG, GIF, WEBP, SVG
- **Documents**: PDF, DOC, DOCX, TXT
- **Size Limits**: 
  - Max file size: 10MB per file
  - Max request size: 50MB total
  - File size threshold: 1MB (for memory vs disk storage)

## Usage Instructions

1. **Upload Documents**:
   - Navigate to Device Settings → Documents section
   - Enter a descriptive name for your document (mandatory)
   - Select the corresponding file using the file picker
   - Click "Add Another Document" to upload multiple documents at once
   - All documents must have both a name and file before uploading
   - Click "Upload Documents" to save all documents

2. **View Documents**:
   - All uploaded documents are displayed as enhanced cards
   - Each card prominently shows the document name
   - Original filename and upload date are shown below
   - Document count is shown in the accordion header
   - File type icons indicate document types with color coding

3. **Download Documents**:
   - Click the download icon on any document card
   - File will be downloaded with its original filename

4. **Delete Documents**:
   - Click the delete icon on any document card
   - Document will be removed from storage and database
   - Document list will automatically refresh

5. **Manage Multiple Documents**:
   - Use "Add Another Document" to create additional upload fields
   - Remove unwanted fields using the delete button (minimum 1 field)
   - Upload button only enables when at least one complete document entry exists

## Security Features
- User permissions are checked for all operations
- File type validation prevents malicious uploads
- File size limits prevent storage abuse (10MB per file, 50MB per request)
- Files are stored in device-specific directories
- Multipart configuration prevents servlet vulnerabilities
- Document names are validated and sanitized
- Authentication required for all document operations

## Technical Implementation

### Multipart Configuration
- Temporary file location: System temp directory
- Max file size: 10MB per file
- Max request size: 50MB total
- File size threshold: 1MB (memory vs disk)

### Form Data Structure
Documents are uploaded using indexed form fields:
- `documentName_0`, `documentName_1`, etc. for document names
- `file_0`, `file_1`, etc. for corresponding files
- Server matches names and files by index

### Data Flow
1. Frontend creates indexed form data with names and files
2. Backend processes multipart data, matching names to files
3. Files stored with unique timestamp-based filenames  
4. Document metadata saved to device attributes
5. Response includes complete document information

## Future Enhancements
- Document preview functionality
- Document search and filtering by name
- Document categories/tags
- Batch upload with progress tracking
- Document sharing between devices
- Version control for document updates
- Advanced file type support (Excel, PowerPoint, etc.)
- Document expiration dates
- Document access logging

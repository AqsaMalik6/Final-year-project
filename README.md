# MeasureMate – Precise Garments Size Measurement

MeasureMate is a mobile application built with Flutter that enables **precise, real-time measurement** of garments like **denim jeans** and **sweatshirts** using a smartphone camera and edge detection techniques. The app minimizes manual errors and speeds up the size-checking process for manufacturers, quality control teams, tailors, and apparel brands.

---

## Features

- **User Authentication** – Secure login and signup screens with Firebase Authentication.
- **Garment Type Selection** – Choose between Sweatshirt and Denim Jeans for size measurement.
- **Real-Time Camera Input** – Capture images of garments using device camera.
- **Automatic Measurement Extraction** – Detects contours and calculates key measurements using OpenCV.
- **Accuracy Comparison** – Compares user-input measurements with detected results and shows differences.
- **Save Results** – Save processed images with overlaid measurements for future reference.
- **Firebase Firestore Integration** – Stores user data, measurements, and image history securely.

---

## Technologies Used

- **Frontend**: [Flutter](https://flutter.dev/)  
- **Image Processing**: [OpenCV](https://opencv.org/) (via Dart bindings)  
- **State Management**: Dart Streams & Isolates  
- **Authentication & Database**: [Firebase Authentication](https://firebase.google.com/products/auth) + [Cloud Firestore](https://firebase.google.com/products/firestore)

---

## How It Works

1. User logs in or signs up.
2. Selects garment type: Sweatshirt or Denim Jeans.
3. Inputs actual size measurements for comparison.
4. App opens the camera and captures the garment image.
5. Dart isolates process the image using OpenCV to detect edges and contours.
6. Key measurements are calculated and compared with input.
7. Result is displayed along with the accuracy and the option to save.

---

## Measurement Details

### Sweatshirt
- Chest Width  
- Shirt Length  
- Sleeve Length  
- Shoulder Width  

### Denim Jeans
- Waist  
- Inseam  
- Full Length  

---

## Testing Highlights

- **Black Box Testing**: Verifies user interaction, input validation, and expected outputs.
- **White Box Testing**: Validates internal logic, image processing accuracy, and performance.
- **Integration Testing**: Ensures smooth data flow between Flutter UI and Dart isolates.

---

---

## Setup Instructions

1. **Clone the repository**  
   ```bash
   git clone https://github.com/ZaheerAfzal1408/MeasureMate.git
   cd MeasureMate
2. Install dependencies
   ```bash
   flutter pub get
3. Run the app
   ```bash
   flutter run

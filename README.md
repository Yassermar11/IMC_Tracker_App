## ✨ Features

- 🧮 **BMI Calculation**  
  Calculate and display the Body Mass Index (BMI) based on user input.  
  A visual **gauge** appears after clicking the **Calculate** button, showing the BMI value and indicating its category (e.g., Underweight, Normal, Overweight...) with color-coded segments.

- 🔐 **Authentication**  
  Secure user login and registration functionality, including:
  - 🔑 Login with email and password  
  - ❓ "Forgot Password" recovery option

- 💾 **Data Storage**  
  Store user data safely using **Firestore Database**

- 📊 **History Tracking**  
  Keep track of previous BMI entries and changes over time.  
  Each user's history is securely stored and **isolated from other users**, ensuring privacy and personalized data access.

- 🌍 **Multilingual Support**  
  Supports multiple languages:
  - English  
  - French  
  - Arabic

- 👤 **Profile Page**  
  A dedicated page where users can:
  - ✏️ Change their **username**
  - 📧 View the **email address** they registered with
  - 🚪 **Log out** securely from their account


## 🚀 Step by Step: How to run the Project on your computer

1) Clone the project
```bash
git clone https://github.com/Yassermar11/imc_with_backend_v2
```
Open the project in your IDE (e.g., Android Studio or VS Code).

2) Update Flutter dependencies

Run the following command to ensure all dependencies are up to date:
```bash
flutter pub get
```

3) Create a Firebase project
 - Sign in to [Firebase Console](https://console.firebase.google.com/u/0/)
 - Click ```Create a project```
 - In the Project name field, enter ```IMC```, then click Continue
 - You can choose to disable ```Google Analytics``` (optional)
 - Click through the project creation options, accept the Firebase terms if prompted.

4) Enable email sign-in authentication
 - In the [Firebase Console](https://console.firebase.google.com/u/0/), open your project and expand the ```Build``` menu.
 - Click ```Authentication > Get Started > Sign-in method > Email/Password```
 - ```Enable``` it and click ```Save```

![58e3e3e23c2f16a4_856](https://github.com/user-attachments/assets/3acfc8f4-c92f-4fa6-b7c6-c1f2dbeb4d85)

5) Set up Firestore

 - In the left panel of the [Firebase Console](https://console.firebase.google.com/u/0/), expand ```Build``` and select ```Firestore Database```
 - Click ```Create database```
 - Keep the Database ID as ```default```
 - Select a location for your database ```(Europe or USA is recommended)```, then click ```Next```
 - Click ```Start``` in test mode, and review the security rules disclaimer.
 - Click ```Create```

 - Go to ```the Rules``` tab and replace the content with:
```bash
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /bmiResults/{documentId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && 
                                   request.auth.uid == resource.data.userId;
    }
    match /users/{userId} {
      allow create: if request.auth != null && request.auth.uid == userId;
      allow read, update, delete: if request.auth != null && 
                                   request.auth.uid == userId;
    }
  }
}
```
 - Click ```Publish```
6) Configuration of index
 - In the [Firebase Console](https://console.firebase.google.com/u/0/), open your project and then Firestore Database.
 - Click ```Index > Add Index```

![efzefzefzef](https://github.com/user-attachments/assets/57e40be7-08d5-44d5-a12d-f6f3c7cfe342)

7) Configure Firebase in the Flutter project

Ensure you are logged in with the correct Google account by running:
```bash
firebase login
```
Run the following command to configure Firebase in your Flutter project:
```bash 
flutterfire configure
```

If you see the following message, type "no":

```You have an existing firebase.json file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing firebase.json file to configure your project?```

8) Generate localization files

Use this command to generate localization files. 
This command reads the ```intl configuration``` from the ```l10n.yaml``` file and generates the Dart localization files.
```bash
flutter gen-l10n
```

10) Run the project

Start the project with this command
```bash
flutter run -d edge
```
```It's recommended to run the project on the edge or chrome.```

## 📈 Sequence Diagram

![diagramme de séquence BMI app Yasser Marzouhi![efzefzefzef](https://github.com/user-attachments/assets/f6579e0f-a9f0-4c0d-8bf5-833f27062d7c)
](https://github.com/user-attachments/assets/4a3c2022-a171-4e88-be49-34616bcd9e92)

## 📲 Follow Me

<a href="https://linkedin.com/in/yasser-marzouhi-590a23260"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/LinkedIn_logo_initials.png/960px-LinkedIn_logo_initials.png" width="30" height="30" alt="LinkedIn"></a>
<a href="https://github.com/Yassermar11"><img src="https://upload.wikimedia.org/wikipedia/commons/9/91/Octicons-mark-github.svg" width="30" height="30" alt="GitHub"></a>
<a href="https://www.instagram.com/its_yasser_33/"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Instagram_logo_2022.svg/1200px-Instagram_logo_2022.svg.png" width="30" height="30" alt="Instagram"></a>

### 📌 Made by Yasser Marzouhi

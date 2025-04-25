 - BMI Calculation
 - Authentication
 - Data Storage
 - History Tracking
 - Multilingual Support
    - English/French/Arabic languages

1) Clone the project
git clone https://github.com/Yassermar11/imc_with_backend_v2

2) Update Flutter dependencies

Run the following command to ensure all dependencies are up to date:
$ flutter pub get

If you see the message "All dependencies are up-to-date.", you're good to go.

3) Create a Firebase project
 - Sign in to Firebase Console: Firebase Console
 - Click Create a project.
 - In the Project name field, enter "IMC", then click Continue.
 - Disable the Google Analytics option.
 - Click through the project creation options. Accept the Firebase terms if prompted.

4) Enable email sign-in authentication
 - In the Firebase Console, open your project and expand the Build (Créer) menu.
 - Click Authentication > Get Started > Sign-in method > Email/Password.
 - Enable it and click Save.

See example here : https://firebase.google.com/static/codelabs/firebase-get-to-know-flutter/img/58e3e3e23c2f16a4_856.png

5) Set up Firestore
 - In the left panel of the Firebase Console, expand Build (Créer) and select Firestore Database.
 - Click Create database.
 - Keep the Database ID as (default).
 - Select a location for your database (Europe is recommended), then click Next.
 - Click Start in test mode and read the security rules disclaimer.
 - Click Create.

 - Go to the Rules (Règles) tab and replace the content with:

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

 - Click Publish (Partager).
6) Configuration de l'index
 - In the Firebase Console, open your project and then Firestore Database.
 - Click Index > Add Index (or "Ajouter un index")
 - Screenshot explain everything https://drive.google.com/file/d/15RuAYuHvQ2-L0qvUgw5-wqwZiRf52X9J/view?usp=sharing

7) Configure Firebase in the Flutter project

Ensure you are logged in with the correct Google account by running:
$ firebase login

Run the following command to configure Firebase in your Flutter project:
$ flutterfire configure

If you see the following message, type "no":

"You have an existing firebase.json file and possibly already configured your project for Firebase.
Would you prefer to reuse the values in your existing firebase.json file to configure your project? · no"

8) Run the project
- Befor you run the project, use this command to generate localization files. This command reads the intl configuration from the l10n.yaml file and generates the Dart localization files.
- $ flutter gen-l10n

- Start the project with the command:
flutter run -d edge (It's recommended to run the project on the edge or chrome, to avoid the problems with the android)

Diagramme de séquence : 
![diagramme de séquence BMI app Yasser Marzouhi](https://github.com/user-attachments/assets/4a3c2022-a171-4e88-be49-34616bcd9e92)

📌 made by @Yassermar11



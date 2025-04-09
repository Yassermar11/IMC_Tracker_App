1) Clone the project
git clone https://github.com/Yassermar11/imc_with_backend_v2

2) Update Flutter dependencies

Run the following command to ensure all dependencies are up to date:
flutter pub get

Or check for outdated packages by running:
flutter pub outdated
If you see the message "All dependencies are up-to-date.", you're good to go.

3) Create a Firebase project

Sign in to Firebase Console: Firebase Console

Click Create a project.

In the Project name field, enter "IMC", then click Continue.

Disable the Google Analytics option.

Click through the project creation options. Accept the Firebase terms if prompted.

4) Enable email sign-in authentication

In the Firebase Console, open your project and expand the Build (Créer) menu.

Click Authentication > Get Started > Sign-in method > Email/Password.

Enable it and click Save.

See example here : https://firebase.google.com/static/codelabs/firebase-get-to-know-flutter/img/58e3e3e23c2f16a4_856.png

5) Set up Firestore

In the left panel of the Firebase Console, expand Build (Créer) and select Firestore Database.

Click Create database.

Keep the Database ID as (default).

Select a location for your database (Europe is recommended), then click Next.

Click Start in test mode and read the security rules disclaimer.

Click Create.

Go to the Rules (Règles) tab and replace the content with:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /bmiResults/{documentId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && 
                                   request.auth.uid == resource.data.userId;
    }
  }
}

Click Publish (Partager).

6) Configure Firebase in the Flutter project

Ensure you are logged in with the correct Google account by running:
firebase login

Run the following command to configure Firebase in your Flutter project:
flutterfire configure
If you see the following message, type "no":

"You have an existing firebase.json file and possibly already configured your project for Firebase.
Would you prefer to reuse the values in your existing firebase.json file to configure your project? · no"

7) Configuration de l'index
In the Firebase Console, open your project and then Firestore Database.
Click Index > Add Index (or "Ajouter un index")

  - ID de collection : bmiResults
  
  - Chemin d'accès du champ : userId   -->  Ascending
  - Chemin d'accès du champ : timestamp   -->  Descending
  - Chemin d'accès du champ : __name__   -->  Descending (You may click on "Ajouter un champ")

  - Champs d'application des requetes --> Collection

8) Run the project
Start the project with the command:
flutter run -d edge (It's recommended to run the project on the edge, to avoid the problems with the android)
If you encounter any issues, feel free to contact me.

📌 @made_by_yasser

# NetConnect Setup Guideline

Before running the application, you need to set up Firebase and Google Cloud Platform (GCP) to enable authentication and access to Google Sheets and Calendar.

## 1. Firebase Project Setup

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add project** and follow the steps to create a new project (e.g., "NetConnect").
3.  Once created, go to **Project settings** (gear icon).
4.  Under **Your apps**, click the **Web** icon (`</>`) to add a web app.
5.  Register the app (you can ignore Firebase Hosting for now).
6.  You will see a configuration object (`firebaseConfig`). You will need these values for `lib/firebase_options.dart` (or use `flutterfire configure` if you have the CLI).

### Enable Authentication
1.  In the Firebase Console sidebar, go to **Build** > **Authentication**.
2.  Click **Get started**.
3.  Select **Google** as a Sign-in provider.
4.  Enable it.
5.  Configure the **Support email**.
6.  **IMPORTANT**: You will need to add your authorized domains (e.g., `localhost`, your deployment domain) in the **Authorized domains** section.

## 2. Google Cloud Platform (GCP) Setup

Firebase automatically creates a GCP project. You need to enable specific APIs.

1.  Go to the [Google Cloud Console](https://console.cloud.google.com/).
2.  Select your Firebase project from the top dropdown.
3.  Open the **Navigation Menu** > **APIs & Services** > **Library**.
4.  Search for and **Enable** the following APIs:
    *   **Google Sheets API**
    *   **Google Drive API**
    *   **Google Calendar API**

### OAuth Consent Screen
1.  Go to **APIs & Services** > **OAuth consent screen**.
2.  Select **External** (or Internal if you have a Workspace organization) and click **Create**.
3.  Fill in the **App Information** (App name, User support email, Developer contact information).
4.  Click **Save and Continue**.
5.  **Scopes**: Add the following scopes:
    *   `.../auth/userinfo.email`
    *   `.../auth/userinfo.profile`
    *   `https://www.googleapis.com/auth/spreadsheets` (See, edit, create, and delete your Google Sheets spreadsheets)
    *   `https://www.googleapis.com/auth/drive.file` (See, edit, create, and delete only the specific Google Drive files you use with this app)
    *   `https://www.googleapis.com/auth/calendar` (See, edit, share, and permanently delete all the calendars you can access using Google Calendar)
6.  **Test Users**: Add your own email address as a test user so you can log in during development.

### Credentials
1.  Go to **APIs & Services** > **Credentials**.
2.  You should see an **OAuth 2.0 Client ID** (Web client) created by Firebase.
3.  Click the pencil icon to edit it.
4.  Under **Authorized JavaScript origins**, add:
    *   `http://localhost:5000` (or whatever port you use)
    *   `http://localhost:****` (your Flutter debug port)
5.  Under **Authorized redirect URIs**, add:
    *   `http://localhost:5000/__/auth/handler`
    *   `https://<your-project-id>.firebaseapp.com/__/auth/handler`

## 3. Code Configuration

1.  **Firebase Options**:
    If you use `flutterfire configure`, it will generate `lib/firebase_options.dart`.
    Otherwise, create `lib/firebase_options.dart` and populate it with your Firebase config.

## 4. Enable Vertex AI for Firebase

1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Select your project.
3.  In the left sidebar, click on **Build** > **Vertex AI**.
4.  Click **Get started** (if not already enabled).
5.  Follow the prompts to enable the API and link a billing account (required for Vertex AI, though there is a free tier).

## 5. Enable App Check (Optional but Recommended)

1.  In the Firebase Console, go to **Build** > **App Check**.
2.  Click **Get started**.
3.  Register your web app for App Check using **reCAPTCHA v3**.
    *   You will need to create a reCAPTCHA v3 key in the [Google Cloud Console](https://console.cloud.google.com/security/recaptcha).
    *   Add the **Site Key** to your Firebase App Check configuration.
    *   Update `lib/services/firebase_service.dart` with this Site Key.
4.  If you skip this, AI features might not work if App Check is enforced. For development, you can use the debug provider (already configured in code).

## 6. Run the Application

1.  Open a terminal in the project root.
2.  Run the following command:
    ```bash
    flutter run -d chrome
    ```

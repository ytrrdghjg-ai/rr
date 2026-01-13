/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.12.4/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.4/firebase-messaging-compat.js');

firebase.initializeApp({"apiKey": "AIzaSyDvNt9M9VqmZP_cDKokBgPhfteoE-F_bOA", "authDomain": "resdelivery-4b658.firebaseapp.com", "projectId": "resdelivery-4b658", "storageBucket": "resdelivery-4b658.firebasestorage.app", "messagingSenderId": "783938973684", "appId": "1:783938973684:web:3c58042bb9e8da304453a1", "measurementId": "G-QZC4YEKF9F"});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || 'إشعار';
  const options = {
    body: payload.notification?.body || '',
  };
  self.registration.showNotification(title, options);
});

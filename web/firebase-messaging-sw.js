importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging.js');

firebase.initializeApp({
    apiKey: 'AIzaSyDASHR2FiPLLllcy7ofZJ-UJ3rfNuvocCM',
    authDomain: 'car-rental-62719.firebaseapp.com',
    projectId: 'car-rental-62719',
    storageBucket: 'car-rental-62719.appspot.com',
    messagingSenderId: '627192719',
    appId: '1:627192719:web:your_web_app_id',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/favicon.png'
    };
    self.registration.showNotification(notificationTitle, notificationOptions);
});

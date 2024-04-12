const admin = require('firebase-admin');
const serviceAccount = require('./key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://console.firebase.google.com/project/compare-app-f00bb/firestore/databases/-default-/data/~2F' 
});

const firestore = admin.firestore();

const storesData = require('./stores.json');

storesData.stores.forEach(store => {
  firestore.collection('stores').doc(store.name.toLowerCase()).set({
    rank: store.rank,
    items: store.items.reduce((acc, item) => {
      acc[item.name] = item.price;
      return acc;
    }, {})
  });
});

console.log('Data imported successfully.');

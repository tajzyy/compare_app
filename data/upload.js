const admin = require('firebase-admin');
const serviceAccount = require('./key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://console.firebase.google.com/project/compare-app-f00bb/firestore/databases/-default-/data/~2F' 
});

const firestore = admin.firestore();

const storesData = require('./stores.json');
const foodData = require('./foods.json');

console.log("here")
storesData.stores.forEach(store => {
  const storeRef = firestore.collection('stores').doc(store.name.toLowerCase());
  
  // Update the map field directly with prices and discounts
  const itemsToUpdate = {};
  store.items.forEach(item => {
    itemsToUpdate[item.name.toLowerCase()] = {
      price: item.price,
      discount: item.discount
    };
  });
  
  // Update the entire items map field
  storeRef.update({
    items: itemsToUpdate
  })
  .then(() => {
    console.log(`Prices and discounts updated successfully for store ${store.name}.`);
  })
  .catch(error => {
    console.error(`Error updating prices and discounts for store ${store.name}:`, error);
  });
});

console.log("here")
foodData.items.forEach(food => {
  const storeRef = firestore.collection('foods').doc(food.name.toLowerCase());
  
  // Update the map field directly with prices and discounts
  const itemsToUpdate = {};
  food.stores.forEach(store => {
    itemsToUpdate[store.name.toLowerCase()] = {
      price: store.price,
      discount: store.discount
    };
  });
  
  // Update the entire items map field
  storeRef.update({
    items: itemsToUpdate
  })
  .then(() => {
    console.log(`Prices and discounts updated successfully for store ${food.name}.`);
  })
  .catch(error => {
    console.error(`Error updating prices and discounts for store ${food.name}:`, error);
  });
});
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Notificación de nuevo mensaje de chat
exports.createChatNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;
    const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
    const users = chatDoc.data().users;
    const senderId = message.senderId;
    const receiverId = users.find(uid => uid !== senderId);
    await admin.firestore()
      .collection('users')
      .doc(receiverId)
      .collection('notifications')
      .add({
        title: 'Nuevo mensaje',
        body: message.content,
        date: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
  });

// Notificación de nueva compra
exports.createPurchaseNotification = functions.firestore
  .document('purchases/{purchaseId}')
  .onCreate(async (snap, context) => {
    const purchase = snap.data();
    // Notificar al vendedor
    await admin.firestore()
      .collection('users')
      .doc(purchase.sellerId)
      .collection('notifications')
      .add({
        title: '¡Tienes una nueva venta!',
        body: `El usuario ${purchase.buyerName || 'alguien'} compró tu producto.`,
        date: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
    // Notificar al comprador
    await admin.firestore()
      .collection('users')
      .doc(purchase.buyerId)
      .collection('notifications')
      .add({
        title: '¡Compra realizada!',
        body: `Has comprado ${purchase.productTitle || 'un producto'}.`,
        date: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
  });

// Notificación de favorito
exports.createFavoriteNotification = functions.firestore
  .document('users/{userId}/favorites/{productId}')
  .onCreate(async (snap, context) => {
    const productId = context.params.productId;
    const userId = context.params.userId;
    const productDoc = await admin.firestore().collection('products').doc(productId).get();
    const sellerId = productDoc.data().sellerId;
    await admin.firestore()
      .collection('users')
      .doc(sellerId)
      .collection('notifications')
      .add({
        title: '¡Producto agregado a favoritos!',
        body: `Alguien agregó tu producto a favoritos.`,
        date: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
  });

// Notificación de nuevo producto publicado
exports.createNewProductNotification = functions.firestore
  .document('products/{productId}')
  .onCreate(async (snap, context) => {
    const product = snap.data();
    // Notificar a todos los usuarios
    const usersSnap = await admin.firestore().collection('users').get();
    const batch = admin.firestore().batch();
    usersSnap.forEach(doc => {
      batch.set(
        doc.ref.collection('notifications').doc(),
        {
          title: '¡Nuevo producto publicado!',
          body: `${product.title || 'Un producto'} ya está disponible.`,
          date: admin.firestore.FieldValue.serverTimestamp(),
          read: false,
        }
      );
    });
    await batch.commit();
  });

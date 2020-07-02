const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const algoliasearch = require('algoliasearch');
const ALGOLIA_ID = functions.config().algolia.app_id;
const ALGOLIA_ADMIN_KEY = functions.config().algolia.api_key;
const ALGOLIA_SEARCH_KEY = functions.config().algolia.search_key;
const ALGOLIA_INDEX_NAME = 'posts';

const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);

exports.createIndex = functions.firestore.document('posts/{postID}').onCreate((snap, context) => {
 const data = snap.data();
    // AlgoliaのIndexに保存する情報
  const algoliaObject = {
    groupID: data.GroupID,
    title: data.name,
    text: data.text,
  };
  algoliaObject.objectID = context.params.postID;

  // Indexを保存
  const index = client.initIndex(ALGOLIA_INDEX_NAME);
  return index.saveObject(algoliaObject);
})
exports.removeIndex = functions.firestore.document('posts/{postID}').onDelete((snap, context)  => {
   const objectID = context.params.postID;

   return index.deleteObject(objectID);
})
exports.editIndex  = functions.firestore.document('posts/{postID}').onUpdate((snap, context) => {
 const afterData = snap.after.data();
 const algoliaObject = {
     groupID: afterData.groupID,
     title: afterData.title,
     text: afterData.text,
   };
  algoliaObject.objectID = context.params.postID;
  return index.saveObject(algoliaObject);
})

const admin = require('firebase-admin');
const { firebaseConfig } = require('firebase-functions');
admin.initializeApp();

const db = admin.firestore();
const userRef = db.collection('users');
const groupRef = db.collection('groups');
const postRef = db.collection('posts');
exports.addGroup = functions.https.onCall((data, context) =>{
      groupRef.add({
          name: data.name,
          text: data.text,
          iconImage: data.image,
          GroupUser: context.auth.uid,
          UserCount: 1,
          Follower: 0,
      }).then(function(docRef) {
        return userRef.doc(context.auth.uid).collection('belongingGroup').doc(docRef.id).set({
           joinAt: admin.firestore.FieldValue.serverTimestamp(),
           GroupID: docRef.id
       })
      })
        .catch(function(error) {
           throw console.error("Error adding document: ", error);
        });
})
exports.copyPost = functions.https.onCall((data, context) =>{
  return userRef.doc(context.auth.uid).collection('feed').doc(data.postID).set({
      postID: data.postID
  });
})
exports.copyPostForFollower = functions.firestore.document('groups/{groupID}/posts/{postID}').onCreate((snap, context) => {
  const postID = context.params.postID;
  const groupID = context.params.groupID;
  return groupRef.doc(groupID).collection('Follower').get().then(function(snap) {
    return snap.forEach(function(doc) {
      userRef.doc(doc.id).collection('feed').doc(postID).set({
      postID: postID,
      });
    });
  })
  .catch(function(error) {
        console.log("Error getting documents: ", error);
  });
})
exports.removePostForFollower = functions.firestore.document('groups/{groupID}/posts/{postID}').onDelete((snap, context) => {
  const postID = context.params.postID;
    const groupID = context.params.groupID;
    return groupRef.doc(groupID).collection('Follower').get().then(function(snap) {
      return snap.forEach(function(doc) {
        userRef.doc(doc.id).collection('feed').doc(postID).delete();
      });
    })
    .catch(function(error) {
          console.log("Error getting documents: ", error);
    });
})
exports.copyPostForGroup = functions.firestore.document('posts/{postID}').onCreate((snap, context) => {
  const postID = context.params.postID;
  const groupID = snap.data().GroupID;
  return groupRef.doc(groupID).collection('posts').doc(postID).set({
    postID: postID,
  });
})
exports.removePostForGroup = functions.firestore.document('posts/{postID}').onDelete((snap, context) => {
  const postID = context.params.postID;
  const groupID = snap.data().GroupID;
  return groupRef.doc(groupID).collection('posts').doc(postID).delete();
})

exports.addPost = functions.https.onCall((data, context) =>{
    postRef.add({
      title: data.title,
      text: data.text,
      imageURL: data.image,
      GroupID: data.groupID,
      like: 0,
      created: admin.firestore.FieldValue.serverTimestamp(),
    }).then(function(docRef){
      return groupRef.doc(data.groupID).collection('posts').doc(docRef.id).set({
        postID: docRef.id
      })
    }).catch(function(error){
      throw console.error("Error adding document: ", error);
    });
})
// フォローした時の処理
exports.followGroup = functions.firestore.document('users/{userID}/following/{groupID}').onCreate((snap, context) => {
    const groupID = context.params.groupID;
    const userID = context.params.userID;
    
    return groupRef.doc(groupID).collection('posts').get().then(function(snap) {
        return snap.forEach(function(doc){
            db.collection('users').doc(userID).collection('feed').doc(doc.id).set({
            postID: doc.id,
          });
        });
    })
    .catch(function(error) {
      console.log("Error getting documents: ", error);
    });
})
exports.followGroupForFollower = functions.firestore.document('users/{userID}/following/{groupID}').onCreate((snap, context) => {
  const groupID = context.params.groupID;
  const userID = context.params.userID;
  return db.collection('groups').doc(groupID).collection('Follower').doc(userID).set({
    userID: userID,
  });
})
// フォローを外した時の処理
exports.unFollowGroup = functions.firestore.document('users/{userID}/following/{groupID}').onDelete((snap, context) => {
  const groupID = context.params.groupID;
  const userID = context.params.userID;
  
  return groupRef.doc(groupID).collection('posts').get().then(function(snap) {
      return snap.forEach(function(doc){
          db.collection('users').doc(userID).collection('feed').doc(doc.id).delete();
      });
  })
  .catch(function(error) {
    console.log("Error getting documents: ", error);
  });
})
exports.unFollowGroupForFollower = functions.firestore.document('users/{userID}/following/{groupID}').onDelete((snap, context) => {
  const groupID = context.params.groupID;
  const userID = context.params.userID;
  return db.collection('groups').doc(groupID).collection('Follower').doc(userID).delete();
})
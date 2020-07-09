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
   const index = client.initIndex(ALGOLIA_INDEX_NAME);
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
exports.createdGroupIndex = functions.firestore.document('groups/{groupID}').onCreate((snap, context) => {
  const data = snap.data();
      // AlgoliaのIndexに保存する情報
    const algoliaObject = {
      name: data.name,
      text: data.text,
    };
    algoliaObject.objectID = context.params.groupID;

    // Indexを保存
    const groupIndex = client.initIndex('groups');
    return groupIndex.saveObject(algoliaObject);
})
exports.removeGroupIndex = functions.firestore.document('groups/{groupID}').onDelete((snap, context)  => {
   const objectID = context.params.groupID;
   const groupIndex = client.initIndex('groups');
   return groupIndex.deleteObject(objectID);
})
exports.editGroupIndex  = functions.firestore.document('groups/{groupID}').onUpdate((snap, context) => {
 const afterData = snap.after.data();
 const algoliaObject = {
     name: afterData.name,
     text: afterData.text,
   };
   const groupIndex = client.initIndex('groups');
  algoliaObject.objectID = context.params.groupID;
  return groupIndex.saveObject(algoliaObject);
})
exports.createdUserIndex = functions.firestore.document('users/{userID}').onCreate((snap, context) => {
  const data = snap.data();
      // AlgoliaのIndexに保存する情報
    const algoliaObject = {
      title: data.name,
    };
    algoliaObject.objectID = context.params.userID;
    // Indexを保存
    const userIndex = client.initIndex('user');
    return userIndex.saveObject(algoliaObject);
})
exports.removeUserIndex = functions.firestore.document('users/{userID}').onDelete((snap, context)  => {
   const objectID = context.params.userID;
   const userIndex = client.initIndex('user');
   return userIndex.deleteObject(objectID);
})
exports.editUserIndex  = functions.firestore.document('users/{userID}').onUpdate((snap, context) => {
 const afterData = snap.after.data();
 const algoliaObject = {
     name: afterData.name,
   };
  algoliaObject.objectID = context.params.userID;
  const userIndex = client.initIndex('user');
  return userIndex.saveObject(algoliaObject);
})

const admin = require('firebase-admin');
const { firebaseConfig } = require('firebase-functions');
admin.initializeApp();

const db = admin.firestore();
const userRef = db.collection('users');
const groupRef = db.collection('groups');
const postRef = db.collection('posts');
exports.addGroup = functions.firestore.document('groups/{groupID}').onCreate((snap,context) => {
  const data = snap.data();
  const groupID = context.params.groupID;
  return userRef.doc(data.Founder).collection('belongingGroup').doc(groupID).set({
    joinAt: data.created,
  }).then(function(snap) {
    return groupRef.doc(groupID).collection('groupUsers').doc(data.Founder).set({
     joinAt: data.created,
    });
  });
})

exports.copyPost = functions.https.onCall((data, context) =>{
  return userRef.doc(context.auth.uid).collection('feed').doc(data.postID).set({
      postID: data.postID,
      created: FieldValue.serverTimestamp();
    
  });
})
exports.copyPostForFollower = functions.firestore.document('groups/{groupID}/posts/{postID}').onCreate((snap, context) => {
  const postID = context.params.postID;
  const groupID = context.params.groupID;
  const data = snap.data();
  return groupRef.doc(groupID).collection('Follower').get().then(function(snap) {
    return snap.forEach(function(doc) {
      userRef.doc(doc.id).collection('feed').doc(postID).set({
      postID: postID,
      created: data.created
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
  const data = snap.data();
  return groupRef.doc(groupID).collection('posts').doc(postID).set({
    postID: postID,
    created: data.created
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
            created: doc.created
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
exports.competition = functions.firestore.document('users/{userID}/belongingGroup/{groupID}').onDelete((snap,context) => {
   const userID = context.params.userID;
   const groupID = context.params.groupID;
   return groupRef.doc(groupID).collection('groupUsers').doc(userID).delete();
})
exports.incrementGroupUser = functions.firestore.document('users/{userID}/belongingGroup/{groupID}').onCreate((snap,context) => {
  const groupID = context.params.groupID;
  const userID = context.params.userID;
  return db.collection('groups').doc(groupID).update({
    UserCount: FieldValue.increment(1)
  });
})
exports.decrementGroupUser= functions.firestore.document('users/{userID}/belongingGroup/{groupID}').onDelete((snap,context) => {
  const groupID = context.params.groupID;
  const userID = context.params.userID;
  return db.collection('groups').doc(groupID).update({
    UserCount: FieldValue.increment(-1)
  });
})
const functions = require('firebase-functions');
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
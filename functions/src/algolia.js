const functions = require('firebase-functions');
const algoliasearch = require('algoliasearch');
const ALGOLIA_ID = functions.config().algolia.app_id;
const ALGOLIA_ADMIN_KEY = functions.config().algolia.api_key;
const ALGOLIA_SEARCH_KEY = functions.config().algolia.search_key;
const ALGOLIA_INDEX_NAME = 'posts';

const client = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);




exports.createIndex = functions.database.ref('posts/{postID}').onCreate((snap, context) => {
 const data = snap.data();
    // AlgoliaのIndexに保存する情報 
  const algoliaObject = {
    objectID: context.params.postID,
    groupID: data.groupID,
    title: data.title,
    text: data.text,
  }

  // Indexを保存
  const index = client.initIndex(ALGOLIA_INDEX_NAME);
  return index.saveObject(algoliaObject);
});
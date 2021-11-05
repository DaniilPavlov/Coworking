const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const database = admin.firestore();


// firebase deploy

//добавил час, чтобы не сразу удалялись встречи
exports.checkMeetingEnd = functions.pubsub.schedule('every 60 minutes').onRun(async (context) => {
    const query = await database.collection("meetings")
        .where("dateCompleted", '<=', new Date(Date.now() - 60 * 60 * 1000))
        .get();
    query.forEach(async eachMeeting => {
        await database.doc('meetings/' + eachMeeting.id).delete()
    })
});

exports.checkMeetingSoon= functions.pubsub.schedule('every 60 minutes').onRun(async (context) => {
    var title = `До встречи осталось мение часа`;
    var body = `Нажмите для подробной информации`;
    const query = await database.collection("meetings")
        .where("dateCompleted", '<=', new Date(Date.now() + 60 * 60 * 1000))
        .get();
    query.forEach(document => {
                var tokens = document.tokens;
                tokens.forEach(async eachToken => {
                  const message = {
                      notification: { title: title, body: body},
                      token: eachToken,
                      data: { click_action: 'FLUTTER_NOTIFICATION_CLICK' },
                  }
                  admin.messaging().send(message).then(response => {
                      return console.log("Notification 1 HOUR TO MEETING successful");
                  }).catch(error => {
                      return console.log("Error 1 HOUR: " + error);
                  });
              });
              });
});

exports.onUpdateMeeting = functions.firestore.document('meetings/{documentId}').onUpdate(async (snapshot, context)  => {
    var meetingInfoAfter = snapshot.after.data();
    var tokens = meetingInfoAfter.tokens;
    var meetingInfoBefore = snapshot.before.data();

    if(meetingInfoAfter.notify != meetingInfoBefore.notify){
        var title = `Напоминание о встрече`;
        var body = `Нажмите для подробной информации`;
    } else {
        var title = `Изменение одной из ваших встреч`;
        var body = `Нажмите для подробной информации`;
    }
    tokens.forEach(async eachToken => {
        const message = {
            notification: { title: title, body: body },
            token: eachToken,
            data: { click_action: 'FLUTTER_NOTIFICATION_CLICK' },
        }
        admin.messaging().send(message).then(response => {
            return console.log("Notification NEW INFO successful");
        }).catch(error => {
            return console.log("Error NEW INFO: " + error);
        });
    });
});
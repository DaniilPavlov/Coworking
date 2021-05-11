const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const database = admin.firestore();


// firebase deploy

exports.checkMeetingEnd = functions.pubsub.schedule('every 90 minutes').onRun(async (context) => {
    const query = await database.collection("meetings")
        .where("dateCompleted", '<=', admin.firestore.Timestamp.now())
        .get();
    query.forEach(async eachMeeting => {
        await database.doc('meetings/' + eachMeeting.id).delete()
    })
})

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
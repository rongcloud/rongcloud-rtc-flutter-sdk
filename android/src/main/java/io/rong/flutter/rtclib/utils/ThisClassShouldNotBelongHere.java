package io.rong.flutter.rtclib.utils;

import io.rong.imlib.chatroom.message.ChatRoomKVNotiMessage;
import io.rong.imlib.location.message.LocationMessage;
import io.rong.imlib.model.MessageContent;
import io.rong.message.FileMessage;
import io.rong.message.GIFMessage;
import io.rong.message.HQVoiceMessage;
import io.rong.message.ImageMessage;
import io.rong.message.RecallNotificationMessage;
import io.rong.message.ReferenceMessage;
import io.rong.message.RichContentMessage;
import io.rong.message.SightMessage;
import io.rong.message.TextMessage;

public class ThisClassShouldNotBelongHere {

    public MessageContent string2MessageContent(String object, String content) {
        MessageContent message = null;
        switch (object) {
            case CHAT_ROOM_KV_NOTIFICATION_MESSAGE:
                message = new ChatRoomKVNotiMessage(content.getBytes());
                break;
//            case COMBINE_MESSAGE:
//                message = new CombineMessage(content.getBytes());
//                break;
            case FILE_MESSAGE:
                message = new FileMessage(content.getBytes());
                break;
            case GIF_MESSAGE:
                message = new GIFMessage(content.getBytes());
                break;
            case IMAGE_MESSAGE:
                message = new ImageMessage(content.getBytes());
                break;
            case LOCATION_MESSAGE:
                message = new LocationMessage(content.getBytes());
                break;
            case RECALL_NOTIFICATION_MESSAGE:
                message = new RecallNotificationMessage(content.getBytes());
                break;
            case REFERENCE_MESSAGE:
                message = new ReferenceMessage(content.getBytes());
                break;
            case RICH_CONTENT_MESSAGE:
                message = new RichContentMessage(content.getBytes());
                break;
            case SIGHT_MESSAGE:
                message = new SightMessage(content.getBytes());
                break;
            case TEXT_MESSAGE:
                message = new TextMessage(content.getBytes());
                break;
            case HQ_VOICE_MESSAGE:
                message = new HQVoiceMessage(content.getBytes());
                break;
            default:
                RCFlutterLog.e("MessageContent", "NOT SUPPORT " + object + "TYPE MESSAGE!!!!");
                break;
        }
        return message;
    }

    private static class SingleHolder {
        static ThisClassShouldNotBelongHere instance = new ThisClassShouldNotBelongHere();
    }

    public static ThisClassShouldNotBelongHere getInstance() {
        return ThisClassShouldNotBelongHere.SingleHolder.instance;
    }

    private static final String CHAT_ROOM_KV_NOTIFICATION_MESSAGE = "RC:chrmKVNotiMsg";
//    private static final String COMBINE_MESSAGE = "RC:CombineMsg";
    private static final String FILE_MESSAGE = "RC:FileMsg";
    private static final String GIF_MESSAGE = "RC:GIFMsg";
    private static final String IMAGE_MESSAGE = "RC:ImgMsg";
    private static final String LOCATION_MESSAGE = "RC:LBSMsg";
    private static final String RECALL_NOTIFICATION_MESSAGE = "RC:RcNtf";
    private static final String REFERENCE_MESSAGE = "RC:ReferenceMsg";
    private static final String RICH_CONTENT_MESSAGE = "RC:ImgTextMsg";
    private static final String SIGHT_MESSAGE = "RC:SightMsg";
    private static final String TEXT_MESSAGE = "RC:TxtMsg";
    private static final String HQ_VOICE_MESSAGE = "RC:HQVCMsg";

}

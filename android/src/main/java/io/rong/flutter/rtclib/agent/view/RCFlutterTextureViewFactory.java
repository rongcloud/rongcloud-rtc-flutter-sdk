package io.rong.flutter.rtclib.agent.view;

import android.util.LongSparseArray;

public class RCFlutterTextureViewFactory {

    private LongSparseArray<RCFlutterTextureView> renders = new LongSparseArray<>();

    private static class SingletonHolder {
        static RCFlutterTextureViewFactory instance = new RCFlutterTextureViewFactory();
    }

    private RCFlutterTextureViewFactory() {
    }

    public static RCFlutterTextureViewFactory getInstance() {
        return RCFlutterTextureViewFactory.SingletonHolder.instance;
    }

    public void put(long textureId, RCFlutterTextureView renderer) {
        renders.put(textureId, renderer);
    }

    public RCFlutterTextureView get(long textureId) {
        return renders.get(textureId);
    }

    public void delete(long textureId) {
        renders.delete(textureId);
    }
}

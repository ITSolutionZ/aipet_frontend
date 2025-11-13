package com.itz.aipet_frontend

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import java.io.PrintStream

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // WebView 디버그 로그 비활성화
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(false)
        }

        // System.err 리다이렉션으로 WebView 경고 차단
        System.setErr(object : PrintStream(System.err) {
            override fun println(x: String?) {
                if (x != null && (
                    x.contains("ImageReader_JNI") ||
                    x.contains("setRequestedFrameRate") ||
                    x.contains("Unable to acquire a buffer") ||
                    x.contains("frameRate=NaN")
                )) {
                    // WebView 관련 경고는 무시
                    return
                }
                super.println(x)
            }
        })
    }
}

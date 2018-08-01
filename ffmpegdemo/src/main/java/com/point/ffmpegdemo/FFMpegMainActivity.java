package com.point.ffmpegdemo;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.text.method.ScrollingMovementMethod;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.TextView;

public class FFMpegMainActivity extends AppCompatActivity implements SurfaceHolder.Callback {

    private SurfaceHolder mSurfaceHolder;
//    public static final String url = "http://tx2.a.yximgs.com/upic/2017/06/06/12/BMjAxNzA2MDYxMjA3MDJfOTg5MDkwODRfMjMzMzY5NjI3OV8xXzM=_hd.mp4?tag=1-1496888787-h-0-2gpzxdvetp-f9da4113e6f3de74";
    public static final String url = "/mnt/sdcard/aa.mp4";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);


        final TextView tv = findViewById(R.id.tv);
        SurfaceView mSurfaceView = findViewById(R.id.surface_view);
        tv.setMovementMethod(ScrollingMovementMethod.getInstance());
        findViewById(R.id.button).setOnClickListener(new View.OnClickListener() {
            @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN)
            @Override
            public void onClick(View v) {
                tv.setText(FFmpegNdk.avcodecinfo());
//                startActivity(new Intent(FFMpegMainActivity.this, VideoActivity.class));
            }
        });

        mSurfaceHolder = mSurfaceView.getHolder();
        mSurfaceHolder.addCallback(this);

    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                FFmpegNdk.playVideo(url, mSurfaceHolder.getSurface());
            }
        }).start();
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {

    }


}

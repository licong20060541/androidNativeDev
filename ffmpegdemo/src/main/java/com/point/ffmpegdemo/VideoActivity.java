package com.point.ffmpegdemo;

import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.SystemClock;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatSeekBar;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import java.io.IOException;

import butterknife.Bind;
import butterknife.ButterKnife;

public class VideoActivity extends AppCompatActivity implements SeekBar.OnSeekBarChangeListener, MediaPlayer.OnCompletionListener {

    @Bind(R.id.surfaceView)
    SurfaceView surfaceView;
    @Bind(R.id.tv_cur_time)
    TextView tvCurTime;
    @Bind(R.id.tv_total_time)
    TextView tvTotalTime;
    @Bind(R.id.btn_play)
    Button btnPlay;
    @Bind(R.id.btn_pause)
    Button btnPause;
    @Bind(R.id.btn_stop)
    Button btnStop;
    @Bind(R.id.btn_restart)
    Button btnRestart;
    @Bind(R.id.seekbar)
    AppCompatSeekBar seekbar;
    private SurfaceHolder mHolder;
    private MediaPlayer mMediaPlayer;
    private boolean isStopUpdatingProgress = false;

    private static final int NORMAL = 0;
    private static final int PLAYING = 1;
    private static final int PAUSING = 2;
    private static final int STOPING = 3;
    private int currnetstate = NORMAL;

    public static final String url = "http://tx2.a.yximgs.com/upic/2017/06/06/12/BMjAxNzA2MDYxMjA3MDJfOTg5MDkwODRfMjMzMzY5NjI3OV8xXzM=_hd.mp4?tag=1-1496888787-h-0-2gpzxdvetp-f9da4113e6f3de74";


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video);
        ButterKnife.bind(this);

        initData();

    }

    private void initData() {
        seekbar.setOnSeekBarChangeListener(this);
        mHolder = surfaceView.getHolder();
        mHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }


    public void start(View view) {
        if (mMediaPlayer != null){
            if (currnetstate != PAUSING){
                mMediaPlayer.start();
                currnetstate = PLAYING;
                isStopUpdatingProgress = false;
                return;
            }else if(currnetstate == STOPING){
                mMediaPlayer.reset();
                mMediaPlayer.release();
            }
        }
        play();
    }

    public void play() {
        mMediaPlayer = new MediaPlayer();
//        设置数据类型
        mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
//        设置播放器显示的位置
        mMediaPlayer.setDisplay(mHolder);

        try {
            mMediaPlayer.setDataSource(url);
            mMediaPlayer.prepare();
            mMediaPlayer.start();

            mMediaPlayer.setOnCompletionListener(this);

            currnetstate = PLAYING;
//            总时长
            int duration = mMediaPlayer.getDuration();
            seekbar.setMax(duration);
            int m = duration / 1000 / 60;
            int s = duration / 1000 % 60;
            tvTotalTime.setText("/" + m + ":" + s);
            tvCurTime.setText("00:00");

            isStopUpdatingProgress = false;
            new Thread(new UpdateProgressRunnable()).start();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void stop(View view) {
        if (mMediaPlayer != null){
            mMediaPlayer.stop();
            currnetstate = STOPING;
        }
    }

    public void pause(View view) {
        if (mMediaPlayer != null && currnetstate == PLAYING){
            mMediaPlayer.pause();
            currnetstate = PAUSING;
            isStopUpdatingProgress = true;
        }
    }

    public void restart(View view) {
        if (mMediaPlayer != null){
            mMediaPlayer.reset();
            mMediaPlayer.release();
            play();
        }
    }


    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {
        isStopUpdatingProgress = true;
        Log.d("@@@","onStartTrackingTouch");
    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        final int progress = seekBar.getProgress();
        mMediaPlayer.seekTo(progress);
        isStopUpdatingProgress = false;
        new Thread(new UpdateProgressRunnable()).start();
    }

    @Override
    public void onCompletion(MediaPlayer mp) {
        Toast.makeText(this, "播放完成了，重新播放", Toast.LENGTH_SHORT).show();
        mp.start();
    }

    private class UpdateProgressRunnable implements Runnable {
        @Override
        public void run() {
            while (!isStopUpdatingProgress) {
                int currentPosition = mMediaPlayer.getCurrentPosition();

                seekbar.setProgress(currentPosition);
                final int m = currentPosition / 1000 / 60;
                final int s = currentPosition / 1000 % 60;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        tvCurTime.setText(m + ":" + s);
                    }
                });
                SystemClock.sleep(1000);

            }
        }
    }
}

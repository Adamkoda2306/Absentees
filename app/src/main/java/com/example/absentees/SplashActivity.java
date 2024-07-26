package com.example.absentees;

import androidx.appcompat.app.AppCompatActivity;
import android.content.Intent;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.activity.EdgeToEdge;
import androidx.core.view.WindowInsetsCompat;
import android.os.Handler;
import android.view.View;
import android.view.WindowManager;

public class SplashActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_splash);

//        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
//            int flags = getWindow().getDecorView().getSystemUiVisibility();
//            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR; // Remove the light status bar flag if it's set
//            getWindow().getDecorView().setSystemUiVisibility(flags);
//        } in this i dont want the status icon to be white

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                Intent intent = new Intent(SplashActivity.this, Branch_Login.class);
                startActivity(intent);
                finish();

            }
        }, 1500);
    }
}
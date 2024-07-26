package com.example.absentees;

import androidx.appcompat.app.AppCompatActivity;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;
import android.widget.Button;
import android.view.View;
import android.content.Intent;
import androidx.activity.EdgeToEdge;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class Branch_Login extends AppCompatActivity {

    Button cse, ece, aids;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        // Check if the user has already chosen a branch
        SharedPreferences preferences = getSharedPreferences("MyPrefs", MODE_PRIVATE);
        String chosenBranch = preferences.getString("chosenBranch", null);

        if (chosenBranch != null) {
            try {
                Class<?> chosenActivity = Class.forName(chosenBranch);
                Intent intent = new Intent(Branch_Login.this, chosenActivity);
                startActivity(intent);
                finish();
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
            return;
        }

        setContentView(R.layout.activity_branch_login);

//        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
//            int flags = getWindow().getDecorView().getSystemUiVisibility();
//            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR; // Remove the light status bar flag if it's set
//            getWindow().getDecorView().setSystemUiVisibility(flags);
//        }
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        cse = findViewById(R.id.cse);
        ece = findViewById(R.id.ece);
        aids = findViewById(R.id.aids);

        cse.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                navigateToActivity(CSE_MainActivity.class);
            }
        });

        ece.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                navigateToActivity(ECE_MainActivity.class);
            }
        });

        aids.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                navigateToActivity(AIDS_MainActivity.class);
            }
        });
    }

    private void navigateToActivity(Class<?> activityClass) {
        // Store the chosen branch in SharedPreferences
        SharedPreferences.Editor editor = getSharedPreferences("MyPrefs", MODE_PRIVATE).edit();
        editor.putString("chosenBranch", activityClass.getName());
        editor.putBoolean("isLoggedIn", true);
        editor.apply();

        // Navigate to the selected activity
        Intent intent = new Intent(Branch_Login.this, activityClass);
        startActivity(intent);
        finish();
    }
}

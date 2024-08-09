package com.example.absentees;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import androidx.core.content.ContextCompat;
import android.widget.ImageView;

public class TimeTableActivity extends AppCompatActivity {

    private ImageView backgroundImageView;
    private TextView button1, button2, button3, button4;
    private Button btnBack;

    private TextView selectedTextView = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_time_table);

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            getWindow().setStatusBarColor(ContextCompat.getColor(this, R.color.black));
            int flags = getWindow().getDecorView().getSystemUiVisibility();
            flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR; // Remove the light status bar flag if it's set
            getWindow().getDecorView().setSystemUiVisibility(flags);
        }
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        backgroundImageView = findViewById(R.id.backgroundImageView);
        button4 = findViewById(R.id.ece_time);
        button1 = findViewById(R.id.sec1_time);
        button3 = findViewById(R.id.sec2_time);
        button2 = findViewById(R.id.sec3_time);
        btnBack = findViewById(R.id.btnBack2);

        // Set initial image
        backgroundImageView.setImageResource(R.drawable.example_timetable);
        button2.setTextColor(Color.BLACK);
        button2.setBackgroundColor(Color.WHITE);
        selectedTextView = button2;

        // Set click listeners for buttons
        button1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateSelection(button1);
                backgroundImageView.setImageResource(R.drawable.menu_dot);
            }
        });
        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateSelection(button2);
                backgroundImageView.setImageResource(R.drawable.example_timetable);
            }
        });
        button3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateSelection(button3);
                backgroundImageView.setImageResource(R.drawable.example_timetable);
            }
        });
        button4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                updateSelection(button4);
                backgroundImageView.setImageResource(R.drawable.menu_dot);
            }
        });

        btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
            }
        });
    }

    private void updateSelection(TextView textView) {
        if (selectedTextView != null) {
            resetTextViewStyle(selectedTextView);
        }

        // Set the selected background and text color
        if (textView == button1) {
            textView.setBackgroundResource(R.drawable.ui_left_btn_clicked);
        } else if (textView == button2) {
            textView.setBackgroundColor(Color.WHITE);
        } else if (textView == button3) {
            textView.setBackgroundColor(Color.WHITE);
        } else if (textView == button4) {
            textView.setBackgroundResource(R.drawable.ui_right_btn_clicked);
        }
        textView.setTextColor(Color.BLACK);
        selectedTextView = textView;
    }

    private void resetTextViewStyle(TextView textView) {
        if (textView == button1) {
            textView.setBackgroundResource(R.drawable.ui_left_btn);
        } else if (textView == button2) {
            textView.setBackgroundColor(Color.BLACK);
        } else if (textView == button3) {
            textView.setBackgroundColor(Color.BLACK);
        } else if (textView == button4) {
            textView.setBackgroundResource(R.drawable.ui_right_btn);
        }
        textView.setTextColor(Color.WHITE);
    }

    @Override
    public void onBackPressed() {
        // Implement back navigation
        super.onBackPressed(); // This will finish the current activity and go back to the previous activity or fragment
    }
}

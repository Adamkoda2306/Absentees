package com.example.absentees;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import androidx.core.content.ContextCompat;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import java.util.Calendar;
import androidx.activity.EdgeToEdge;

public class CSE_MainActivity extends AppCompatActivity {

    private static final String PREFS_NAME = "AttendancePrefs";
    private static final String ATTENDANCE_KEY_PREFIX = "attendance_";

    private static AttendanceData[] attendanceData = {
            new AttendanceData("RANAC", 35, 0, 0, 0),
            new AttendanceData("OOPs", 32, 0, 0, 0),
            new AttendanceData("ADSA", 30, 0, 0, 0),
            new AttendanceData("OS", 30, 0, 0, 0),
            new AttendanceData("DBMS", 32, 0, 0, 0),
            new AttendanceData("PC", 33, 0, 0, 0)
    };

    private ImageView imageView;
    private Handler handler;
    private Runnable updateImageRunnable;
    private ScrollView scrollView2;
    private boolean isHidden = true;
    private LinearLayout hiddenLayout;
    private boolean isMenuHidden = true;
    private TextView[] subjects;
    private TextView timetable;
    private SharedPreferences sharedPreferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_cse_main);

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

        sharedPreferences = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        loadAttendanceData();

        imageView = findViewById(R.id.imageView);

        handler = new Handler();
        updateImageRunnable = new Runnable() {
            @Override
            public void run() {
                updateImageView();
                // Repeat every hour
                handler.postDelayed(this, 60 * 60 * 1000);
            }
        };

        // Start the runnable for the first time
        handler.post(updateImageRunnable);

        subjects = new TextView[]{
                findViewById(R.id.attendanceSub1),
                findViewById(R.id.attendanceSub2),
                findViewById(R.id.attendanceSub3),
                findViewById(R.id.attendanceSub4),
                findViewById(R.id.attendanceSub5),
                findViewById(R.id.attendanceSub6)
        };

        timetable = findViewById(R.id.timetabletext);

        Button[] buttons = {
                findViewById(R.id.Subbtn1),
                findViewById(R.id.Subbtn2),
                findViewById(R.id.Subbtn3),
                findViewById(R.id.Subbtn4),
                findViewById(R.id.Subbtn5),
                findViewById(R.id.Subbtn6)
        };

        scrollView2 = findViewById(R.id.scrollView2);

        timetable.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent_timetable = new Intent(CSE_MainActivity.this, TimeTableActivity.class);
                startActivity(intent_timetable);
            }
        });

        for (int i = 0; i < attendanceData.length; i++) {
            subjects[i].setText(String.format("%.1f%%", attendanceData[i].getAttendancePercentage()));
            final int index = i;
            buttons[i].setOnClickListener(v -> {
                Intent intent = new Intent(CSE_MainActivity.this, DetailActivity.class);
                intent.putExtra("index", index);
                intent.putExtra("callingActivity", "CSE");
                startActivityForResult(intent, 1);
            });
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1 && resultCode == RESULT_OK) {
            int index = data.getIntExtra("index", -1);
            if (index != -1) {
                subjects[index].setText(String.format("%.1f%%", attendanceData[index].getAttendancePercentage()));
                saveAttendanceData(index);
            }
        }
    }

    public void toggleLayoutVisibility(View view) {
        int gridId = view.getId();

        // Initialize hiddenLayout based on gridId
        if (gridId == R.id.grid1) {
            hiddenLayout = findViewById(R.id.hiddenLayout5);
        } else if (gridId == R.id.grid2) {
            hiddenLayout = findViewById(R.id.hiddenLayout4);
        } else if (gridId == R.id.grid3) {
            hiddenLayout = findViewById(R.id.hiddenLayout3);
        } else if (gridId == R.id.grid4) {
            hiddenLayout = findViewById(R.id.hiddenLayout2);
        } else if (gridId == R.id.grid5) {
            hiddenLayout = findViewById(R.id.hiddenLayout1);
        } else if (gridId == R.id.grid6) {
            hiddenLayout = findViewById(R.id.hiddenLayout);
        }

        // Ensure hiddenLayout is not null before changing visibility
        if (hiddenLayout != null) {
            if (isHidden) {
                hiddenLayout.setVisibility(View.VISIBLE);
                if (gridId == R.id.grid6 || gridId == R.id.grid5 || gridId == R.id.grid4) {
                    scrollView2.post(new Runnable() {
                        @Override
                        public void run() {
                            scrollView2.fullScroll(View.FOCUS_DOWN);
                        }
                    });
                }
            } else {
                hiddenLayout.setVisibility(View.GONE);
            }
            isHidden = !isHidden;
        }
    }

    public void toggleMenuLayoutVisibility(View view) {
        LinearLayout hiddenMenuLayout = findViewById(R.id.Menu);

        if (isMenuHidden) {
            hiddenMenuLayout.setVisibility(View.VISIBLE);
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    hiddenMenuLayout.setVisibility(View.GONE);
                    isMenuHidden = !isMenuHidden;
                }
            }, 10000); // Hide the menu after 10 seconds
        } else {
            hiddenMenuLayout.setVisibility(View.GONE);
        }
        isMenuHidden = !isMenuHidden;
    }

    private void updateImageView() {
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);

        if (hour >= 6 && hour < 9) {
            imageView.setImageResource(R.drawable.morning);
        } else if (hour >= 9 && hour < 15) {
            imageView.setImageResource(R.drawable.working);
        } else if (hour >= 15 && hour < 19) {
            imageView.setImageResource(R.drawable.evening);
        } else {
            imageView.setImageResource(R.drawable.before_night); // You can set a default image for other times
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Remove callbacks to avoid memory leaks
        handler.removeCallbacks(updateImageRunnable);
    }

    private void saveAttendanceData(int index) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(ATTENDANCE_KEY_PREFIX + index, attendanceData[index].toString());
        editor.apply();
    }

    private void loadAttendanceData() {
        for (int i = 0; i < attendanceData.length; i++) {
            String dataString = sharedPreferences.getString(ATTENDANCE_KEY_PREFIX + i, null);
            if (dataString != null) {
                attendanceData[i] = AttendanceData.fromString(dataString);
            }
        }
    }

    public static AttendanceData getAttendanceData(int index) {
        if (index >= 0 && index < attendanceData.length) {
            return attendanceData[index];
        }
        return null;
    }
}

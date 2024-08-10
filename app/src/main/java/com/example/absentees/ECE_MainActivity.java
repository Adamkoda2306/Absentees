package com.example.absentees;

import androidx.activity.EdgeToEdge;
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
import android.view.WindowManager;
import androidx.core.content.ContextCompat;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import java.util.Calendar;

public class ECE_MainActivity extends AppCompatActivity {

    private static final String PREFS_NAME = "AttendancePrefs";
    private static final String ATTENDANCE_KEY_PREFIX = "attendance_";

    private static AttendanceData[] attendanceData = {
            new AttendanceData("RANAC", 48, 0, 0, 0),
            new AttendanceData("OOPs", 36, 0, 0, 0),
            new AttendanceData("ES", 36, 0, 0, 0),
            new AttendanceData("CNA", 36, 0, 0, 0),
            new AttendanceData("CS", 36, 0, 0, 0),
            new AttendanceData("PC", 24, 0, 0, 0)
    };

    private ImageView imageView;
    private Handler handler;
    private Runnable updateImageRunnable;
    private ScrollView scrollView2;
    private boolean isHidden = true;
    private LinearLayout hiddenLayout;
    private boolean isMenuHidden = true;
    private TextView[] subjects;
    private TextView timetable,alamanac;
    private SharedPreferences sharedPreferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_ece_main);

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

        imageView = findViewById(R.id.imageViewece);

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
                findViewById(R.id.attendanceSub1ece),
                findViewById(R.id.attendanceSub2ece),
                findViewById(R.id.attendanceSub3ece),
                findViewById(R.id.attendanceSub4ece),
                findViewById(R.id.attendanceSub5ece),
                findViewById(R.id.attendanceSub6ece)
        };

        Button[] buttons = {
                findViewById(R.id.Subbtn1ece),
                findViewById(R.id.Subbtn2ece),
                findViewById(R.id.Subbtn3ece),
                findViewById(R.id.Subbtn4ece),
                findViewById(R.id.Subbtn5ece),
                findViewById(R.id.Subbtn6ece)
        };

        scrollView2 = findViewById(R.id.scrollView2ece);
        timetable = findViewById(R.id.timetabletextece);
        alamanac = findViewById(R.id.alamanactextece);

        alamanac.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent_alamanac = new Intent(ECE_MainActivity.this, AlmanacActivity.class);
                startActivity(intent_alamanac);
            }
        });

        timetable.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent_timetable = new Intent(ECE_MainActivity.this, TimeTableActivity.class);
                startActivity(intent_timetable);
            }
        });

        for (int i = 0; i < attendanceData.length; i++) {
            subjects[i].setText(String.format("%.1f%%", attendanceData[i].getAttendancePercentage()));
            final int index = i;
            buttons[i].setOnClickListener(v -> {
                Intent intent = new Intent(ECE_MainActivity.this, DetailActivity.class);
                intent.putExtra("index", index);
                intent.putExtra("callingActivity", "ECE");
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
                saveAttendanceData();
            }
        }
    }

    private void saveAttendanceData() {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        for (int i = 0; i < attendanceData.length; i++) {
            editor.putString(ATTENDANCE_KEY_PREFIX + i, attendanceData[i].toString());
        }
        editor.apply();
    }

    private void loadAttendanceData() {
        for (int i = 0; i < attendanceData.length; i++) {
            String attendanceString = sharedPreferences.getString(ATTENDANCE_KEY_PREFIX + i, null);
            if (attendanceString != null) {
                attendanceData[i] = AttendanceData.fromString(attendanceString);
            }
        }
    }

    public void toggleLayoutVisibility(View view) {
        int gridId = view.getId();

        // Initialize hiddenLayout based on gridId
        if (gridId == R.id.grid1ece) {
            hiddenLayout = findViewById(R.id.hiddenLayout5ece);
        } else if (gridId == R.id.grid2ece) {
            hiddenLayout = findViewById(R.id.hiddenLayout4ece);
        } else if (gridId == R.id.grid3ece) {
            hiddenLayout = findViewById(R.id.hiddenLayout3ece);
        } else if (gridId == R.id.grid4ece) {
            hiddenLayout = findViewById(R.id.hiddenLayout2ece);
        } else if (gridId == R.id.grid5ece) {
            hiddenLayout = findViewById(R.id.hiddenLayout1ece);
        } else if (gridId == R.id.grid6ece) {
            hiddenLayout = findViewById(R.id.hiddenLayoutece);
        }

        // Ensure hiddenLayout is not null before changing visibility
        if (hiddenLayout != null) {
            if (isHidden) {
                hiddenLayout.setVisibility(View.VISIBLE);
                if (gridId == R.id.grid6ece || gridId == R.id.grid5ece || gridId == R.id.grid4ece) {
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
        LinearLayout hiddenMenuLayout = findViewById(R.id.Menuece);

        if (isMenuHidden) {
            hiddenMenuLayout.setVisibility(View.VISIBLE);
            handler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    hiddenMenuLayout.setVisibility(View.GONE);
                    isMenuHidden = !isMenuHidden;
                }
            }, 6000); // Hide the menu after 6 seconds
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
        saveAttendanceData();
    }

    public static AttendanceData getAttendanceData(int index) {
        if (index >= 0 && index < attendanceData.length) {
            return attendanceData[index];
        }
        return null;
    }
}

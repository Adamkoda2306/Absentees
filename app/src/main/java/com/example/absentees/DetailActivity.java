package com.example.absentees;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import androidx.core.content.ContextCompat;
import com.github.mikephil.charting.data.PieEntry;
import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

public class DetailActivity extends AppCompatActivity {

    private static final String PREFS_NAME = "AttendancePrefs";
    private static final String ATTENDANCE_KEY_PREFIX = "attendance_";

    private PieChart pieChart;
    private AttendanceData attendanceData;
    private int index;
    private Stack<Action> actionStack;
    private TextView tvSubjectName;
    private String callingActivity;
    private SharedPreferences sharedPreferences;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_detail);

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

        index = getIntent().getIntExtra("index", -1);
        callingActivity = getIntent().getStringExtra("callingActivity");

        if (index != -1) {
            switch (callingActivity) {
                case "CSE":
                    attendanceData = CSE_MainActivity.getAttendanceData(index);
                    break;
                case "ECE":
                    attendanceData = ECE_MainActivity.getAttendanceData(index);
                    break;
                case "AIDS":
                    attendanceData = AIDS_MainActivity.getAttendanceData(index);
                    break;
                default:
                    throw new IllegalArgumentException("Invalid calling activity");
            }
        }

        pieChart = findViewById(R.id.pieChart);
        Button btnExtraClass = findViewById(R.id.btnExtraClass);
        Button btnCancelledClass = findViewById(R.id.btnCancelledClass);
        Button btnAbsent = findViewById(R.id.btnAbsent);
        Button btnUndo = findViewById(R.id.btnUndo);
        Button btnBack = findViewById(R.id.btnBack);
        tvSubjectName = findViewById(R.id.tvSubjectName);

        actionStack = new Stack<>();

        String subjectName = attendanceData.getSubjectName();
        tvSubjectName.setText(subjectName);

        updatePieChart();

        btnExtraClass.setOnClickListener(v -> {
            actionStack.push(new Action(ActionType.ADD_EXTRA_CLASS));
            attendanceData.addExtraClass();
            updatePieChart();
            saveAttendanceData();
        });

        btnCancelledClass.setOnClickListener(v -> {
            actionStack.push(new Action(ActionType.ADD_CANCELED_CLASS));
            attendanceData.addCanceledClass();
            updatePieChart();
            saveAttendanceData();
        });

        btnAbsent.setOnClickListener(v -> {
            actionStack.push(new Action(ActionType.INCREMENT_ABSENTS));
            attendanceData.incrementAbsents();
            updatePieChart();
            saveAttendanceData();
        });

        btnUndo.setOnClickListener(v -> {
            if (!actionStack.isEmpty()) {
                Action lastAction = actionStack.pop();
                undoAction(lastAction);
                updatePieChart();
                saveAttendanceData();
            }
        });

        btnBack.setOnClickListener(v -> {
            Intent resultIntent = new Intent();
            resultIntent.putExtra("index", index);
            resultIntent.putExtra("callingActivity", callingActivity);
            setResult(RESULT_OK, resultIntent);
            finish();
            overridePendingTransition(R.anim.slide_in_left, R.anim.slide_out_right);
        });
    }

    @Override
    public void onBackPressed() {
        Intent resultIntent = new Intent();
        resultIntent.putExtra("index", index);
        resultIntent.putExtra("callingActivity", callingActivity);
        setResult(RESULT_OK, resultIntent);
        finish();
    }

    private void updatePieChart() {
        List<PieEntry> entries = new ArrayList<>();
        int totalClasses = attendanceData.getTotalClasses();
        int requiredClasses = attendanceData.getAllowedAbsencesFor75Percent();
        int remainingclasses = (int) Math.ceil(0.75 * totalClasses);
        int absents = attendanceData.getAbsents();
        int safe;

        if(requiredClasses > 0) {
            safe = totalClasses - requiredClasses - absents;
        }else {
            safe = totalClasses - absents;
        }

        entries.add(new PieEntry(safe, "Safe"));
        entries.add(new PieEntry(Math.min(absents, totalClasses), "Absents"));
        if (requiredClasses > 0) {
            entries.add(new PieEntry(requiredClasses, "Maintaining 75%"));
        }

        PieDataSet dataSet = new PieDataSet(entries, "Attendance");
        dataSet.setColors(new int[]{Color.parseColor("#04821d"), Color.RED, Color.parseColor("#26cced")});
        dataSet.setValueTextSize(16f);
        dataSet.setValueTextColor(Color.BLACK);

        PieData pieData = new PieData(dataSet);
        pieChart.setData(pieData);
        pieChart.setCenterText("Attendance");
        pieChart.setCenterTextSize(18f);
        pieChart.setCenterTextColor(Color.BLACK);

        pieChart.getDescription().setText(" ");
        pieChart.invalidate(); // refresh
    }

    private void undoAction(Action action) {
        switch (action.getActionType()) {
            case ADD_EXTRA_CLASS:
                attendanceData.addCanceledClass(); // revert add extra class
                break;
            case ADD_CANCELED_CLASS:
                attendanceData.addExtraClass(); // revert add canceled class
                break;
            case INCREMENT_ABSENTS:
                attendanceData.decrementAbsents(); // revert increment absents
                break;
        }
    }

    private void saveAttendanceData() {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(ATTENDANCE_KEY_PREFIX + index, attendanceData.toString());
        editor.apply();
    }

    private static class Action {
        private final ActionType actionType;

        public Action(ActionType actionType) {
            this.actionType = actionType;
        }

        public ActionType getActionType() {
            return actionType;
        }
    }

    private enum ActionType {
        ADD_EXTRA_CLASS,
        ADD_CANCELED_CLASS,
        INCREMENT_ABSENTS
    }
}

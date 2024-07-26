package com.example.absentees;

public class AttendanceData {
    private String subjectName;
    private int totalClasses;
    private int extraClasses;
    private int canceledClasses;
    private int absents;

    public AttendanceData(String subjectName, int totalClasses, int extraClasses, int canceledClasses, int absents) {
        this.subjectName = subjectName;
        this.totalClasses = totalClasses;
        this.extraClasses = extraClasses;
        this.canceledClasses = canceledClasses;
        this.absents = absents;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public int getPresents() {
        return totalClasses - absents;
    }

    public void addExtraClass() {
        this.totalClasses++;
    }

    public int getTotalClasses() {
        return totalClasses;
    }

    public int getExtraClasses() {
        return extraClasses;
    }

    public void addCanceledClass() {
        this.totalClasses--;
    }

    public int getCanceledClasses() {
        return canceledClasses;
    }

    public void incrementAbsents() {
        this.absents++;
    }

    public void decrementAbsents() {
        this.absents--;
    }

    public int getAbsents() {
        return absents;
    }

    public double getAttendancePercentage() {
        return (double) getPresents() / totalClasses * 100;
    }

    public int getAllowedAbsencesFor75Percent() {
        int requiredPresents = (int) Math.ceil(0.75 * totalClasses);
        return totalClasses - requiredPresents - absents;
    }

    @Override
    public String toString() {
        return subjectName + "," + totalClasses + "," + extraClasses + "," + canceledClasses + "," + absents;
    }

    public static AttendanceData fromString(String data) {
        String[] parts = data.split(",");
        return new AttendanceData(
                parts[0],
                Integer.parseInt(parts[1]),
                Integer.parseInt(parts[2]),
                Integer.parseInt(parts[3]),
                Integer.parseInt(parts[4])
        );
    }
}

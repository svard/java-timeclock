package net.svard.domain;

public class ClientReport {
    private long workTime;

    private long lunchTime;

    private long arrivalTime;

    private long leaveTime;

    public long getWorkTime() {
        return workTime;
    }

    public void setWorkTime(long workTime) {
        this.workTime = workTime;
    }

    public long getLunchTime() {
        return lunchTime;
    }

    public void setLunchTime(long lunchTime) {
        this.lunchTime = lunchTime;
    }

    public long getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(long arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public long getLeaveTime() {
        return leaveTime;
    }

    public void setLeaveTime(long leaveTime) {
        this.leaveTime = leaveTime;
    }

    @Override
    public String toString() {
        return "ClientReport{" +
                "workTime=" + workTime +
                ", lunchTime=" + lunchTime +
                ", arrivalTime=" + arrivalTime +
                ", leaveTime=" + leaveTime +
                '}';
    }
}

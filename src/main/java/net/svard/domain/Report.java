package net.svard.domain;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

@Document(collection = "reports")
public class Report {
    @Id
    @Field("_id")
    private String id;

    private long total;

    private long lunch;

    private Date arrival;

    private Date leave;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public long getTotal() {
        return total;
    }

    public void setTotal(long total) {
        this.total = total;
    }

    public long getLunch() {
        return lunch;
    }

    public void setLunch(long lunch) {
        this.lunch = lunch;
    }

    public Date getArrival() {
        return arrival;
    }

    public void setArrival(Date arrival) {
        this.arrival = arrival;
    }

    public Date getLeave() {
        return leave;
    }

    public void setLeave(Date leave) {
        this.leave = leave;
    }

    @Override
    public String toString() {
        return "Report{" +
                "id='" + id + '\'' +
                ", total=" + total +
                ", lunch=" + lunch +
                ", arrival=" + arrival +
                ", leave=" + leave +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Report report = (Report) o;

        if (total != report.total) return false;
        if (lunch != report.lunch) return false;
        if (id != null ? !id.equals(report.id) : report.id != null) return false;
        if (arrival != null ? !arrival.equals(report.arrival) : report.arrival != null) return false;
        return leave != null ? leave.equals(report.leave) : report.leave == null;

    }

    @Override
    public int hashCode() {
        int result = id != null ? id.hashCode() : 0;
        result = 31 * result + (int) (total ^ (total >>> 32));
        result = 31 * result + (int) (lunch ^ (lunch >>> 32));
        result = 31 * result + (arrival != null ? arrival.hashCode() : 0);
        result = 31 * result + (leave != null ? leave.hashCode() : 0);
        return result;
    }
}

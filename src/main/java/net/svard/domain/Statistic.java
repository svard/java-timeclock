package net.svard.domain;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Document(collection = "reports")
public class Statistic {
    @Id
//    @Field("_id")
    private int id;

    private long sum;

    private long avg;

    private Date shortestDate;

    private Date longestDate;

    private long shortestTime;

    private long longestTime;

    private class Record {
        private Date date;

        private long time;

        public Record(Date date, long time) {
            this.date = date;
            this.time = time;
        }

        public Date getDate() {
            return date;
        }

        public long getTime() {
            return time;
        }
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public long getSum() {
        return sum;
    }

    public void setSum(long sum) {
        this.sum = sum;
    }

    public long getAvg() {
        return avg;
    }

    public void setAvg(long avg) {
        this.avg = avg;
    }

    public void setShortestDate(Date shortestDate) {
        this.shortestDate = shortestDate;
    }

    public void setLongestDate(Date longestDate) {
        this.longestDate = longestDate;
    }

    public void setShortestTime(long shortestTime) {
        this.shortestTime = shortestTime;
    }

    public void setLongestTime(long longestTime) {
        this.longestTime = longestTime;
    }

    public Record getLongest() {
        return new Record(longestDate, longestTime);
    }

    public Record getShortest() {
        return new Record(shortestDate, shortestTime);
    }
}

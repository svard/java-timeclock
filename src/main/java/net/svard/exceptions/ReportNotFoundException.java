package net.svard.exceptions;

public class ReportNotFoundException extends RuntimeException {
    private String id;

    public ReportNotFoundException(String id) {
        this.id = id;
    }

    public String getId() {
        return id;
    }
}

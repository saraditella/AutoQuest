package model.bean;

public enum Cambio {
    Manuale, Automatico, Sequenziale, CVT, Doppia_Frizione;

    public static Cambio fromString(String value) {
        return switch (value) {
            case "Doppia Frizione" -> Doppia_Frizione;
            default -> Cambio.valueOf(value);
        };
    }

    @Override
    public String toString() {
        return this == Doppia_Frizione ? "Doppia Frizione" : name();
    }
}
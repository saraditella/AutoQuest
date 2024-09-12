package model.bean;

public enum Alimentazione {
    Benzina, Diesel, Elettrica, Ibrida, Ibrida_Plug_in, GPL, Metano, Idrogeno;

    //converte uba stringa in un valore dell'enum Alimentazione
    public static Alimentazione fromString(String value) {
        return switch (value) {
            case "Ibrida Plug-in" -> Ibrida_Plug_in; //intercetta in modo specifico ibrida plug-in
            default -> Alimentazione.valueOf(value);
        };
    }


    @Override
    public String toString() {
        return this == Ibrida_Plug_in ? "Ibrida Plug-in" : name();
    }
}
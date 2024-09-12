// File: salva-confronto.js
// Gestisce il click su “Salva confronto” in confronto.jsp

document.addEventListener("DOMContentLoaded", function() {
    const btn = document.getElementById("btnSalvaConfronto");
    if (!btn) return;  // nulla da fare se non presente

    btn.addEventListener("click", function() {
        const nomeEl = document.getElementById("nomeConfronto");
        const nome = nomeEl ? nomeEl.value.trim() : "";
        if (!nome) {
            if (typeof window.mostraMessaggio === "function") window.mostraMessaggio("Inserisci un nome per il confronto", "error");
            else alert("Inserisci un nome per il confronto");
            return;
        }

        // Costruisco URL-encoded
        const params = new URLSearchParams();
        params.append("nomeConfronto", nome);

        // OPZIONALE: se sulla pagina esiste un hiddenIdAllestimento (es. da dettaglio) lo includiamo
        // non è obbligatorio per il salvataggio del confronto (la servlet usa la sessione.confronto),
        // ma lo aggiungiamo come sicurezza/estensione
        const hiddenAll = document.getElementById("hiddenIdAllestimento") || document.querySelector('input[name="idAllestimento"][type="hidden"]');
        if (hiddenAll && hiddenAll.value) {
            params.append("idAllestimento", hiddenAll.value);
        } else {
            // fallback: cerca una radio selezionata in pagina
            const radioSel = document.querySelector('input[name="idAllestimento"]:checked');
            if (radioSel) params.append("idAllestimento", radioSel.value);
        }

        fetch(contextPath + "/salva-confronto", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
            },
            body: params.toString(),
            credentials: 'same-origin'
        })
            .then(resp => {
                if (!resp.ok) throw new Error(resp.statusText);
                return resp.json();
            })
            .then(data => {
                if (typeof window.mostraMessaggio === "function") {
                    window.mostraMessaggio(data.message, data.success ? "success" : "error");
                } else {
                    // fallback
                    const alertFn = data.success ? alert : alert;
                    alertFn(data.message);
                }
            })
            .catch(err => {
                if (typeof window.mostraMessaggio === "function") window.mostraMessaggio("Errore nel salvataggio: " + err.message, "error");
                else alert("Errore nel salvataggio: " + err.message);
            });
    });
});
